using CostasArrays

# Labels are mutually exclusive: classify(perm) returns exactly one CostasKind,
# so a single label column suffices.
const LABEL = Dict(
    Welch            => "W",
    WelchShift       => "V",
    WelchOrbit       => "w",
    WelchShiftOrbit  => "v",
    Lempel           => "L",
    LempelOrbit      => "l",
    LempelGolomb     => "G",
    LempelGolombOrbit => "g",
    Sporadic         => "s",
)

function writelabels(outpath::String, datadir::String)
    open(outpath, "w") do io
        println(io, "array,label")
        for n in 1:20
            fpath = joinpath(datadir, "costas_$(n)x$(n).txt")
            isfile(fpath) || continue
            println(stderr, "classifying order $n...")
            for perm in opencostas(fpath)
                label = LABEL[classify(perm)]
                println(io, "\"$(join(perm, " "))\",$label")
            end
        end
    end
end

const LOCAL_DATA = joinpath(@__DIR__, "../../data")

writelabels(
    joinpath(LOCAL_DATA, "labels.csv"),
    LOCAL_DATA,
)
