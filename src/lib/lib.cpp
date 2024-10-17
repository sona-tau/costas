#include "lib.hpp"
#include "prelude.hpp"
#include <cmath>
#include <iomanip>
#include <iostream>
#include <optional>
#include <unordered_set>

using MI64 = std::optional<I64>;
using MInt = std::optional<Int>;
using MUInt = std::optional<UInt>;

/*
 * Complexity: O(n^2)
 */
template <class T> fn is_permutation_matrix(Vec<T> a) noexcept -> Bool {
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

/*
 * Complexity: O(n^2)
 */
template <class T> fn is_costas(Vec<T> const& vec) -> Bool {
    using Set = std::unordered_set<T>;

    if (Set(vec.cbegin(), vec.cend()).size() != vec.size())
        return false;

    let n = vec.size();
    var flag = false;
    for (Size k = 1; k < n; ++k) {
        if (flag)
            break;
        var seen = Vec<Bool>(2 * n, false);
        for (Size i = 0; i < n - k; ++i) {
            let result = Int(vec[(i + k) % n]) - Int(vec[i]) + Int(n);
            if (not seen[result]) {
                flag = true;
                break;
            }
        }
    }
    return flag;
}

/*
 * Complexity: O((n^2)!)
 */
template <class T> fn costas_nxn(Vec<T> v) -> Vec<Vec<T>> {
    auto out = Vec<Vec<T>>();
    ra::sort(v);

    do {
        if (is_costas<T>((const Vec<T>)v))
            out.push_back(v);
    } while (std::next_permutation(v.begin(), v.end()));

    return out;
}

/*
 * Complexity: O(n^3)
 */
template <class T> fn build_all_naive(Vec<T> const& vec, T x) -> Vec<Vec<T>> {
    var out = Vec<Vec<T>>();
    for (Size i = 0; i < vec.size(); ++i) {
        var lst2 = vec;
        lst2.insert(lst2.begin() + i, x);
        if (is_costas(lst2))
            out.push_back(lst2);
    }
    return out;
}

/*
 * Complexity: O(n)
 */
template <class T> void print(Vec<T> const& v) {
    for (var x : v)
        std::cout << x << ' ';
    std::cout << std::endl;
}
