#include "external.hpp"
#include "lib/lib.hpp"
#include "test/test.hpp"
#include <cassert>
#include <format>
#include <iostream>
#include <ranges>

fn main() noexcept -> int {
#ifndef TEST
    for (auto p : vi::iota(5, 20) | vi::filter(ext::is_prime)) {
        std::cout << std::format("Primitive roots for {}.\n", p);
        for (auto root : primitive_roots(UInt(p))) {
            std::cout << std::format("{}: [", root);
            let s = seq(p, root);
            assert(is_permutation_matrix(s));
            for (auto space = ""; auto p : s) {
                std::cout << space << p;
                space = " ";
            }
            std::cout << "]" << std::endl;
        }
    }
#else
    let s1 = seq(11, 2);
    Vec<UInt> s2 = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11};
    "2 is a primitive root of 11"_test = is_primitive_root(11, 2);
    "test permutation matrix for 11 for alpha 2"_test =
        is_permutation_matrix(s1);
    "test permutation matrix for 11 with increasing numbers"_test =
        not is_permutation_matrix(s2);
#endif


    return 0;
}
