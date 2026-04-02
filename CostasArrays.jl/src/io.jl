const DATADIR = get(ENV, "COSTAS_DATA", joinpath(@__DIR__, "../data"))

function fromtxt(s::String)::Vector{Vector{Int}}
    map.(Base.Fix1(parse, Int), split.(split(s, "\n")))
end

function totxt(c::Vector{Vector{Integer}})::String
    join(join.(c, " "), "\n")
end

function opencostas(fpath::String)::Vector{Vector{Int}}
    map.(Base.Fix1(parse, Int), split.(eachline(fpath)))
end

function loadcostas(specs, datadir::String)
    Dict(spec => begin
        kind, m, n = spec

        file_path = datadir * (
            kind == :all    ? "costas_$(m)x$(n).txt" :
            kind == :orbits || kind == :classes ? "classes_$(m)x$(n).txt" :
            error("Unknown kind: $kind"))

        out = opencostas(file_path)
        println(file_path, " has ", length(out), " arrays.")
        out
    end for spec in specs)
end
