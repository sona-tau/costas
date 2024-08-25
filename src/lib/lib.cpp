#include "lib.hpp"
#include "prelude.hpp"
#include <algorithm>
#include <cmath>
#include <format>
#include <iostream>
#include <numeric>
#include <ranges>
#include <unordered_set>

// TODO: fix
/* Will give a false positive even if a is not a primitive root for p when
 * a^(p - 1) / 2 is congruent to (p - 1).
 */
fn is_primitive_root(UInt p, Int a) noexcept -> Bool {
    UInt i = 1;
    for (; i < (p - 1) / 2 - 1; ++i)
        if (mod_pow_bin(a, i, p) == p - 1)
            return false;
    ++i;
    return mod_pow_bin(a, i, p) == p - 1;
}

fn inline mod_mul(I64 a, I64 b, I64 m) noexcept -> I64 {
    return ((a % m) * (b % m)) % m;
}

fn mod_pow(I64 base, I64 exp, I64 m) noexcept -> I64 {
    var ret = 0;
    if (m != 1) {
        ret = 1;
        for (I64 e = 0; e < exp; ++e)
            ret = (base * ret) % m;
    }
    return ret;
}

fn mod_pow_bin(I64 base, I64 exp, I64 m) noexcept -> I64 {
    var ret = 0;
    if (m != 1)
        for (ret = 1; exp != 0; exp >>= 1) {
            if (exp & 1)
                ret = (ret * base) % m;
            base = (base * base) % m;
        }

    return ret;
}

fn primitive_roots(UInt p) noexcept -> Vec<UInt> {
    Vec<UInt> out;
    out.reserve(Size(p));
    for (var i : vi::iota(1, Int(p))) {
        if (is_primitive_root(p, i))
            out.push_back(i);
    }
    return out;
}

fn seq(UInt p, UInt a) noexcept -> Vec<UInt> {
    Vec<UInt> out;
    out.reserve(Size(p));
    for (UInt i = 1, e = a; e != 1; ++i) {
        e = mod_pow_bin(a, i, p);
        out.push_back(e);
    }
    return out;
}

// 1, 2, 4, 3
// .
//    .
//          .
//       .

fn lempel(UInt p) noexcept -> Vec<Vec<Char>> {
    var ret = Vec<Vec<Char>>(p, Vec<Char>(p - 1, ' '));
    let v = seq(p, primitive_roots(p).front());
    for (var idx = 0; var e : v)
        ret[e - 1][idx++] = '.';
    ra::reverse(ret);
    return ret;
}

fn is_permutation_matrix(Vec<UInt> a) noexcept -> Bool {
    let h = [&](Size stride) {
        std::unordered_set<UInt> u;
        var size = 0;
        for (let& e : a | vi::stride(stride) | vi::slide(2))
            u.insert(e[0] - e[1]), ++size;
        // std::cout << std::format("({}, {})", u.size(), size) << std::endl;
        return u.size() == size;
    };
    Vec<Size> arr(a.size());
    ra::iota(arr, 1);
    for (let i : arr)
        if (not h(i))
            return false;

    return true;
}
