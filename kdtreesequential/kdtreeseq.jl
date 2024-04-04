module kdtreeseq
using nbodymutparallel
# KD-Tree Sequential, single struct for nodes
# Audrey & Clarissa

# Constants
const MAX_PARTS = 7
const THETA = 0.3


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

function build_tree(indicies::Array{Int64}, start::Int64, ending::Int64, system::Array{Body}, cur_node::Int64, nodes::Array{KDTree})
    np = ending - start
    if np <= MAX_PARTS
        while cur_node >= length(nodes)
            push!(nodes, KDTree())
        end
        nodes[cur_node].num_parts = np
        for i in 1:np
            nodes[cur_node].particles[i] = indicies[start + i]
        end
        cur_node
    else
        min = [1e100, 1e100, 1e100]
        max = [-1e100, -1e100, -1e100]
        m = 0.0
        cm = [0.0, 0.0, 0.0]
        for i in start:ending
            m += system[indicies[i]].m
            cm[0] += system[indicies[i]].m * system[indicies[i]].x
            cm[1] += system[indicies[i]].m * system[indicies[i]].y
            cm[2] += system[indicies[i]].m * system[indicies[i]].z
            min[0] = min(min[0], system[indicies[i]].x)
            min[1] = min(min[1], system[indicies[i]].y)
            min[2] = min(min[2], system[indicies[i]].z)
            max[0] = max(min[0], system[indicies[i]].x)
            max[1] = max(min[1], system[indicies[i]].y)
            max[2] = max(min[2], system[indicies[i]].z)
        end
        cm[0] /= m
        cm[1] /= m
        cm[2] /= m 
        split_dim = 0
        if max[1] - min[1] > max[split_dim] - min[split_dim]
            split_dim = 1
        end
        if max[2] - min[2] > max[split_dim] - min[split_dim]
            split_dim = 2
        end
        size = max[split_dim] - min[split_dim]
        # partition time
        mid = (start + ending) / 2
        s = start
        e = ending
        while s + 1 < e
            pivot = rand(s:e)
            swapTmp = indicies[s]
            indices[s] = indices[pivot]
            indices[pivot] = swapTmp
            low = s+1
            high = e-1
            while low<= high
                if #STOPPED HERE
            end
        end
    end
end

end