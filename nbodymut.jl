module nbody 

using Printf

# Constants - include solar mass ? 
const solar_mass = 4 * pi * pi
const days_per_year = 365.24

# construct body - need mutable struct -> do we want mutable?
mutable struct body
    x::Float64
    y::Float64
    z::Float64
    vx::Float64
    vy::Float64
    vz::Float64
    m::Float64
end

# account for momentum 

# create the sun 

# kicks 

# account for energy 

# planets - jupiter - saturn - uranus - neptune 

# dont forget to end module 