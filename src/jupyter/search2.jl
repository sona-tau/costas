include("header.jl")
import Pkg
import Serialization
using Serialization
Pkg.add("Combinatorics")
Pkg.add("Primes")
Pkg.add("BenchmarkTools")
Pkg.add("Transducers")
using Combinatorics
using Primes
using BenchmarkTools
using Transducers

struct Unit
end

# Check if a sequence is a Costas sequence with debug information
function iscostas(lst::Vector{Int})::Union{Unit, Tuple{Tuple{Int, Int}, Tuple{Int, Int}}}
	n::Int = length(lst)
	for k in 1:n
		diffs::Vector{Tuple{Bool, Tuple{Int, Int}}} = [(false, (-1,-1)) for _ in 1:2 * n]
		for i in 1:(n - k)
			result::Int = lst[i + k] - lst[i] + n
			if diffs[result][1]
				return ((i, i + k), diffs[result][2])
			elseif result != n
				diffs[result] = (true, (i, i + k))
			end
		end
	end
	return Unit()
end

using Base.Threads
function searchallt(n::Int)::Vector{Vector{Int}}
	p1::Int = 0
	p2::Int = 0
	p3::Int = 0
	p4::Int = 0
	i1::Int = 0
	i2::Int = 0
	i3::Int = 0
	i4::Int = 0
	acc::Vector{Vector{Vector{Int}}} = [[] for _ in 1:nthreads()]

	@threads :static for i in 1:factorial(n)
		tid::Int = threadid()
		lst::Vector{Int} = nthperm(1:n, i)
		if (i1 != 0 && p1 == lst[i1]) && (i2 != 0 && p2 == lst[i2]) && (i3 != 0 && p3 == lst[i3]) && (i4 != 0 && p4 == lst[i4])
			continue
		end
		result::Union{Unit, Tuple{Tuple{Int, Int}, Tuple{Int, Int}}} = iscostas(lst)
		if result isa Unit
			push!(acc[tid], lst)
		else
			(i1, i2), (i3, i4) = result
			p1, p2, p3, p4 = lst[i1], lst[i2], lst[i3], lst[i4]
		end
	end
	reduce(vcat, acc)
end

function searchall(n::Int64)::Vector{Vector{Int64}}
	p1::Int64 = 0
	p2::Int64 = 0
	p3::Int64 = 0
	p4::Int64 = 0
	i1::Int64 = 0
	i2::Int64 = 0
	i3::Int64 = 0
	i4::Int64 = 0
	acc::Vector{Vector{Int64}} = []

	for i in 1:factorial(n)
		lst::Vector{Int64} = nthperm(1:n, i)
		if (i1 != 0 && p1 == lst[i1]) && (i2 != 0 && p2 == lst[i2]) && (i3 != 0 && p3 == lst[i3]) && (i4 != 0 && p4 == lst[i4])
			continue
		end
		result = iscostas(lst)
		if result isa Unit
			push!(acc, lst)
		else
			(i1, i2), (i3, i4) = result
			p1, p2, p3, p4 = lst[i1], lst[i2], lst[i3], lst[i4]
		end
	end
	acc
end

function searchonet(n::Integer)::Union{Nothing, Vector{Integer}}
	p1 = 0
	p2 = 0
	p3 = 0
	p4 = 0
	i1 = 0
	i2 = 0
	i3 = 0
	i4 = 0

	@threads for i in 1:factorial(n)
		lst = nthperm(1:n, i)
		if (i1 != 0 && p1 == lst[i1]) && (i2 != 0 && p2 == lst[i2]) && (i3 != 0 && p3 == lst[i3]) && (i4 != 0 && p4 == lst[i4])
			continue
		end
		result = iscostasdbg(lst)
		if result isa Unit
			return lst
		else
			(i1, i2), (i3, i4) = result
			p1, p2, p3, p4 = lst[i1], lst[i2], lst[i3], lst[i4]
		end
	end
	return nothing
end

function searchone(n::Integer)::Union{Nothing, Vector{Integer}}
	p1 = 0
	p2 = 0
	p3 = 0
	p4 = 0
	i1 = 0
	i2 = 0
	i3 = 0
	i4 = 0

	for i in 1:factorial(n)
		lst = nthperm(1:n, i)
		if (i1 != 0 && p1 == lst[i1]) && (i2 != 0 && p2 == lst[i2]) && (i3 != 0 && p3 == lst[i3]) && (i4 != 0 && p4 == lst[i4])
			continue
		end
		result = iscostasdbg(lst)
		if result isa Unit
			return lst
		else
			(i1, i2), (i3, i4) = result
			p1, p2, p3, p4 = lst[i1], lst[i2], lst[i3], lst[i4]
		end
	end
	return nothing
end

# const START = 10
# const LIMIT = 20
# 
# for n in (START + 1):LIMIT
#	 out = searchdbg(n)
#	 file_path = "costas_$(n)x$n.dat"
#	 serialize(file_path, out)
#	 println("$file_path has $(length(out)) arrays.")
# end
# 
