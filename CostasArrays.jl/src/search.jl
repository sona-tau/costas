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

"""
	mark!(state, pos, candidate_val)

Place `candidate_val` at position `pos`, updating the difference bitmasks
and the used-value mask in `state`. Not part of the public API.
"""
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

"""
	unmark!(state, pos, candidate_val)

Undo the placement of `candidate_val` at position `pos`, restoring the
difference bitmasks and the used-value mask in `state`. Not part of the
public API.
"""
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

"""
	searchBT!(solutions, state, pos)

Recursive backtracking search. Fills `solutions` with all Costas arrays of
order `state.n`, starting from column `pos`. Not part of the public API.
"""
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

"""
    nextorder(canonical) -> Vector{Vector{Int}}

Given all D4 canonical representatives of Costas arrays of order n, return
all canonical representatives of order n+1 that can be constructed by
inserting the value n+1 into any position of any order-n array.

Covers roughly 98-99% of all order-(n+1) arrays; the remainder must be found
by backtracking (see `tsearchbt_hybrid`).
"""
function nextorder(canonical::Vector{Vector{Int}})::Vector{Vector{Int}}
    n = length(first(canonical))
    result = Set{Vector{Int}}()
    buf = Vector{Int}(undef, n + 1)

    for c in canonical
        for i in 1:n+1
            @inbounds begin
                for j in 1:i-1;  buf[j] = c[j];   end
                buf[i] = n + 1
                for j in i:n;    buf[j+1] = c[j]; end
            end
            iscostas(buf) && iscanonical(buf) && push!(result, copy(buf))
        end
    end

    collect(result)
end

"""
    nextorderfull(canonical) -> Vector{Vector{Int}}

Like `nextorder`, but inserts every possible value (not just the maximum) at
every possible position. For each canonical representative of order n and each
(value, position) pair, values in the source array that are ≥ the inserted
value are shifted up by 1 so the result is a permutation of {1, …, n+1}.

Covers all order-(n+1) arrays that have any Costas child, i.e. arrays reachable
by removing any single element (with value compression) to obtain an order-n
Costas array. Compare with `nextorder`, which only inserts the maximum element
and covers ~98–99% of arrays.
"""
function nextorderfull(canonical::Vector{Vector{Int}})::Vector{Vector{Int}}
    n = length(first(canonical))
    result = Set{Vector{Int}}()
    buf = Vector{Int}(undef, n + 1)

    for c in canonical
        for ins_val in 1:n+1
            for ins_pos in 1:n+1
                @inbounds begin
                    for j in 1:ins_pos-1
                        v = c[j]
                        buf[j] = v >= ins_val ? v + 1 : v
                    end
                    buf[ins_pos] = ins_val
                    for j in ins_pos:n
                        v = c[j]
                        buf[j+1] = v >= ins_val ? v + 1 : v
                    end
                end
                iscostas(buf) && push!(result, copy(buf))
            end
        end
    end

    collect(result)
end

"""
    searchBT_missing!(solutions, state, pos, subbuf)

Backtracking search that only collects canonical solutions where removing the
maximum value does not yield a Costas array (i.e. arrays not reachable via
`nextorder` from the previous order). `subbuf` is a caller-owned buffer of
length `state.n - 1` reused across leaf visits. Not part of the public API.
"""
function searchBT_missing!(
    solutions::Vector{Vector{Int}},
    state::State,
    pos::Int,
    subbuf::Vector{Int}
)::Nothing
    if pos > 1 && pos < (state.n >> 1) && shouldprune(state.arr, state.n)
        return nothing
    elseif pos > state.n
        k = 0
        @inbounds for j in 1:state.n
            state.arr[j] == state.n && continue
            k += 1
            subbuf[k] = state.arr[j]
        end
        iscostas(subbuf) || push!(solutions, copy(state.arr))
        return nothing
    end

    for candidate_val in 1:state.n
        state.used_mask & (UInt64(1) << candidate_val) != 0 && continue
        if iscostas0(state, pos, candidate_val)
            mark!(state, pos, candidate_val)
            searchBT_missing!(solutions, state, pos + 1, subbuf)
            unmark!(state, pos, candidate_val)
        end
    end

    return nothing
end

"""
    tsearchbt_hybrid(n, prev_canonical) -> Vector{Vector{Int}}

Two-phase search for all D4 canonical representatives of order `n`:
- Phase 1: insert n into every canonical representative of order n-1 at all
  positions. Covers ~98-99% of order-n arrays with no backtracking.
- Phase 2: parallel backtracking collecting only arrays where removing the max
  element does not give a Costas array. Uses one thread-local buffer per thread
  instead of a `found_set`, avoiding the large allocation from Phase 1 output.

The combined result is identical to `tsearchbt(n)`.
"""
function tsearchbt_hybrid(n::Int, prev_canonical::Vector{Vector{Int}})::Vector{Vector{Int}}
    constructed = nextorder(prev_canonical)

    missed = foldxt(vcat, begin
        local_solutions = Vector{Vector{Int}}()
        state = newstate(n)
        subbuf = Vector{Int}(undef, n - 1)
        mark!(state, 1, first_val)
        searchBT_missing!(local_solutions, state, 2, subbuf)
        local_solutions
    end for first_val in 1:n)

    vcat(constructed, missed)
end

"""
	searchbt(n) -> Vector{Vector{Int}}

Return all D4 orbit representatives of Costas arrays of order `n` using
single-threaded backtracking with D4 canonicalization pruning.
"""
function searchbt(n::Int)::Vector{Vector{Int}}
    solutions::Vector{Vector{Int}} = Vector{Vector{Int}}()
    searchBT!(solutions, newstate(n))
    return solutions
end

"""
	tsearchbt(n) -> Vector{Vector{Int}}

Return all D4 orbit representatives of Costas arrays of order `n` using
parallel backtracking. Work is split by fixing the first column value and
distributing across threads via `Transducers.foldxt`.
"""
function tsearchbt(n::Int)
    foldxt(vcat, begin
            local_solutions = Vector{Vector{Int}}()
            state = newstate(n)
            mark!(state, 1, first_val)
            searchBT!(local_solutions, state, 2)
            local_solutions
        end for first_val in 1:n)
end

