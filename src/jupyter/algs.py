def permutations(iterable, r=None):
    # permutations('ABCD', 2) → AB AC AD BA BC BD CA CB CD DA DB DC
    # permutations(range(3)) → 012 021 102 120 201 210

    pool = tuple(iterable)
    n = len(pool)
    r = n if r is None else r
    if r > n:
        return

    indices = list(range(n))
    cycles = list(range(n, n-r, -1))
    yield tuple(pool[i] for i in indices[:r])

    while n:
        for i in reversed(range(r)):
            cycles[i] -= 1
            if cycles[i] == 0:
                indices[i:] = indices[i+1:] + indices[i:i+1]
                cycles[i] = n - i
            else:
                j = cycles[i]
                indices[i], indices[-j] = indices[-j], indices[i]
                yield tuple(pool[i] for i in indices[:r])
                break
        else:
            return

def is_costas(lst: list[int]) -> bool:
    if len(set(lst)) != len(lst):
        return False
    n = len(lst)
    flag = False
    for k in range(1, n):
        diffs = [False] * (2 * n)
        if flag:
            continue
        for i in range(0, n - k):
            a = lst[(i + k) % n]
            b = lst[i]
            result = a - b + n
            if diffs[result]:
                return False
            else:
                diffs[result] = True
            flag = diffs[result]
    return flag

def costas_nxn(i: int) -> list[tuple[list[int], bool]]:
    return list(filter(lambda x: x[1], [(lst, is_costas(lst)) for lst in permutations(range(1, i + 1))]))

def build_all_naive(lst: list[int], x: int) -> list[int]:
    out = []
    for i in range(len(lst) + 1):
        lst2 = list(lst).copy()
        lst2.insert(i, x)
        if is_costas(lst2):
            out.append(lst2)
    return out

# prev = set([(1,2), (2,1)])
# counts2 = []
# for i in range(2, 11):
#     print(i, len(prev))
#     counts2.append(prev)
#     nxt = [build_all_naive(lst, i + 1) for lst in prev]
#     prev = set()
#     for lsts in nxt:
#         for lst in lsts:
#             prev.add(tuple(lst))
