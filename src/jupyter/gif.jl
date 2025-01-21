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

loadvar(file_path::String) = Serialization.deserialize(file_path)

costas_10x10 = loadvar("costas_10x10.dat")
costas_5x5 = loadvar("costas_5x5.dat")

size = 5
lists = costas_5x5
last = lists[1][1:size - 3]
inputs = []
arr = []
for l in lists
    if last != l[1:size - 3]
        push!(inputs, arr)
        global last = l[1:size - 3]
        global arr = []
    end
    push!(arr, (l[size - 2], l[size - 1], l[size]))
end

println("inputs has $(length(inputs)) many elements")
println(inputs)

kw = (proj_type = :ortho, legend = false, aspect_ratio = :equal, xlimits = (0,10), ylimits = (0,10), zlimits = (0,10))
limit = length(inputs)
colors = palette([:orange, :blue], limit + 2)

@gif for i in 0:360
    idx = 1
    for pts in inputs
        x = pts .|> a -> a[1]
        y = pts .|> a -> a[2]
        z = pts .|> a -> a[3]
        idx += 1
        println((x, y, z))
        scatter!(x, y, z; markercolor = colors[idx], camera = (i, round(atand(1 / √2); digits = 3)), kw...)
    end
end
