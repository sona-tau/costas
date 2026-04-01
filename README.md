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
