#include "lib.hpp"
#include "prelude.hpp"
#include <cmath>
#include <iomanip>
#include <iostream>
#include <unordered_set>

fn is_permutation_matrix(Vec<UInt> a) noexcept -> Bool {
    let h = [&](Size stride) {
        // NOTE: std::unordered_set cannot be constexpr, therefore this
        // function is not constexpr.
        std::unordered_set<UInt> u;
        var size = 0;
        for (let& e : a | vi::stride(stride) | vi::slide(2))
            u.insert(e[0] - e[1]), ++size;
        return u.size() == size;
    };
    Vec<Size> arr(a.size());
    ra::iota(arr, 1);
    for (let i : arr)
        if (not h(i))
            return false;

    return true;
}
