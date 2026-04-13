#include <stdio.h>
#include <string.h>

// TODO: documentation

int iscostas(int *perm, int n) {
    int seen[n + 1];
    memset(seen, 0, sizeof(seen));
    for (int i = 0; i < n; i++) {
        if (perm[i] < 1 || perm[i] > n || seen[perm[i]]) return 0;
        seen[perm[i]] = 1;
    }
    for (int k = 1; k < n; k++) {
        long long used = 0;
        for (int i = 0; i < n - k; i++) {
            int d = perm[i + k] - perm[i] + n;
            long long bit = 1LL << d;
            if (used & bit) return 0;
            used |= bit;
        }
    }
    return 1;
}

int main(void) {
    int n;
    (void)scanf("%d", &n);
    int perm[n];
    for (size_t i = 0; i < n; ++i) (void)scanf("%d", &perm[i]);
    printf("%d\n", iscostas(perm, n));
    return 0;
}
