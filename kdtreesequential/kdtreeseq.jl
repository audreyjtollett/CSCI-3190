module juliasim
# KD-Tree Sequential, single struct for nodes
# Audrey & Clarissa

# Constants
const MAX_PARTS = 7
const THETA = 0.3

mutable struct Body
    p::Array{Float64} #p[0] = x, p[1] = y...
    v::Array{Float64} #v[0] = vx, v[1] = vy...
    m::Float64
end


abstract type KDTree end

struct KDLeaf <: KDTree
    # for leaves
    num_parts::Int64
    particles::Array{Int64}
end

struct KDInternal <: KDTree
    # for internal nodes
    split_dim::Int64
    split_val::Float64
    m::Float64
    cm::Array{Float64}
    size::Float64
    left::KDTree
    right::KDTree
end

function build_tree(indices::Array{Int64}, start::Int64, ending::Int64, system::Array{Body})::KDTree
    np = ending - start
    if np <= MAX_PARTS
        node = KDLeaf(np, zeros(Int64, MAX_PARTS))
        for i in 1:np
            node.particles[i] = indices[start + i]
        end
        node
    else
        minp = [1e100, 1e100, 1e100]
        maxp = [-1e100, -1e100, -1e100]
        m = 0.0
        cm = [0.0, 0.0, 0.0]
        for i in start:ending
            m += system[indices[i]].m
            cm += system[indices[i]].m * system[indices[i]].p
            # cm[0] += system[indices[i]].m * system[indices[i]].p[0]
            # cm[1] += system[indices[i]].m * system[indices[i]].p[1]
            # cm[2] += system[indices[i]].m * system[indices[i]].p[2]
            minp = min.(minp, system[indices[i]].p)
            # minp[0] = min(minp[0], system[indices[i]].x)
            # minp[1] = min(minp[1], system[indices[i]].y)
            # minp[2] = min(minp[2], system[indices[i]].z)
            maxp = max.(maxp, system[indices[i]].p)
            # maxp[0] = max(minp[0], system[indices[i]].x)
            # maxp[1] = max(minp[1], system[indices[i]].y)
            # maxp[2] = max(minp[2], system[indices[i]].z)
        end
        cm /= m
        # cm[0] /= m
        # cm[1] /= m
        # cm[2] /= m 
        split_dim = 1
        if maxp[2] - minp[2] > maxp[split_dim] - minp[split_dim]
            split_dim = 2
        end
        if maxp[3] - minp[3] > maxp[split_dim] - minp[split_dim]
            split_dim = 3
        end
        size = maxp[split_dim] - minp[split_dim]
        # partition time
        mid::Int64 = div((start + ending), 2) # int division mid bs
        s = start
        e = ending
        while s + 1 < e
            pivot = rand(s:e)
            swapTmp = indices[s]
            indices[s] = indices[pivot]
            indices[pivot] = swapTmp
            low = s+1
            high = e-1
            while low <= high
                if system[indices[low]].p[split_dim] < system[indices[s]].p[split_dim]
                    low += 1
                else
                    swapTmp2 = indices[low]
                    indices[low] = indices[high]
                    indices[high] = swapTmp2
                    high-= 1
                end
            end
            swapTmp3 = indices[s]
            indices[s] = indices[high]
            indices[high] = swapTmp3
            if high < mid
                s = high + 1
            elseif high > mid
                e = high
            else
                s = e
            end
        end
        split_val = system[indices[mid]].p[split_dim]
        #recursion on kids
        left = build_tree(indices, start, mid, system)
        right = build_tree(indices, mid, ending, system)
        
        node = KDInternal(split_dim, split_val, m, [0, 1, 2], size, left, right)
        
        node
    end
end

    function calc_pp_accel(system, i, j, acc)
        d = system[i].p - system[j].p
        dist = sqrt(sum(d.^2))
        magi = -system[j].m / (dist^3) 
        acc += d * magi
    end

    function accel_recur(cur_node::KDLeaf, p::Int64, system::Vector{Body}, acc)
        for i in 1:cur_node.num_parts
            if cur_node.particles[i] != p
                calc_pp_accel(system, p, cur_node.particles[i], acc)
            end
        end
    end
    function accel_recur(cur_node::KDInternal, p::Int64, system::Vector{Body}, acc)
        d = system[p].p - cur_node.cm
        dist_sqr = sum(d.^2)
        if cur_node.size * cur_node.size < THETA^2 * dist_sqr
            dist = sqrt(dist_sqr)
            magi = -nodes[cur_node].m / (dist_sqr * dist)
            acc += d * magi
        else
            accel_recur(cur_node.left, p, system, acc)
            accel_recur(cur_node.right, p, system, acc)
        end
    end

    function calc_accel(p::Int64, tree:: KDTree, system::Vector{Body}, acc)
        accel_recur(tree, p, system, acc)
    end

    function print_tree(step::Int64, tree::KDTree, system::Array{Body})
        function print_node(n::KDLeaf, file::IO)
            println(file, "L $(n.num_parts)")
                        for i in 1:n.num_parts
                            p = n.particles[i]
                            println(p)
                            println(file, "$(system[p].p[1]) $(system[p].p[2]) $(system[p].p[3])")
                        end
        end

        function print_node(n::KDInternal, file::IO)
            println(file, "I $(n.split_dim) $(n.split_val) 0 1")
            print_node(n.left, file)
            print_node(n.right, file)
        end

        fname = "tree$step.txt"
        try
            open(fname, "w") do file
                println(file, 0)
                print_node(tree, file)
            end
        catch ex
            println("Exception writing to file.\n")
            println(ex)
        end
    end


    function simple_sim(system::Vector{Body}, dt::Float64, steps::Int64)
        nb::Int64 = length(system)
        acc = zeros(nb, 3)
        indices = collect(1:nb)
    
        for step in 1:steps
            tree = build_tree(indices, 1, nb, system)
            for i in 1:nb
                calc_accel(i, tree, system, acc[i, :])
            end
            for i in 1:nb
                system[i].v += dt * acc[i,:]
                system[i].p += dt * system[i].v
                acc[i, :] .= 0.0
            end
            print_tree(step, tree, system)
        end
    end


end