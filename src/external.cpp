#include "external.hpp"
#include "lib/prelude.hpp"

// Code taken from: https://stackoverflow.com/a/4424496
fn power(I32 a, I32 n, I32 mod) noexcept -> I64 {
    I64 power = I64(a);
    I64 result = I64(1);

    while (n) {
        if (n & 1)
            result = (result * power) % mod;
        power = (power * power) % mod;
        n >>= 1;
    }
    return result;
}

fn witness(I32 a, I32 n) noexcept -> Bool {
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
