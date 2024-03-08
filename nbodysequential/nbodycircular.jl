module nbodycirc
using Printf
using Random
# NBody Circular
# Audrey Tollett

mutable struct Particle
    x::Float64
    y::Float64
    z::Float64
    vx::Float64
    vy::Float64
    vz::Float64
    rad::Float64 #what is rad
    m::Float64
end



function circular_orbits(n) 
    first = Particle(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.00465047, 1.0)
    bods = [first]
    for i in 1:n
        d = .1 + (i * 5.0 / n)
        v = sqrt(1.0 / d)
        theta = rand(Float64)*2*pi
        x = d * cos(theta)
        y = d * sin(theta)
        vx = -v * sin(theta)
        vy = v * cos(theta)
        temp = Particle(x, y, 0.0, vx, vy, 0, 1.0e-14, 1.0e-7)
        push!(bods, temp) #is this pushing a reference to temp in which case is everything going to explode and how do i fix that
    end
    bods
    #print(bods)
end

#circular_orbits(3)

end