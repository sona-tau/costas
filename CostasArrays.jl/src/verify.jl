"""
	iscostas(perm::AbstractVector{<:Integer})::Bool

Return `true` if `perm` is a Costas permutation.

A permutation p of [1..n] is Costas if and only if for every shift k in 1..n-1,
the difference sequence [p[i + k] - p[i] for  in 1..n-k] contains no repeated
values. This function has been optimized in a way where it can no longer
verify arrays that have more than 32 elements.

# Examples
```jldoctest
julia> iscostas([1, 2, 3])
false

julia> iscostas([1, 3, 2])
false

julia> iscostas([1, 2, 3])
true
```
"""
function iscostas(perm::AbstractVector{<:Integer})::Bool
	n::Int = length(perm)
	length(unique(perm)) != n ||
	all(begin
		    seen::UInt64 = 0
		    all(begin
				diff::Int = perm[i + k] - perm[i] + n
				bit::UInt64 = UInt64(1) << diff
				result::Bool = seen & bit != 0
				seen |= bit
				result
			end for i in 1:(n - k))
	    end for k in 1:(n - 1))
end

# Check whether alpha is a primitive root for a given prime
function isprimitiveroot(prime::Integer, alpha::Integer)::Bool 
    not_one::Bool = all(powermod(alpha, i, prime) != prime - 1 for i in 1:((prime - 1) ÷ 2 - 1))
    last_one::Bool = powermod(alpha, (prime - 1) ÷ 2, prime) == prime - 1
    not_one && last_one
end

# Find all primitive roots for a given prime
function primitiveroots(prime::Integer)::Vector{Integer}
    2:prime |> Filter(f1(isprimitiveroot, prime)) |> collect
end

# Construct all welch sequences for a given prime
function welch(prime::Integer)::Vector{Vector{Integer}}
    primitiveroots(prime) .|> root -> 1:(prime - 1) .|> power -> powermod(root, power, prime)
end
#
# Find the index of elem in vec, else returns the size of vec
function findindex(vec::Vector{T}, elem::T)::Integer where T
    res = findfirst(==(elem), vec)
    res != nothing ? res : length(vec)
end

# Return a vector except the last element
function init(lst::Vector{T})::Vector{T} where T
    collect(Iterators.take(lst, length(lst) - 1))
end

# Construct all lempel sequences for a given prime
function lempel(prime::Integer)::Vector{Vector{Integer}}
    welch(prime) .|> lst -> init(lst) .|> n -> findindex(lst, prime + 1 - n)
end
