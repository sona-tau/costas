module CostasArrays

using Transducers

include("verify.jl")
include("symmetry.jl")
include("search.jl")
include("io.jl")

export DATADIR
export iscostas, canon, isequiv, isstabilized
export d4orbit, classes, stabilizers
export searchbt, tsearchbt
export welch, lempel, primitiveroots, isprimitiveroot
export loadcostas, opencostas, fromtxt, totxt

end
