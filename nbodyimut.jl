module nbody 

using Printf

# Constants - include solar mass ? 
const SOLAR_MASS = 4 * pi * pi
const DAYS_PER_YEAR = 365.24

# construct body - need immmutable struct 
struct body
    x::Float64    # position 
    y::Float64
    z::Float64
    vx::Float64   # velocity 
    vy::Float64
    vz::Float64   # mass 
    m::Float64
end
# account for momentum 

# create the sun 
function init_sun(bodies)
    px = py = pz = 0.0
    for b in bodies
        px -= b.vx * b.m
        py -= b.vy * b.m
        pz -= b.vz * b.m
    end
    Body(0.0, 0.0, 0.0, px / SOLAR_MASS, py / SOLAR_MASS, pz / SOLAR_MASS, SOLAR_MASS)
end
# kicks 

# account for energy 

# planets - jupiter - saturn - uranus - neptune 
function nbody(n)
    jupiter = Body( 4.84143144246472090e+0,                   # x
                   -1.16032004402742839e+0,                   # y
                   -1.03622044471123109e-1,                   # z
                    1.66007664274403694e-3 * DAYS_PER_YEAR,   # vx
                    7.69901118419740425e-3 * DAYS_PER_YEAR,   # vy
                   -6.90460016972063023e-5 * DAYS_PER_YEAR,   # vz
                    9.54791938424326609e-4 * SOLAR_MASS)      # mass

    saturn = Body( 8.34336671824457987e+0,
                   4.12479856412430479e+0,
                  -4.03523417114321381e-1,
                  -2.76742510726862411e-3 * DAYS_PER_YEAR,
                   4.99852801234917238e-3 * DAYS_PER_YEAR,
                   2.30417297573763929e-5 * DAYS_PER_YEAR,
                   2.85885980666130812e-4 * SOLAR_MASS)

    uranus = Body( 1.28943695621391310e+1,
                  -1.51111514016986312e+1,
                  -2.23307578892655734e-1,
                   2.96460137564761618e-3 * DAYS_PER_YEAR,
                   2.37847173959480950e-3 * DAYS_PER_YEAR,
                  -2.96589568540237556e-5 * DAYS_PER_YEAR,
                   4.36624404335156298e-5 * SOLAR_MASS)

    neptune = Body( 1.53796971148509165e+1,
                   -2.59193146099879641e+1,
                    1.79258772950371181e-1,
                    2.68067772490389322e-3 * DAYS_PER_YEAR,
                    1.62824170038242295e-3 * DAYS_PER_YEAR,
                   -9.51592254519715870e-5 * DAYS_PER_YEAR,
                    5.15138902046611451e-5 * SOLAR_MASS)

    bodies = [jupiter, saturn, uranus, neptune]
    pushfirst!(bodies, init_sun(bodies)) # making the sun the first thing in the array 
end

# dont forget to end module 