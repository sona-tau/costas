#pragma once
#include "lib/prelude.hpp"

fn power(I32 a, I32 n, I32 mod) noexcept -> I64;

fn witness(I32 a, I32 n) noexcept -> Bool;

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
            if (number % (6 * k + 1) == 0 ||
                (number % 6 * k - 1) == 0)
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
