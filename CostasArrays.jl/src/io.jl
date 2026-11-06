const DATADIR = get(ENV, "COSTAS_DATA", joinpath(@__DIR__, "../data"))

"""
	fromtxt(s) -> Vector{Vector{Int}}

Parse a newline-separated string of space-separated integers into a vector of
permutations. Each line becomes one permutation.
"""
function fromtxt(s::String)::Vector{Vector{Int}}
    map.(Base.Fix1(parse, Int), split.(split(s, "\n")))
end

"""
	totxt(c) -> String

Serialize a vector of permutations to a newline-separated string of
space-separated integers, matching the plain-text data file format.
"""
function totxt(c::Vector{Vector{Integer}})::String
    join(join.(c, " "), "\n")
end

"""
	opencostas(fpath) -> Vector{Vector{Int}}

Read a plain-text Costas array file (one space-separated permutation per line)
and return the arrays as a vector of integer vectors.
"""
function opencostas(fpath::String)::Vector{Vector{Int}}
    map.(Base.Fix1(parse, Int), split.(eachline(fpath)))
end

"""
	loadcostas(specs, datadir) -> Dict

Load multiple Costas array files from `datadir` and return a `Dict` mapping
each spec to its arrays. Each spec is a tuple `(kind, m, n)` where `kind` is
`:all` (reads `costas_mxn.txt`) or `:orbits`/`:classes` (reads `orbits_mxn.txt`).
"""
function loadcostas(specs, datadir::String)
    Dict(spec => begin
        kind, m, n = spec

        file_path = datadir * (
            kind == :all    ? "costas_$(m)x$(n).txt" :
            kind == :orbits || kind == :classes ? "orbits_$(m)x$(n).txt" :
            error("Unknown kind: $kind"))

        out = opencostas(file_path)
        println(file_path, " has ", length(out), " arrays.")
        out
    end for spec in specs)
end
