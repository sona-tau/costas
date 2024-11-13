import Pkg
Pkg.add("BenchmarkTools")
Pkg.add("Transducers")
Pkg.add("Combinatorics")
using BenchmarkTools
using Transducers
using Combinatorics
include("header.jl")
1:10 |> permutations |> Filter(iscostas) |> tcollect
1:10 |> permutations |> Filter(iscostasdbg) |> tcollect

println(@benchmark 1:10 |> permutations |> Filter(iscostas) |> tcollect)
println(@benchmark 1:10 |> permutations |> Filter(iscostasdbg) |> tcollect)
