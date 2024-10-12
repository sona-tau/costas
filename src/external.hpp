#pragma once
#include "lib/prelude.hpp"

namespace ext {
// power, witness and is_prime taken from: https://stackoverflow.com/a/4424496
fn constexpr power(I64 power, I32 base, I32 mod) noexcept -> I64 {
    I64 result = I64(1);

    while (base) {
        if (base & 1)
            result = (result * power) % mod;
        power = (power * power) % mod;
        base >>= 1;
    }
    return result;
}

fn constexpr witness(I32 a, I32 n) noexcept -> Bool {
    I32 t, u, i;
    I64 prev, curr;

    u = n / 2;
    t = 1;
    while (!(u & 1)) {
        u /= 2;
        ++t;
    }

    prev = power(a, u, n);
    // [[assume(i <= t)]];
    for (i = 1; i <= t; ++i) {
        curr = (prev * prev) % n;
        if (curr == 1 && prev != 1 && prev != n - 1)
            return true;
        prev = curr;
    }

    if (curr != 1)
        return true;
    return false;
}

/* WARNING: Algorithm deterministic only for numbers < 4,759,123,141 (unsigned
 * int's max is 4294967296) if n < 1,373,653, it is enough to test a = 2 and 3.
 * if n < 9,080,191, it is enough to test a = 31 and 73.
 * if n < 4,759,123,141, it is enough to test a = 2, 7, and 61.
 * if n < 2,152,302,898,747, it is enough to test a = 2, 3, 5, 7, and 11.
 * if n < 3,474,749,660,383, it is enough to test a = 2, 3, 5, 7, 11, and 13.
 * if n < 341,550,071,728,321, it is enough to test a = 2, 3, 5, 7, 11, 13,
 * and 17.
 */
fn inline is_prime(Int number) noexcept -> Bool {
    if ((!(number & 1) && number != 2) || number < 2 ||
        (number % 3 == 0 && number != 3))
        return false;

    if (number < 1373653) {
        for (Int k = 1; 36 * k * k - 12 * k < number; ++k)
            if (number % (6 * k + 1) == 0 || (number % 6 * k - 1) == 0)
                return false;

        return true;
    }

    if (number < 9080191) {
        if (witness(31, number))
            return false;
        if (witness(73, number))
            return false;
        return true;
    }

    if (witness(2, number))
        return false;
    if (witness(7, number))
        return false;
    if (witness(61, number))
        return false;
    return true;
}
} // namespace ext
