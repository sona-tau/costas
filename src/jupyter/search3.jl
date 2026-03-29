using Transducers

function topoints(l::Vector{<:Integer})::Vector{Tuple{Int, Int}}
    l |> enumerate |> Filter(a -> a[2] != 0) |> collect
end

function frompoints(ts::AbstractVector{<:Tuple{<:Integer,<:Integer}}, n::Integer)::Vector{Int}
    ret::Vector{Int} = zeros(n)
    @inbounds for (x, y) in ts
        ret[x] = y
    end
    ret
end

function D₄π(p::Vector{Int}, n::Int)::Vector{Int}
    [[(a[1], a[2]), (n + 1 - a[2], a[1]), (n + 1 - a[1], n + 1 - a[2]), (a[2], n + 1 - a[1]), (a[1], n + 1 - a[2]), (n + 1 - a[1], a[2]), (a[2], a[1]), (n + 1 - a[2], n + 1 - a[1])] for a in topoints(p)] |>
        Base.Fix1(reduce, hcat) |>
        eachrow |>
        minimum |>
        Base.Fix2(frompoints, n) |>
        collect
end

function shouldprune(c::Vector{Int}, n::Int)::Bool
    D₄π(c, n) != c
end

mutable struct State
    arr::Vector{Int}
    used_mask::UInt64
    diffs::Vector{UInt64}
    n::Int
end

function newstate(n::Int)::State
    State(zeros(Int, n), 0, zeros(n - 1), n)
end

@inline function iscostas0(state::State, pos::Int, candidate_val::Int)::Bool
    @inbounds all(begin
            prev_val::Int = state.arr[prev_pos]
            bit::UInt64 = UInt64(1) << (candidate_val - prev_val + state.n)
            prev_val == 0 || ((state.diffs[pos - prev_pos] & bit) == 0)
        end for prev_pos::Int in 1:(pos - 1))
end

function mark!(state::State, pos::Int, candidate_val::Int)::Nothing
    @inbounds for prev_pos::Int in 1:(pos - 1)
        prev_val::Int = state.arr[prev_pos]

        if prev_val == 0
            continue
        end
        bit::UInt64 = UInt64(1) << (candidate_val - prev_val + state.n)
        state.diffs[pos - prev_pos] |= bit
    end
    
    state.arr[pos] = candidate_val
    state.used_mask |= UInt64(1) << candidate_val

    return nothing
end

function unmark!(state::State, pos::Int, candidate_val::Int)::Nothing
    @inbounds for prev_pos::Int in 1:(pos - 1)
        prev_val::Int = state.arr[prev_pos]

        if prev_val == 0
            continue
        end
        bit::UInt64 = ~(UInt64(1) << (candidate_val - prev_val + state.n))
        state.diffs[pos - prev_pos] &= bit
    end
    
    state.arr[pos] = 0
    state.used_mask &= ~(UInt64(1) << candidate_val)
    
    return nothing
end

function next_pos(arr::Vector{Int})::Int
    for pos in eachindex(arr)
        if arr[pos] == 0
            return pos
        end
    end
    return 0
end

function searchBT!(solutions::Vector{Vector{Int}}, state::State, pos::Int)::Nothing
    if pos > 1 && pos < (state.n >> 1) && shouldprune(state.arr, state.n)
            return nothing
    elseif pos > state.n
        push!(solutions, copy(state.arr))
        return nothing
    end

    for candidate_val in 1:state.n
        if state.used_mask & (UInt64(1) << candidate_val) != 0
            continue
        end

        if iscostas0(state, pos, candidate_val)
            mark!(state, pos, candidate_val)
            searchBT!(solutions, state, pos + 1)
            unmark!(state, pos, candidate_val)
        end
    end

    return nothing
end

function searchbt(n::Int)::Vector{Vector{Int}}
    solutions::Vector{Vector{Int}} = Vector{Vector{Int}}()
    searchBT!(solutions, new_state(n))
    return solutions
end

function tsearchbt(n::Int)
    foldxt(vcat, begin
            local_solutions = Vector{Vector{Int}}()
            state = newstate(n)
            mark!(state, 1, first_val)
            searchBT!(local_solutions, state, 2)
            local_solutions
        end for first_val in 1:n)
end

# const START = 13
# const LIMIT = 20

# @Threads.threads for n in (START + 1):LIMIT
# 	 out = searchbt(n)
# 	 file_path = "costas_$(n)x$n.dat"
# 	 serialize(file_path, out)
# 	 println("$file_path has $(length(out)) arrays.")
# end
