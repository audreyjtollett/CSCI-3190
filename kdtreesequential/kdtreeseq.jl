module kdtreeseq
# KD-Tree Sequential, single struct for nodes
# Audrey

# Constants
const MAX_PARTS = 7
const THETA = 0.3


struct KDTree
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

end