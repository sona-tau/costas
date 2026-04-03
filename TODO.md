# Infra

- [ ] ask Sergio and Gustavo for author credits in `README.md`
- [ ] upload counts to zenodo?
- [x] add `CITATION.cff`
    - more info: https://citation-file-format.github.io/
- [x] add `CHANGELOG.md`
    - this file documents how the data looks and what changes are made

# Data

- [ ] compute arrays for orders 15 to 20 from orbits
- [ ] submit counts for orders 15 to 20 to OEIS
    - more info: https://oeis.org/A008404
- [ ] bug: `data/costas_1x2.txt` is empty
    - [ ] remove it from `data/`
    - [ ] regenerate `SHA256SUMS`
    - [ ] make a new release
- [ ] rename `classes_NxN.txt` to `orbits_NxN.txt`
- [ ] add `src/julia/generate.jl`
    - this file generates all the data
- [ ] add `data/counts.csv`
- [ ] add `data/README.md`
    - this file explains the file format, naming conventions, how to verify and the remaining orders to be computed
- [ ] add `data/labels.csv`
    - [ ] verify that labels are mutually exclusive, if not, then the shape of the file has to have 1 column per label and a boolean flag marking whether that array meets the criteria
    - a CSV with a column for an array and a column for a label
        - `L`: produced by the Lempel construction
        - `G`: produced by the Lempel-Golomb construction
        - `W`: produced by the Welch construction
        - `l`: in the orbit of an array that was produced by the Lempel construction
        - `g`: in the orbit of an array that was produced by the Lempel-Golomb construction
        - `w`: in the orbit of an array that was produced by the Welch construction
        - `V`: a shift of an array that was produced by the Welch construction
        - `v`: a shift of an array that is in the orbit of another array that was produced by the Welch construction
        - `s`: a sporadic array (none of the above)
- [ ] do other group actions produce meaningful orbits?

# Algorithms

- [ ] add `BenchmarkTools.jl` benchmark suite in `benchmarks/`
- [ ] add `notebooks/julia/profiling.ipynb`

# CostasArrays.jl package

- [ ] write `test/runtests.jl` with known Costas arrays
- [ ] finish docstrings

# verify/

- add `verify/README.md`
    - each file has the implementation that checks whether an array is a Costas array.
    - each file, when executed, will read a number `N` the order and then `N` positive integers and output `1` or `0` depending on if the list of positive integers was a Costas array or not repectively.
- [ ] Write `is_costas.ext` for:
    - [ ] Python
    - [ ] C
    - [ ] Haskell
    - [ ] Julia
    - [ ] Sage
    - [ ] Rust
    - [ ] C++
    - [ ] R
    - [ ] APL
    - [ ] J
    - [ ] BQN
    - [ ] Javascript
    - [ ] Go
    - [ ] Fortran
    - [ ] Clojure
    - [ ] Octave (covers MATLAB)
- [ ] add `verify/test.sh`
    - this file tests each implementation against all of the data to see if they agree

# Future

## GPU

- [ ] parallelize with a GPU
    - [ ] check ROCm compatibility with `rocminfo`
    - [ ] confirm that my exact GPU models are ROCm-supported
    - [ ] add ROCm packages to `flake.nix`
    - [ ] prototype GPU kernel using `KernelAbstractions.jl`
