module kdtreemain
include("kdtreeseq.jl")



# KD-Tree Main
# Audrey

function circular_orbits(n::Int64)::Vector{juliasim.Body}
    first = juliasim.Body([0.0, 0.0, 0.0], [0.0, 0.0, 0.0], 1.0)
    bods = [first]
    for i in 1:n
        d = .1 + (i * 5.0 / n)
        v = sqrt(1.0 / d)
        theta = rand(Float64)*2*pi
        x = d * cos(theta)
        y = d * sin(theta)
        vx = -v * sin(theta)
        vy = v * cos(theta)
        temp = juliasim.Body([x, y, 0.0], [vx, vy, 0] , 1.0e-7)
        push!(bods, temp)
    end
    bods
    #print(bods)
end

if !isinteractive()
    n = parse(Int64, ARGS[1])
    steps = parse(Int64, ARGS[2])
    dt = 1e-3
    system = circular_orbits(n)
    juliasim.simple_sim(system, dt, steps)
end

end