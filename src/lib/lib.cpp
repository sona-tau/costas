#include "lib.hpp"
#include "prelude.hpp"
#include <cmath>
#include <ranges>

fn is_primitive_root(UInt p, Int a) noexcept -> Bool {
    return (UInt(std::pow(a, (p - 1) / 2)) % p) == p - 1;
}

fn primitive_roots(UInt p) noexcept -> Vec<UInt> {
    Vec<UInt> out;
    out.reserve(Size(p));
    for (auto i : vi::iota(1, Int(p))) {
        if (is_primitive_root(p, i))
            out.push_back(i);
    }
    return out;
}

fn seq(UInt p, UInt a) noexcept -> Vec<UInt> {
    Vec<UInt> out;
    out.reserve(Size(p));
    for (UInt i = 1, e = a; e != 1; ++i) {
        e = UInt(std::pow(a, i)) % p;
        out.push_back(e);
    }
    return out;
}

