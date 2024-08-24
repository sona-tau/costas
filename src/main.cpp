#include "external.hpp"
#include "lib/lib.hpp"
#include "test/test.hpp"
#include <iostream>
#include <ranges>

fn main() noexcept -> int {
    "2 is a primitive root of 11"_test = is_primitive_root(11, 2);
    for (auto p : vi::iota(2, 20) | vi::filter(is_prime)) {
        auto space = "";
        std::cout << p << ": [";
        for (auto const& i : primitive_roots(UInt(p))) {
            std::cout << space << i;
            space = " ";
        }
        std::cout << "]" << std::endl;
    }
    for (auto e : seq(11, 2)) {
        std::cout << e << std::endl;
    }

    return 0;
}
