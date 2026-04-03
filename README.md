# Costas Permutation Matrices

A database of Costas arrays and related combinatorial data, with tools for
computing and classifying them.

## What is a Costas array?

Take an $n \times n$ grid. Place $n$ dots so that:
- every row has exactly one dot, and
- every column has exactly one dot.

This is just a permutation matrix. Now add one more rule: if you look at every
pair of dots and measure how far apart they are (both horizontally and
vertically), all those distance vectors must be distinct.

That extra rule makes it a **Costas array**. They are rare. For $n = 1$ through
$n = 5$ you can find them by hand. By $n = 16$ there are $21,104$ of them, and
finding them all requires serious computation. Beyond $n = 29$, we do not know
how many exist . . .

Costas arrays were originally studied for use in sonar and radar, where their
distance property translates to an ideal ambiguity function. They are also
interesting as pure combinatorial objects.

## What is in this repo?

### Data (`data/`)

Plain text files, one array per line, space-separated integers. Each line is a
permutation of $1, 2, \dots, n$ that satisfies the Costas property.

```txt
1 2 4 8 5 10 9 7 3 6
1 2 5 7 3 10 9 6 4 8
```

There is not a newline at the end of the file. This makes it easier to parse:
1. open the file as a really long string
2. split the string on newlines
3. split each string on spaces
4. parse each string as an integer

In there, you will find ASCII text files:
- `costas_NxN.txt` all Costas arrays of order N
- `classes_NxN.txt` all equivalence classes under the dihedral group D4[1]
- `stabilizers_NxN.txt` arrays that get fixed by at least one non-identity
element of D4

- [1]: the equivalence classes are a single array, in this case, the array with
the smallest lexicographic value

### Non-square arrays

This might be a bit strange since Costas arrays of order N have to have N
points. In this case, this is a list very similar to the previous, but without
the entry: $1$. Because of this, the files are labeled `costas_(N-1)xN.txt`.


### Source (`src/`)

- `src/cpp` has a C++ implementation for the search and Costas property[2]
- `src/julia` has a Julia implementation for the search and also utilities for
classification
- `src/python` helpful tools for dealing with files[2]

- [2]: these files are somewhat old and most of the project deals with Julia
now.

### Jupyter Notebooks (`notebooks/`)

The Jupyter notebooks in this project are used for general research and to
play around with the data. No polished documents as of yet - 2026-04-01.

## Data

Simply split on each line and then split on spaces. For example, in Julia you
would do something like:

```julia
parseint = Base.Fix1(parse, int)

costas_10x10 = map.(parseint, split.(eachline("data/costas_10x10.txt")))
```

## Verify the data

```bash
sha256sum --check SHA256SUMS
```

## Building

```bash
nix develop # This pulls in all the data
make        # This builds the C++ search engine
```

## Counts

| Order | Costas arrays | D4 orbits |
|:---:|:---:|:---:|
| 1 | 1 | 1 |
| 2 | 2 | 1 |
| 3 | 4 | 1 |
| 4 | 12 | 2 |
| 5 | 40 | 6 |
| 6 | 116 | 17 |
| 7 | 200 | 30 |
| 8 | 444 | 60 |
| 9 | 760 | 100 |
| 10 | 2160 | 277 |
| 11 | 4367 | 555 |
| 12 | 7852 | 990 |
| 13 | 12828 | 1616 |
| 14 | 17252 | 2168 |
| 15 |       | 2467 |
| 16 |       | 2648 |
| 17 |       | 2294 |
| 18 |       | 1892 |
| 19 |       | 1283 |
| 20 |       | 810 |

# Credits

This work has been done in collaboration with:
- Gustavo Torres Hance @gustavbit
- Sergio Rodríguez de Jesús @sergiodrd
