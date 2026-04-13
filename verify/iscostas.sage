import sys

# TODO: documentation

n = int(input())
perm = list(map(int, input().split()))


def iscostas(perm):
    n = len(perm)
    if len(set(perm)) != n:
        return False
    for k in range(1, n):
        seen = set()
        for i in range(n - k):
            d = perm[i + k] - perm[i]
            if d in seen:
                return False
            seen.add(d)
    return True


print(1 if iscostas(perm) else 0)
