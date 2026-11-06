"""
Costas array classification into Welch, Lempel, Lempel-Golomb, and Sporadic families.

Categories (checked in order; first match wins):
  Welch              - exactly a Welch construction array
  WelchShift         - a cyclic column shift of a Welch array
  WelchOrbit         - D4-equivalent to a Welch array
  WelchShiftOrbit    - cyclic column shift of a D4-image of a Welch array
  Lempel             - exactly a Lempel construction array
  LempelOrbit        - D4-equivalent to a Lempel array
  LempelGolomb       - a Lempel-Golomb construction array
  LempelGolombOrbit  - D4-equivalent to a Lempel-Golomb array
  Sporadic           - none of the above
"""

@enum CostasKind begin
	Welch
	WelchShift
	WelchOrbit
	WelchShiftOrbit
	Lempel
	LempelOrbit
	LempelGolomb
	LempelGolombOrbit
	Sporadic
end

"""
	allshifts(perm) -> Vector{Vector{Int}}

Return all n cyclic column shifts of a length-n permutation.
"""
function allshifts(perm::AbstractVector{<:Integer})::Vector{Vector{Int}}
	n = length(perm)
	[collect(Int, circshift(perm, s)) for s in 0:n-1]
end

# --- Classification predicates ---

"""
	iswelch(perm) -> Bool

Return `true` if `perm` is a Welch construction array (order p-1 for prime p).
"""
function iswelch(perm::AbstractVector{<:Integer})::Bool
	n = length(perm)
	isprime(n + 1) || return false
	pv = collect(Int, perm)
	any(pv == collect(Int, w) for w in welch(n + 1))
end

"""
	iswelchshift(perm) -> Bool

Return `true` if some cyclic column shift of `perm` is a Welch array.
"""
function iswelchshift(perm::AbstractVector{<:Integer})::Bool
	any(iswelch(s) for s in allshifts(perm))
end

"""
	inwelchorbit(perm) -> Bool

Return `true` if `perm` is D4-equivalent to a Welch array.
"""
function inwelchorbit(perm::AbstractVector{<:Integer})::Bool
	any(iswelch(d) for d in d4orbit(perm))
end

"""
	inwelchshiftorbit(perm) -> Bool

Return `true` if some cyclic column shift of `perm` is D4-equivalent to a Welch array.
"""
function inwelchshiftorbit(perm::AbstractVector{<:Integer})::Bool
	any(inwelchorbit(s) for s in allshifts(perm))
end

"""
	islempel(perm) -> Bool

Return `true` if `perm` is a Lempel construction array (order p-2 for prime p).
"""
function islempel(perm::AbstractVector{<:Integer})::Bool
	n = length(perm)
	isprime(n + 2) || return false
	pv = collect(Int, perm)
	any(pv == collect(Int, l) for l in lempel(n + 2))
end

"""
	inlempelorbit(perm) -> Bool

Return `true` if `perm` is D4-equivalent to a Lempel array.
"""
function inlempelorbit(perm::AbstractVector{<:Integer})::Bool
	any(islempel(d) for d in d4orbit(perm))
end

"""
	islempelgolomb(perm) -> Bool

Return `true` if `perm` is a Lempel-Golomb construction array (order q-2 for prime power q).
This includes Lempel arrays as a special case; check `islempel` first when the distinction matters.
"""
function islempelgolomb(perm::AbstractVector{<:Integer})::Bool
	n = length(perm)
	pv = collect(Int, perm)
	any(pv == lg for lg in lempelgolomb(n + 2))
end

"""
	inlempelgolomborbit(perm) -> Bool

Return `true` if `perm` is D4-equivalent to a Lempel-Golomb array.
"""
function inlempelgolomborbit(perm::AbstractVector{<:Integer})::Bool
	any(islempelgolomb(d) for d in d4orbit(perm))
end

"""
	classify(perm) -> CostasKind

Return the `CostasKind` of a Costas array, checking each construction family
in order. The returned value is the first matching category:

  Welch              - Welch construction
  WelchShift         - cyclic column shift of a Welch array
  WelchOrbit         - D4-equivalent to a Welch array
  WelchShiftOrbit    - cyclic shift of a D4-image of a Welch array
  Lempel             - Lempel construction
  LempelOrbit        - D4-equivalent to a Lempel array
  LempelGolomb       - Lempel-Golomb construction
  LempelGolombOrbit  - D4-equivalent to a Lempel-Golomb array
  Sporadic           - none of the above
"""
function classify(perm::AbstractVector{<:Integer})::CostasKind
	iswelch(perm)              && return Welch
	iswelchshift(perm)         && return WelchShift
	inwelchorbit(perm)         && return WelchOrbit
	inwelchshiftorbit(perm)    && return WelchShiftOrbit
	islempel(perm)             && return Lempel
	inlempelorbit(perm)        && return LempelOrbit
	islempelgolomb(perm)       && return LempelGolomb
	inlempelgolomborbit(perm)  && return LempelGolombOrbit
	Sporadic
end
