module CostasArrays

using Transducers

include("verify.jl")
include("symmetry.jl")
include("search.jl")
include("io.jl")
include("constructions.jl")
include("classify.jl")

export DATADIR
export iscostas, isstabilized, iscanonical, isequiv
export d4orbit, classes, stabilizers
export searchbt, tsearchbt, tsearchbt_hybrid, nextorder, nextorderfull
export welch, lempel, lempelgolomb
export primitiveroots, isprimitiveroot
export loadcostas, opencostas, fromtxt, totxt
export CostasKind, classify
export Welch, WelchShift, WelchOrbit, WelchShiftOrbit
export Lempel, LempelOrbit, LempelGolomb, LempelGolombOrbit, Sporadic
export iswelch, iswelchshift, inwelchorbit, inwelchshiftorbit
export islempel, inlempelorbit, islempelgolomb, inlempelgolomborbit
export allshifts

end
