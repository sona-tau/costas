import Pkg
Pkg.add("BenchmarkTools")
Pkg.add("Transducers")
Pkg.add("Combinatorics")
using BenchmarkTools
using Transducers
using Combinatorics
include("header.jl")
include("search2.jl")
searchallt(5)

println(@benchmark searchallt(10))
