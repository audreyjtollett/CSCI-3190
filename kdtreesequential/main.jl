module kdtreemain
include("kdtreeseq.jl")
# KD-Tree Main
# Audrey

if !isinteractive()
    nbody(parse(Int, ARGS[1]), parse(Int, ARGS[2]))
end