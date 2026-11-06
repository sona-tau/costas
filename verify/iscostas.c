#include <assert.h>
#include <immintrin.h>
#include <inttypes.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

bool is_perm(const uint8_t* perm, size_t n) {
    if (n > 255) {
        fprintf(stderr, "ERROR: n is too big. Expected %zu <= 255.\n", n);
        return false;
    }

    // maximum size should be 255 = 4 * 64, but each uint64_t is accessed like
    // this:
    /*  aa bbbbbb
     *  ^  ^
     *  |  L this is the start of a number which indicates what bit to check
     *  L this is the start of a number which indicates which index to use
     */
    uint64_t seen[4] = {0};
    for (size_t i = 0; i < n; ++i) {
        uint8_t v = perm[i];
        if (v < 1 || v > n)
            return false;

        uint64_t bit = 1ull << (v & 63 /* take last 6 bits */);
        if (seen[v >> 6 /* index with first two bits */] & bit)
            return false;
        seen[v >> 6] |= bit;
    }

    return true;
}

/* 1. scalar: stamp table, no per-k clearing */
bool costas_scalar(const uint8_t* permutation, size_t order) {
    if (!is_perm(permutation, order))
        return false;

    // difference is between -255 and 255, each limit turned into a positive
    // number results in 0 to 512. Using uint8_t limits the maximum array size
    // to 256 by 256.
    uint8_t stamp[512] = {0};

#define STEP(i)                                                                \
    do {                                                                       \
        uint32_t d = permutation[(i) + gap] - permutation[(i)] + 255;          \
        if (stamp[d] == gap)                                                   \
            return false;                                                      \
        stamp[d] = (uint8_t)gap;                                               \
    } while (0)

    for (size_t gap = 1; 2 * gap < order; ++gap) { // rows up to (order - 1) / 2
        size_t row_length = order - gap;           // row length
        size_t skip_begin =
            order - 2 * gap; // skip 0-based i in [skip_begin, skip_end)
        size_t skip_end = gap;

        if (skip_begin >= skip_end)
            skip_begin = skip_end = row_length; // gap <= order / 3: no skip
        for (size_t block_start = 0; block_start < skip_begin; ++block_start)
            STEP(block_start);
        for (size_t block_start = skip_end; block_start < row_length;
             ++block_start)
            STEP(block_start);
    }
#undef STEP
    return true;
}

/* 2. AVX2: diffs in int16, all-pairs compare via shifted unaligned loads */
__attribute__((target("avx2"))) bool costas_avx2(const uint8_t* permutation,
                                                 size_t order) {
    if (!is_perm(permutation, order))
        return false;

    uint8_t zero_padded_permutation[320] = {0};
    int16_t differences[320] = {0};
    memcpy(zero_padded_permutation, permutation, order);

    for (size_t gap = 1; 2 * gap < order; ++gap) {
        size_t row_length = order - gap;

        for (size_t block_start = 0; block_start < row_length;
             block_start += 16) {
            // load 16 bytes from zero_padded_permutation + block_start
            __m256i lo_values = _mm256_cvtepu8_epi16(_mm_loadu_si128(
                (const __m128i*)(zero_padded_permutation + block_start)));

            // load 16 bytes from zero_padded_permutation + block_start + gap
            __m256i hi_values = _mm256_cvtepu8_epi16(_mm_loadu_si128(
                (const __m128i*)(zero_padded_permutation + block_start + gap)));

            // store each (zero_padded_permutation + block_start) -
            // (zero_padded_permutation + block_start + gap) in differences +
            // block_start
            _mm256_storeu_si256((__m256i*)(differences + block_start),
                                _mm256_sub_epi16(hi_values, lo_values));
        }

        for (size_t shift = 1; shift < row_length; ++shift) {
            size_t pairs_at_shift = row_length - shift;

            for (size_t block_start = 0; block_start < pairs_at_shift;
                 block_start += 16) {
                size_t lanes_remaining = pairs_at_shift - block_start;
                uint32_t tail_mask = lanes_remaining >= 16
                                         ? ~0u
                                         : (1u << (2 * lanes_remaining)) - 1;

                // load differences + block_start
                __m256i x = _mm256_loadu_si256(
                    (const __m256i*)(differences + block_start));

                // load differences + block_start + shift
                __m256i y = _mm256_loadu_si256(
                    (const __m256i*)(differences + block_start + shift));

                // compare differences + block_start with differences +
                // block_start + shift
                if ((uint32_t)_mm256_movemask_epi8(_mm256_cmpeq_epi16(x, y)) &
                    tail_mask)
                    return false;
            }
        }
    }
    return true;
}

