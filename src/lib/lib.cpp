#include "lib.hpp"
#include "prelude.hpp"
#include <cmath>
#include <format>

using namespace std;
/*
function unseq(lst::Vector{<:Integer})::Vector{Integer}
    acc = []
    for (idx, elem) ∈ enumerate(lst)
        l, r = splitat(acc, elem)
        acc = [l;[idx];r]
    end
    acc
end
*/
fn from_indices(Vec<U8> lst) -> Vec<U8> {
    cout << format("lst: ");
    for (let e : lst) cout << e << ' ';
    cout << endl;
    Vec<U8> acc;
    for (let [idx, elem] : std::views::enumerate(lst)) {
        var left = Vec<U64>(acc.begin(), acc.begin() + elem);
        cout << format("left: ");
        for (let e : left) cout << e << ' ';
        cout << endl;
        let right = Vec<U64>(acc.begin() + elem, acc.end());
        cout << format("right: ");
        for (let e : right) cout << e << ' ';
        cout << endl;
        left.push_back(idx);
        left.insert(left.end(), right.begin(), right.end());
        cout << "both: ";
        for (let e : left) cout << e << ' ';
        cout << endl;
    }
    return acc;
}
