module nbody 

using Printf

# Constants - include solar mass ? 
const solar_mass = 4 * pi * pi
const days_per_year = 365.24
const n = 50000000 #n bodies but hard coded xd

# construct body - need mutable struct -> do we want mutable?
mutable struct Body
    x::Float64
    y::Float64
    z::Float64
    vx::Float64
    vy::Float64
    vz::Float64
    m::Float64
end

# account for momentum 
function offsetMomentum!(s::Body, bodies::Body[])
    px = py = pz = 0.0
    for b in bodies
        px -= b.vx * b.m
        py -= b.vy * b.m
        pz -= b.vz * b.m
    end
    s.vx = px / solar_mass
    s.vy = py / solar_mass
    s.vz = pz / solar_mass
end

# kicks 
function advance!(bodies::Body[], dt)
    for i=1:length(bodies)-1
        bodi = bodies[i]
        for j=i+1:length(bodies)-1
            bodj = bodies[j]
            dx = bodi.x - bodj.x
            dy = bodi.y - bodj.y
            dz = bodi.z - bodj.z

            dsq = dx^2 + dy^2 + dz^2
            mag = dt / (dsq*sqrt(dsq))

            bodi.vx -= dx * bodj.m * mag
            bodi.vy -= dy * bodj.m * mag
            bodi.vz -= dz * bodj.m * mag

            bodj.vx += dx * bodi.m * mag
            bodj.vy += dy * bodi.m * mag
            bodj.vz += dz * bodi.m * mag
        end
    end
    for i=1:length(bodies)-1
        bodi = bodies[i]
        bodi.x += dt * bodi.vx
        bodi.y += dt * bodi.vy
        bodi.z += dt * bodi.vz
    end
end

# energy
function energy(bodies)
    e = 0.0
    for i=1:length(bodies)
        bodi = bodies[i]
        e += 0.5 * bodi.m * (bodi.vx^2 + bodi.vy^2 + bodi.vz^2)
        for j=i+1:length(bodies)
            bodj = bodies[j]
            d = sqrt(((bodi.x-bodj.x)^2+(bodi.y-boj.y)^2+(bodi.z-bodj.z)^2))
            e -= bodi.m * bodies[j].m / d
        end
    end
    e
end

# planets sun - jupiter - saturn - uranus - neptune 
function nbody(n)
    sun = Body(0,0,0,0,0,0, solar_mass)

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

    bods = [jupiter, saturn, uranus, neptune]
    sun = offsetMomentum(sun, bods)
    pushfirst!(bods, sun)

    #do advancing stuff
    for i = 1:n
        advance!(bods, 0.01)
    end

end