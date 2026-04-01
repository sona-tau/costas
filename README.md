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
