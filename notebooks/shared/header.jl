import Serialization

# Combinators
f1 = Base.Fix1
f2 = Base.Fix2

# --- Functions ---

import Serialization

savevar(file_path::String, a) = Serialization.serialize(file_path, a)
loadvar(file_path::String) = Serialization.deserialize(file_path)

function load_costas(specs)
    Dict(spec => begin
        kind, m, n = spec

        file_path =
            kind == :all    ? "costas_$(m)x$(n).dat" :
            kind == :orbits || kind == :classes ? "classes_$(m)x$(n).dat" :
            error("Unknown kind: $kind")

        out = loadvar(file_path)
        println(file_path, " has ", length(out), " arrays.")
        out
    end for spec in specs)
end

function windows(z, w)
    ((@view z[i:i + w - 1]) for i in 1:length(z) - w + 1)
end

function isstab(a::Vector{<:Integer})::Bool
    v = l -> l .|> x -> (-x % (length(l) + 1)) + length(l) + 1
    t = l -> l |> tomatrix |> permutedims |> frommatrix
    r = l -> l |> t |> v
    a1 = a |> r
    a2 = a |> r |> r
    a3 = a |> r |> r |> r
    a4 = a |> t
    a5 = a1 |> t
    a6 = a2 |> t
    a7 = a3 |> t
    e = a

    e == a1 && e == a2 && e == a3 && e == a4 && e == a5 && e == a6 && e == a7
end

function class(a::Vector{<:Integer})::Vector{Vector{<:Integer}}
    v = l -> l .|> x -> (-x % (length(l) + 1)) + length(l) + 1
    t = l -> l |> tomatrix |> permutedims |> frommatrix
    r = l -> l |> t |> v
    a1 = a |> r
    a2 = a |> r |> r
    a3 = a |> r |> r |> r
    a4 = a |> t
    a5 = a1 |> t
    a6 = a2 |> t
    a7 = a3 |> t
    e = a

    [e, a1, a2, a3, a4, a5, a6, a7]
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

function classes(c)::Vector{Vector{Integer}}
    cls = []
    remaining = copy(c)
    for l in c
        push = true
        for class in cls
            if isequiv(l, class)
                push = false
            end
        end
        if push
            push!(cls, l)
        end
    end
    cls
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

function isequiv(e::Vector{<:Integer}, a::Vector{<:Integer})::Bool
    v = l -> l .|> x -> (-x % (length(l) + 1)) + length(l) + 1
    t = l -> l |> tomatrix |> permutedims |> frommatrix

    r = l -> l |> t |> v

    a1 = a |> r
    a2 = a |> r |> r
    a3 = a |> r |> r |> r
    a4 = a |> t
    a5 = a1 |> t
    a6 = a2 |> t
    a7 = a3 |> t

    e == a || e == a1 || e == a2 || e == a3 || e == a4 || e == a5 || e == a6 || e == a7
end

function tomatrix(l::Vector{<:Integer})::Matrix{Integer}
    acc = zeros(Int, length(l), length(l))
    for i in 1:length(l)
        e = l[i]
        acc[i, e] = 1
    end
    acc
end

function frommatrix(m::Matrix{<:Integer})::Vector{Integer}
    acc = []
    for i in 1:(Int(sqrt(length(m))))
        push!(acc, findindex(m[i, :], 1))
    end
    acc
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


function iscostashelper2(lst::Vector{T}, f::Function, n::Integer)::Bool where T
    all(begin
        seen::Vector{Bool} = zeros(Bool, 2 * n)
        all(begin
                result = f(lst[i + k], lst[i], n)
                result == 0 ? true : begin
                        prev = seen[result]
                        seen[result] = true
                        !prev
                    end
            end for i ∈ 1:(n - k))
        end for k ∈ 1:n)
end

function astmap(a::T, f) where T
    a == '*' ? '*' : f(a)
end

function astbimap(a::T, b::T, f) where T
    a == '*' || b == '*' ? '*' : f(a, b)
end

function astconst(a::T, b::U, c::U) where {T, U}
    a == '*' ? b : c
end

function normal_predicate(x::T, y::T, n::Integer)::Integer where T
    x - y + n
end

function asterisk_predicate(x::T, y::T, n::Integer)::Integer where T
    x == '*' || y == '*' ? n : x - y + n
end

# Check if a sequence is a Costas sequence
function iscostas(lst::Vector{T}, f::Function = normal_predicate)::Bool where T
    length(unique(lst)) == length(lst) && iscostashelper2(lst, f, length(lst))
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

# Check if a sequence is a Costas sequence with debug information
function iscostasdbg(lst::Vector, f::Function = (x, y, n) -> x - y + n)::Bool
    if size(unique(lst), 1) != size(lst, 1)
        # println("No: repeated rows.")
        return false
    end
    n = length(lst)
    flag = false
    for k in 1:n
        diffs = [false for _ = 1:(2 * n - 1)]
        if flag
            continue
        end
        for i in 1:(n - k)
            a = lst[(i + k) % n + 1]
            b = lst[i]
            result = f(a, b, n)
            # print(result, ' ')
            if diffs[result]
                # println()
                # println("No: same difference for a = $(a), b = $(b), result = $(result)")
                # println("diffs = $(diffs)")
                return false
            elseif result != n
                diffs[result] = true
            end
            flag = diffs[result]
        end
        # println()
    end
    return flag
end

function searchnaive(n::Integer)::Vector{Vector{Integer}}
    1:n |> permutations |> Filter(iscostas) |> collect
end

function some(l::Vector)::Bool
    for e in l
        if e
            return true
        end
    end
    return false
end
