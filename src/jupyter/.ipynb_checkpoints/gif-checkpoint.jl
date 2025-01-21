import Pkg
import Serialization
Pkg.add("Combinatorics")
Pkg.add("Primes")
Pkg.add("BenchmarkTools")
Pkg.add("Transducers")
Pkg.add("Plots")
using Combinatorics
using Primes
using BenchmarkTools
using Transducers
using Plots

include("header.jl")

import Base.Iterators

savevar(file_path::String, a) = Serialization.serialize(file_path, a)
loadvar(file_path::String) = Serialization.deserialize(file_path)

for n in 1:10
    # out = 1:n |> permutations |> Filter(iscostas) |> tcollect
    file_path = "costas_$(n)x$(n).dat"
    out = loadvar(file_path)
    #savevar(file_path, out)
    println("$(file_path) has $(length(out)) arrays.")
end

costas_1x1 = loadvar("costas_1x1.dat")
costas_2x2 = loadvar("costas_2x2.dat")
costas_3x3 = loadvar("costas_3x3.dat")
costas_4x4 = loadvar("costas_4x4.dat")
costas_5x5 = loadvar("costas_5x5.dat")
costas_6x6 = loadvar("costas_6x6.dat")
costas_7x7 = loadvar("costas_7x7.dat")
costas_8x8 = loadvar("costas_8x8.dat")
costas_9x9 = loadvar("costas_9x9.dat")
costas_10x10 = loadvar("costas_10x10.dat")
costas_11x11 = loadvar("costas_11x11.dat")
println("costas_11x11 has $(length(costas_11x11)) arrays.")
costas_12x12 = loadvar("costas_12x12.dat")
println("costas_12x12 has $(length(costas_12x12)) arrays.")
costas_13x13 = loadvar("costas_13x13.dat")
println("costas_13x13 has $(length(costas_13x13)) arrays.")

ize = 10
last = costas_10x10[1][1:size - 3]
inputs = []
arr = []
for l in costas_13x13
    if last != l[1:size - 3]
        push!(inputs, arr)
        last = l[1:size - 3]
        arr = []
    end
    push!(arr, (l[size - 2], l[size - 1], l[size]))
end
println(length(inputs))
inputs

