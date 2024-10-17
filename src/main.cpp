#include "external.hpp"
#include "lib/lib.hpp"
#include "test/test.hpp"
#include <algorithm>
#include <cassert>
#include <format>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <ranges>

void static foo() noexcept {
    for (auto p : vi::iota(5, 100) | vi::filter(ext::is_prime)) {
        let roots = primitive_roots((UInt(p)));
        let first_root = roots.front();
        std::cout << std::format("${}$, ${}, ", p, first_root);

        var space = "";
        for (auto root : roots | vi::drop(1)) {
            let i = find_index(seq(p, root), first_root) + 1;
            std::cout << std::format("{}{}^{}", space, first_root, i);
            space = ", ";
        }

        std::cout << "$\n";
    }
}

fn main() noexcept -> int {
#ifndef TEST
    for (var n = 2; n < 30; ++n) {
        var vec = Vec<UInt>(n);
        ra::iota(vec, 1);
        let nxn = costas_nxn<UInt>(vec);

        std::ofstream file;
        file.open(std::format("costas_{}x{}.txt", n, n));
        file << "[\n";
        for (var v : nxn) {
            file << "[";
            String comma = "";
            for (var i : v) {
                file << comma << i;
                comma = ", ";
            }
            file << "],\n";
        }
        file << "]\n";
        file.close();
    }
    /*
    for (let p : vi::iota(5, 25) | vi::filter(ext::is_prime)) {
        std::cout << std::format("Primitive roots for {}:\n", p);
        for (let root : primitive_roots(UInt(p))) {
            var space = "";
            for (let n : seq(p, root)) {
                std::cout << std::format("{}{}", space, n);
                space = " ";
            }
            std::cout << "\n";
        }
    }
    */
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
