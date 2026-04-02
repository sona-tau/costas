"""
	State

Internal mutable state for the backtracking search algorithm. Not part of the
public API.

# Fields
- `arr`: the partial permutation being built, with zeros in unfilled positions
- `used_mask`: a bitmask showing which values have been placed so far
- `diffs`: a vector of bitmasks, one per shift k, tracking which differences
have been seen at that shift
- `n`: the order of the Costas array being built
"""
mutable struct State
    arr::Vector{Int}
    used_mask::UInt64
    diffs::Vector{UInt64}
    n::Int
end

"""
	newstate(n::Integer)::State

Return a new `State`. Not part of the public API.
"""
function newstate(n::Integer)::State
    State(zeros(Int, n), 0, zeros(n - 1), n)
end

"""
	iscostas0(state::State, pos::Integer, candidate_val::Integer)::Bool

Very similar to `iscostas`, however this function accounts for values that
might be 0 and only computes differences for the `candidate_val`'s position.
Not part of the public API.
"""
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

"""
	shouldprune(c::AbstractVector{<:Integer}, n::Integer)::Bool

Pruning: we only extend partial arrays that are already the canonical
representative of their D4 orbit. This avoids generating symmetric duplicates
at the cost of checking canonicity at each node. This is valid because D4
action commutes with the Costas property. Checking whether to prune is more
costly than checking for the Costas property. However, the amount of trees in
the backtracking algorithm that are cut far exceeds the overhead of computing
the canon of a permutation.
"""
function shouldprune(c::Vector{Int}, n::Int)::Bool
	canon(c) != c
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
    searchBT!(solutions, newstate(n))
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

