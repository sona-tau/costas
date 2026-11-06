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
	length(unique(perm)) == n &&
	all(begin
		    seen::UInt64 = 0
		    all(begin
				diff::Int = perm[i + k] - perm[i] + n
				bit::UInt64 = UInt64(1) << diff
				result::Bool = seen & bit == 0
				seen |= bit
				result
			end for i in 1:(n - k))
	    end for k in 1:(n - 1))
end

