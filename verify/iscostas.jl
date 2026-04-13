# TODO: documentation


# Parsing the input
pint = Base.Fix1(parse, Int)

n = parse(Int, readline())
c = parse.(Int, split(readline(), " "))

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

println(iscostas(c) ? 1 : 0)
