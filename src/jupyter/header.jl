# Combinators
f1 = Base.Fix1
f2 = Base.Fix2

# --- Functions ---

function iscostashelper2(lst::Vector{T}, f::Function, n::Integer)::Bool where T
    all(begin
        seen::Vector{Bool} = zeros(Bool, 2 * n)
        all(begin
                result = f(lst[i+k],lst[i],n)
                prev = seen[result]
                seen[result] = true
                !prev
            end for i ∈ 1:(n - k))
        end for k ∈ 1:n)
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
