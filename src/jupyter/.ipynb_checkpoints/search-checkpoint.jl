import Pkg;
using Serialization
Pkg.add("Transducers")
using Transducers
Pkg.add("Primes")
using Primes
Pkg.add("Combinatorics")
using Combinatorics

function iscostashelper2(lst::Vector{T}, n::Integer)::Bool where T
    all(begin
        seen::Vector{Bool} = zeros(Bool, 2 * n)
        all(begin
                result = lst[i+k] - lst[i] + n
                prev = seen[result]
                seen[result] = true
                !prev
            end for i ∈ 1:(n - k))
        end for k ∈ 1:n)
end

# Check if a sequence is a Costas sequence
function iscostas(lst::Vector{T})::Bool where T
    length(unique(lst)) == length(lst) && iscostashelper2(lst, length(lst))
end

const START = 14
const LIMIT = 16

Threads.@threads for n in (START + 1):LIMIT
    out = 1:n |> permutations |> Filter(iscostas) |> tcollect
    file_path = "costas_$(n)x$n.dat"
    serialize(file_path, out)
    println("$file_path has $(length(out)) arrays.")
end

Threads.@threads for n in START:LIMIT
    out = 2:n |> permutations |> Filter(iscostas) |> tcollect
    file_path = "costas_$(n)x$(n + 1).dat"
    serialize(file_path, out)
    println("$file_path has $(length(out)) arrays.")
end
