using Transducers
import Serialization

include("../../notebooks/shared/header.jl")
include("../../CostasArrays.jl/src/io.jl")
include("../../CostasArrays.jl/src/search.jl")
include("../../CostasArrays.jl/src/symmetry.jl")
include("../../CostasArrays.jl/src/verify.jl")

function savetofile(fpath::String, c::Vector{Vector{Integer}})
	text = totxt(c)
	open(fpath, "w") do file
		write(file, text)
	end
end

function orbitsofn(n::Int)::Vector{Vector{Int}}
	orbits = tsearchbt(n) |> classes
end

function genall(c::AbstractVector{AbstractVector{<:Integer}})::Vector{Vector{Int}}
	foldxt(vcat, c .|> unique ∘ d4orbit) |> sort
end

function generate(n::Int)
	println("generating ", n, " by ", n, " Costas arrays")
	orbits::Vector{Vector{Integer}} = tsearchbt(n) |> classes
	println("generated ", length(orbits), " orbits")
	all::Vector{Vector{Integer}} = foldxt(vcat, orbits .|> unique ∘ d4orbit) |> sort
	println("generated ", length(all), " Costas arrays")
	savetofile("../../data/orbits_$(n)x$(n).txt", orbits)
	savetofile("../../data/costas_$(n)x$(n).txt", all)
	nothing
end

generate(10)
