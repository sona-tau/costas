import Transducers

"""
	v(perm::AbstractVector{<:Integer})::Vector{Int}

Vertical reflection of a Costas array.
"""
function v(l::AbstractVector{<:Integer})::Vector{Int}
	length(l) + 1 .- 1
end

"""
	t(perm::AbstractVector{<:Integer})::Vector{Int}

Transpose of a Costas array, equivalent to taking the inverse permutation.
"""
function t(perm::AbstractVector{<:Integer})::Vector{Int}
	invperm(perm)
end

"""
	r(perm::AbstractVector{<:Integer})::Vector{Int}

90-degree rotation of a Costas array. Equivalent to taking the transpose and
then a reflection.
"""
function r(perm::AbstractVector{<:Integer})::Vector{Int}
	perm |> t |> v
end

"""
	d4orbit(perm::AbstractVector{<:Integer})::Vector{Vector{Int}}

Return all 8 images of `perm` under the dihedral group D4 acting on the set of
permutation matrices.
"""
function d4orbit(perm::AbstractVector{<:Integer})::Vector{Vector{Int}}
	n::Int = length(perm)
	[[(a[1], a[2]), (n + 1 - a[2], a[1]), (n + 1 - a[1], n + 1 - a[2]), (a[2], n + 1 - a[1]), (a[1], n + 1 - a[2]), (n + 1 - a[1], a[2]), (a[2], a[1]), (n + 1 - a[2], n + 1 - a[1])] for a in topoints(perm)] |>
		Base.Fix1(reduce, hcat) |>
		eachrow .|>
		Base.Fix2(frompoints, n) |>
		collect
end

"""
	canon(perm::AbstractVector{<:Integer})::Vector{Int}

Return the canonical representative of the D4 equivalence class of `perm`,
in this case, the lexicographically smallest element of the orbit.
"""
function canon(perm::AbstractVector{<:Integer})::Vector{Int}
	n::Int = length(perm)
	[[(a[1], a[2]), (n + 1 - a[2], a[1]), (n + 1 - a[1], n + 1 - a[2]), (a[2], n + 1 - a[1]), (a[1], n + 1 - a[2]), (n + 1 - a[1], a[2]), (a[2], a[1]), (n + 1 - a[2], n + 1 - a[1])] for a in topoints(p)] |>
		Base.Fix1(reduce, hcat) |>
		eachrow |>
		minimum |>
		Base.Fix2(frompoints, n) |>
		collect
end

"""
	isstabilized(perm::AbstractVector{<:Integer})::Bool

Return `true` if `perm` gets fixed by at least one non-identity element of the
D4 action.
"""
function isstabilized(perm::AbstractVector{<:Integer})::Bool
	orbit::Vector{Vector{Int}} = d4orbit(perm)
	any(==(collect(perm)), orbit[2:end])
end

"""
	isequiv(e::AbstractVector{<:Integer}, a::AbstractVector{<:Integer})::Bool

Return `true` if both permutations are in the same orbit.
"""
function isequiv(e::AbstractVector{<:Integer}, a::AbstractVector{<:Integer})::Bool
    canon(e) == canon(a)
end

"""
	classes(c::AbstractVector{AbstractVector{<:Integer}})::Vector{Vector{Integer}}

Collapse `c` into a vector corresponding only of the equivalence classes that
make up `c`.
"""
function classes(c::AbstractVector{AbstractVector{<:Integer}})::Vector{Vector{Integer}}
	cls::Vector{Vector{Int}} = []
	for l::Vector{Int} in c
		if all(canon(l) != class for class in cls)
			push!(cls, canon(l))
		end
	end
	cls
end

function stabilizers(c)
	c |> Filter(isstabilized) |> collect
end

"""
	topoints(l::vector{<:Integer})::Vector{Tuple{Int, Int}}

Return the same permutation represented as a list of coordinates where the dots
would be.
"""
function topoints(l::AbstractVector{<:Integer})::Vector{Tuple{Int, Int}}
    l |> enumerate |> Filter(a -> a[2] != 0) |> collect
end

"""
	frompoints(ts::AbstractVector{<:Tuple{<:Integer, <:Integer}}, n::Integer)::Vector{Int}

Return the permutation that the list of coordinates represents.
"""
function frompoints(ts::AbstractVector{<:Tuple{<:Integer,<:Integer}}, n::Integer)::Vector{Int}
    ret::Vector{Int} = zeros(n)
    @inbounds for (x, y) in ts
        ret[x] = y
    end
    ret
end
