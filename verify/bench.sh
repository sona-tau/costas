#!/usr/bin/env bash
# usage: ./bench.sh [iscostas.c]
set -euo pipefail

src=$(realpath "${1:-iscostas.c}")
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
command -v hyperfine >/dev/null || { echo "hyperfine not found" >&2; exit 1; }

# --- driver: includes your file (its main renamed), loops one impl `reps` times
cat > "$work/bench.c" <<'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#define main costas_orig_main
#include SRC
#undef main

static const struct { const char *name; bool (*fn)(const uint8_t *, size_t); } impls[] = {
    {"scalar",   costas_scalar},
    {"avx2",     costas_avx2},
    {"avx512bw", costas_avx512bw},
    {"avx512cd", costas_avx512cd},
};

int main(int argc, char **argv) {
    if (argc != 4) { fprintf(stderr, "usage: %s impl reps file\n", argv[0]); return 2; }
    bool (*fn)(const uint8_t *, size_t) = NULL;
    for (size_t i = 0; i < sizeof impls / sizeof *impls; ++i)
        if (!strcmp(argv[1], impls[i].name)) fn = impls[i].fn;
    if (!fn) { fprintf(stderr, "unknown impl %s\n", argv[1]); return 2; }

    long reps = atol(argv[2]);
    FILE *f = fopen(argv[3], "r");
    if (!f) return 2;
    size_t n;
    uint8_t perm[256] = {0};
    if (fscanf(f, "%zu", &n) != 1 || n > 255) return 2;
    for (size_t i = 0; i < n; ++i) {
        unsigned v;
        if (fscanf(f, "%u", &v) != 1 || v > 255) return 2;
        perm[i] = (uint8_t)v;
    }
    fclose(f);

    if (!fn(perm, n)) { fprintf(stderr, "%s rejected a valid Costas array\n", argv[1]); return 1; }

    long sink = 0;
    for (long r = 0; r < reps; ++r) {
        sink += fn(perm, n);
        __asm__ volatile("" : "+r"(sink) :: "memory");   /* stop hoisting */
    }
    return sink == reps ? 0 : 1;
}
EOF

cc -O3 -std=gnu11 -DSRC="\"$src\"" -o "$work/bench" "$work/bench.c"

# --- Welch construction: perm[i] = g^i mod p, order p-1, always Costas
gen_welch() {
    awk -v p="$1" 'BEGIN {
        for (g = 2; g < p; g++) {
            x = 1
            for (k = 1; k < p; k++) { x = (x * g) % p; if (x == 1) break }
            if (k == p - 1) break
        }
        x = 1
        printf "%d\n", p - 1
        for (i = 0; i < p - 1; i++) { printf "%d%s", x, (i < p - 2 ? " " : "\n"); x = (x * g) % p }
    }'
}

# --- only benchmark what this CPU supports
impls=(scalar)
grep -qw avx2     /proc/cpuinfo && impls+=(avx2)
grep -qw avx512bw /proc/cpuinfo && impls+=(avx512bw)
grep -qw avx512cd /proc/cpuinfo && impls+=(avx512cd)
list=$(IFS=,; echo "${impls[*]}")

for p in 31 61 101 127 181 251; do
    n=$((p - 1))
    gen_welch "$p" > "$work/in_$n.txt"
    reps=$((300000000 / (n * n)))
    echo "== n=$n  reps=$reps =="
    hyperfine -N --warmup 2 \
        --export-markdown "results_n$n.md" \
        -L impl "$list" \
        "$work/bench {impl} $reps $work/in_$n.txt"
done
