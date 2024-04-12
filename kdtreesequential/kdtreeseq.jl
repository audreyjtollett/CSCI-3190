module kdtreeseq
# KD-Tree Sequential, single struct for nodes
# Audrey & Clarissa

# Constants
const MAX_PARTS = 7
const THETA = 0.3

mutable struct Body
    p::Array{Float64}
    v::Array{Float64}
    m::Float64
end

mutable struct KDTree #I made it mutable for now, basing off java code and i dont see how it can be immut...
    # for leaves
    num_parts::Int64
    particles::Array{MAX_PARTS, Int64}
    # for internal nodes
    split_dim::Int64
    split_val::Float64
    m::Float64
    cm::Array{Float64}
    size::Float64
    left::Int64
    right::Int64
end

function allocate_node_vec(num_parts::Int64)
    num_nodes = 2*(num_parts / (MAX_PARTS-1) + 1)
    ret::Array{num_nodes, Float64}
end

function build_tree(indices::Array{Int64}, start::Int64, ending::Int64, system::Array{Body}, cur_node::Int64, nodes::Array{KDTree})
    np = ending - start
    if np <= MAX_PARTS
        while cur_node >= length(nodes)
            push!(nodes, KDTree()) #idk if this works and idk why im doing this
        end
        nodes[cur_node].num_parts = np
        for i in 1:np
            nodes[cur_node].particles[i] = indices[start + i]
        end
        cur_node
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
        split_dim = 0
        if maxp[1] - minp[1] > maxp[split_dim] - minp[split_dim]
            split_dim = 1
        end
        if maxp[2] - minp[2] > maxp[split_dim] - minp[split_dim]
            split_dim = 2
        end
        size = maxp[split_dim] - minp[split_dim]
        # partition time
        mid = (start + ending) / 2
        s = start
        e = ending
        while s + 1 < e
            pivot = rand(s:e)
            swapTmp = indices[s]
            indices[s] = indices[pivot]
            indices[pivot] = swapTmp
            low = s+1
            high = e-1
            while low<= high #either change how struct body stores xyz or it has to be this way
                if getDim(system[indices[low]], split_dim) < getDim(system[indices[s]], split_dim)
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

        #recursion on kids
        left = build_tree(indices, start, mid, system, cur_node+1, nodes)
        right = build_tree(indices, mid, ending, system, cur_node+1, nodes)

        while cur_node >= length(nodes)
            push!(nodes, KDTree()) #idk if this works and idk why im doing this
        end 

        nodes[cur_node] = KDTree(0, split_dim, split_val, m, [0, 1, 2], size, cur_node + 1, left + 1)

        right
    end

    function calc_pp_accel(system, i, j, acc)
        dx = system.p[i, 1] - system.p[j, 1]
        dy = system.p[i, 2] - system.p[j, 2]
        dz = system.p[i, 3] - system.p[j, 3]
        dist = sqrt(dx^2 + dy^2 + dz^2)
        magi = -system.m[j] / (dist^3) 
        acc[1] += dx * magi
        acc[2] += dy * magi
        acc[3] += dz * magi
    end

    function accel_recur(cur_node, p, system, nodes, acc)
        if nodes[cur_node].num_parts > 0
            for i in 1:nodes[cur_node].num_parts
                if nodes[cur_node].particles[i] != p
                    calc_pp_accel(system, p, nodes[cur_node].particles[i], acc)
                end
            end
        else
            dx = system.p[p, 1] - nodes[cur_node].cm[1]
            dy = system.p[p, 2] - nodes[cur_node].cm[2]
            dz = system.p[p, 3] - nodes[cur_node].cm[3]
            dist_sqr = dx^2 + dy^2 + dz^2
            if nodes[cur_node].size * nodes[cur_node].size < THETA^2 * dist_sqr
                dist = sqrt(dist_sqr)
                magi = -nodes[cur_node].m / (dist_sqr * dist)
                acc[1] += dx * magi
                acc[2] += dy * magi
                acc[3] += dz * magi
            else
                accel_recur(nodes[cur_node].left, p, system, nodes, acc)
                accel_recur(nodes[cur_node].right, p, system, nodes, acc)
            end
        end
    end

    function calc_accel(p, system, nodes, acc)
        accel_recur(1, p, system, nodes, acc)
    end

    function print_tree(step, tree, system)
        fname = "tree$step.txt"
        try
            open(fname, "w") do file
                println(file, length(tree))
                for n in tree
                    if n.num_parts > 0
                        println(file, "L $(n.num_parts)")
                        for p in n.particles
                            println(file, "$(system.p[p, 1]) $(system.p[p, 2]) $(system.p[p, 3])")
                        end
                    else
                        println(file, "I $(n.split_dim) $(n.split_val) $(n.left) $(n.right)")
                    end
                end
            end
        catch ex
            println("Exception writing to file.\n")
            showerror(ex)
        end
    end

    function simple_sim(system, dt, steps)
        acc = zeros(system.numBodies(), 3)
        tree = allocate_node_vec(system.numBodies())
        indices = collect(1:system.numBodies())
    
        for step in 1:steps
            build_tree(indices, 1, system.numBodies(), system, 1, tree)
            for i in 1:system.numBodies()
                calc_accel(i, system, tree, acc[i, :])
            end
            for i in 1:system.numBodies()
                system.incV(i, 1, dt * acc[i, 1])
                system.incV(i, 2, dt * acc[i, 2])
                system.incV(i, 3, dt * acc[i, 3])
                system.incP(i, 1, dt * system.v[i, 1])
                system.incP(i, 2, dt * system.v[i, 2])
                system.incP(i, 3, dt * system.v[i, 3])
                acc[i, :] .= 0.0
            end
        end
    end

end

end