/* 3. AVX-512BW: same, 32 lanes, mask registers handle tails */
__attribute__((target("avx512f,avx512bw"))) bool
costas_avx512bw(const uint8_t* p, size_t n) {
    if (!is_perm(p, n))
        return false;
    uint8_t q[320] = {0};
    int16_t d[320] = {0};
    memcpy(q, p, n);
    for (size_t k = 1; 2 * k < n; ++k) {
        size_t m = n - k;
        for (size_t i = 0; i < m; i += 32) {
            __m512i a = _mm512_cvtepu8_epi16(
                _mm256_loadu_si256((const __m256i*)(q + i)));
            __m512i b = _mm512_cvtepu8_epi16(
                _mm256_loadu_si256((const __m256i*)(q + i + k)));
            _mm512_storeu_si512(d + i, _mm512_sub_epi16(b, a));
        }
        for (size_t r = k; r < m; ++r) {
            size_t len = m - r;
            for (size_t i = 0; i < len; i += 32) {
                size_t c = len - i;
                __mmask32 v = c >= 32 ? ~0u : (1u << c) - 1;
                __m512i x = _mm512_loadu_si512(d + i);
                __m512i y = _mm512_loadu_si512(d + i + r);
                if (_mm512_mask_cmpeq_epi16_mask(v, x, y))
                    return false;
            }
        }
    }
    return true;
}

/* 4. AVX-512CD: vpconflictd within a vector, gather/scatter stamp table across
 * vectors */
__attribute__((target("avx512f,avx512cd"))) bool
costas_avx512cd(const uint8_t* p, size_t n) {
    if (!is_perm(p, n))
        return false;
    uint8_t q[320] = {0};
    int32_t stamp[512] = {0};
    memcpy(q, p, n);
    const __m512i off = _mm512_set1_epi32(255);
    for (size_t k = 1; k + 1 < n; ++k) {
        __m512i kv = _mm512_set1_epi32((int)k);
        size_t m = n - k;
        for (size_t i = 0; i < m; i += 16) {
            size_t c = m - i;
            __mmask16 v = c >= 16 ? 0xFFFF : (__mmask16)((1u << c) - 1);
            __m512i a =
                _mm512_cvtepu8_epi32(_mm_loadu_si128((const __m128i*)(q + i)));
            __m512i b = _mm512_cvtepu8_epi32(
                _mm_loadu_si128((const __m128i*)(q + i + k)));
            __m512i d = _mm512_add_epi32(_mm512_sub_epi32(b, a), off);
            __m512i cf = _mm512_conflict_epi32(d);
            if (_mm512_mask_test_epi32_mask(v, cf, cf))
                return false;
            __m512i g = _mm512_mask_i32gather_epi32(_mm512_setzero_si512(), v,
                                                    d, stamp, 4);
            if (_mm512_mask_cmpeq_epi32_mask(v, g, kv))
                return false;
            _mm512_mask_i32scatter_epi32(stamp, v, d, kv, 4);
        }
    }
    return true;
}

int main(void) {
    size_t n;
    if (scanf("%zu", &n) != 1 || n > 255)
        return 1;
    uint8_t permutation[255] = {0};

    for (size_t i = 0; i < n; ++i) {
        uint32_t v = 0;
        if (scanf("%" SCNu32, &v) != 1 || v > 255)
            return 1;
        permutation[i] = (uint8_t)v;
    }

    __builtin_cpu_init();
    if (__builtin_cpu_supports("avx512cd"))
        printf("%d\n", costas_avx512cd(permutation, n) ? 1 : 0);
    else if (__builtin_cpu_supports("avx512bw"))
        printf("%d\n", costas_avx512bw(permutation, n) ? 1 : 0);
    else if (__builtin_cpu_supports("avx2"))
        printf("%d\n", costas_avx2(permutation, n) ? 1 : 0);
    else
        printf("%d\n", costas_scalar(permutation, n) ? 1 : 0);
    return 0;
}
