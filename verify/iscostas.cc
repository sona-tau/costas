#include <cstdint>
#include <iostream>
#include <unordered_set>
#include <vector>

// TODO: documentation

bool iscostas(const std::vector<int>& perm) {
    int n = perm.size();
    std::unordered_set<int> uniq(perm.begin(), perm.end());
    if ((int)uniq.size() != n) return false;
    for (int k = 1; k < n; k++) {
        uint64_t seen = 0;
        for (int i = 0; i < n - k; i++) {
            int d = perm[i + k] - perm[i] + n;
            uint64_t bit = uint64_t(1) << d;
            if (seen & bit) return false;
            seen |= bit;
        }
    }
    return true;
}

int main() {
    int n;
    std::cin >> n;
    std::vector<int> perm(n);
    for (int& x : perm) std::cin >> x;
    std::cout << (iscostas(perm) ? 1 : 0) << "\n";
}
