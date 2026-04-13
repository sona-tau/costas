include("../../CostasArrays.jl/src/io.jl")
include("../../CostasArrays.jl/src/search.jl")
include("../../CostasArrays.jl/src/symmetry.jl")
include("../../CostasArrays.jl/src/verify.jl")

# Combinators
f1 = Base.Fix1
f2 = Base.Fix2

# --- Functions ---

import Serialization

savevar(file_path::String, a) = Serialization.serialize(file_path, a)
loadvar(file_path::String) = Serialization.deserialize(file_path)

function windows(z, w)
    ((@view z[i:i + w - 1]) for i in 1:length(z) - w + 1)
end

function stabilizers(c)
    sls = []
    for l in c
         if isstab(l)
            push!(sls, l)
        end
    end
    sls
end

function iscircperiodic(v::Vector{T})::Bool where T
    mod = length(v)
    v = vcat(v, v)
    all(begin
            seen::Vector{Bool} = zeros(Bool, 2 * mod + 1)
            all(begin
                    if x == '*' || y == '*'
                        true
                    else
                        result = (x - y + mod) % mod
                        # println("x - y % mod = $x - $y % $mod = $result")
                        prev = seen[result + 1]
                        seen[result + 1] = true
                        !prev
                    end
                end for (x, y) in windows(v, ws))
        end for ws in 2:(mod - 1))
end

function children(current::Vector{<:Integer})::Vector{Vector{Integer}}
    acc =  []
    for i in 0:length(current)
        tmp = copy(current)
        push!(tmp, i)
        if iscostas(unseq(tmp))
            push!(acc, tmp)
        end
    end
    acc
end

function seq(lst::Vector{<:Integer})::Vector{Integer}
    acc = []
    for i ∈ 1:length(lst)
        counter = 0
        for el ∈ lst
            if el < i
                counter += 1
            elseif el == i
                break
            end
        end
        push!(acc, counter)
    end
    acc
end

function unseq(lst::Vector{<:Integer})::Vector{Integer}
    acc = []
    for (idx, elem) ∈ enumerate(lst)
        l, r = splitat(acc, elem)
        acc = [l;[idx];r]
    end
    acc
end

function splitat(v::Vector{T}, i::Integer)::Tuple{Vector{T}, Vector{T}} where T
    (v |> Take(i), v |> Drop(i)) .|> collect
end

function dfs(current::Vector{<:Integer})::Vector{Integer}
    longest = copy(current)
    while length(current) != 0
        if iscostas(unseq(current))
            if length(current) > length(longest)
                longest = copy(current)
            end
            push!(current, 0)
        else
            while length(current) > 0 && last(current) + 1 >= length(current)
                pop!(current)
            end
            if length(current) == 0
                break
            end
            current[length(current)] = last(current) + 1
        end
    end
    longest
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

function searchnaive(n::Integer)::Vector{Vector{Integer}}
    1:n |> permutations |> Filter(iscostas) |> collect
end