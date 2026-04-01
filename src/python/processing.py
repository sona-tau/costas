dict = {
        "costas_10x10.txt": 447324,
        "costas_11x11.txt": 6251040,
        "costas_12x12.txt": 29823168,
        "costas_2x2.txt": 1,
        "costas_3x3.txt": 4,
        "costas_4x4.txt": 8,
        "costas_5x5.txt": 56,
        "costas_6x6.txt": 244,
        "costas_7x7.txt": 2136,
        "costas_8x8.txt": 7924,
        "costas_9x9.txt": 89520 }

for x in dict:
    print(x, ":", dict[x] % 4)
