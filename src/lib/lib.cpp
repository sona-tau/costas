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

fn is_costas(Vec<UInt> const& vec) -> Bool {
    using Set = std::unordered_set<UInt>;

    if (Set(vec.cbegin(), vec.cend()).size() != vec.size())
        return false;

    bool flag = false;
    auto const l = vec.size() / 2 + 2;
#pragma omp parallel for num_threads(16) shared(flag)
    for (Size h = 1; h < l; ++h) {
        if (flag)
            continue;
        var set = Set(l - h);
        for (Size i = h - 1; i < l - 1; ++i) {
            let result = vec[(h + i) % l] - vec[i];
            if (set.contains(result)) {
#pragma omp atomic write
                flag = true;
                break;
            }
            set.insert(vec[(h + i) % l] - vec[i]);
        }
    }
    return !flag;
}

fn costas_nxn(Vec<UInt> v) -> Vec<Vec<UInt>> {
    // auto const max_size = factorial[v.size() + 4];
    auto out = Vec<Vec<UInt>>();
    // out.reserve(factorial[v.size() + 1]);
    ra::sort(v);

    do {
        // print(v);
        if (is_costas((const Vec<UInt>)v)) {
            out.push_back(v);
        }
    } while (std::next_permutation(v.begin(), v.end()));

    return out;
}

void print(Vec<UInt> const& v) {
    for (var x : v)
        std::cout << x << ' ';
    std::cout << std::endl;
}
