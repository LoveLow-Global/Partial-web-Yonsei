# Calling Packages
using Graphs
using GraphRecipes  # For graph plotting
using Plots # For plotting
using DataFrames
using StatsBase
using CSV
using Random # For random
using LinearAlgebra
using Statistics
using BenchmarkTools

# Read CSV file
file_path = "YOUR FILE PATH FOR THE CSV FILE"

# Data, Number of Links
data = CSV.read(file_path, DataFrame)

# Calculate in-degrees and out-degrees for the original network
in_degree_counts = countmap(data.ToNodeId)
out_degree_counts = countmap(data.FromNodeId)

# Extract in-degree values and frequencies
in_degree_values = collect(values(in_degree_counts))
in_degree_hist = countmap(in_degree_values)
in_degrees = collect(keys(in_degree_hist))
in_frequencies = collect(values(in_degree_hist))

# Extract out-degree values and frequencies
out_degree_values = collect(values(out_degree_counts))
out_degree_hist = countmap(out_degree_values)
out_degrees = collect(keys(out_degree_hist))
out_frequencies = collect(values(out_degree_hist))

# Optimized function to create a directed Bianconi-Barabási (BB) network
function bianconi_barabasi_network_directed_optimized(n, m; alpha = 1.0)
    graph = SimpleDiGraph(n)
    fitness = rand(n) .^ alpha

    # Initialize degree arrays
    in_degrees = zeros(Int, n)
    out_degrees = zeros(Int, n)

    # Start with a small fully connected network of size m
    # This creates a complete subgraph among nodes 1 to m
    for i = 1:m
        for j = i+1:m
            add_edge!(graph, i, j)
            add_edge!(graph, j, i)
            in_degrees[j] += 1
            out_degrees[i] += 1
            in_degrees[i] += 1
            out_degrees[j] += 1
        end
    end

    # Prepare weight arrays and totals
    # weights for attachment based on in-degree
    in_weights = (in_degrees .* fitness)
    out_weights = (out_degrees .* fitness)

    sum_in = sum(in_weights)      # total_in_degree_fitness
    sum_out = sum(out_weights)    # total_out_degree_fitness

    # Main loop to add new nodes
    for new_node = m+1:n
        # Only existing nodes are 1:(new_node - 1)
        existing_range = 1:(new_node-1)

        # Compute weights-based distributions for in and out attachments
        # Instead of cumulative arrays, directly use Weights from StatsBase.
        # This handles normalization internally.
        if sum_in > 0
            in_dist = Weights(in_weights[existing_range])
        else
            # If sum_in is zero, all have zero in-degree; fallback to fitness
            # (Though in practice sum_in = 0 only if all degrees are 0)
            in_dist = Weights(fitness[existing_range])
        end

        if sum_out > 0
            out_dist = Weights(out_weights[existing_range])
        else
            out_dist = Weights(fitness[existing_range])
        end

        # Sample m unique targets based on in_weights
        # These are the nodes from which the new_node will receive edges.
        in_targets = sample(existing_range, in_dist, m; replace = false)

        # Add edges from chosen in_targets to new_node
        for target in in_targets
            add_edge!(graph, target, new_node)
            # Update degrees and weights
            in_degrees[new_node] += 1
            out_degrees[target] += 1
            # Increment in_weights[new_node] and out_weights[target]
            val_new = fitness[new_node]
            val_tgt = fitness[target]
            in_weights[new_node] += val_new  # new_node gained an incoming edge
            out_weights[target] += val_tgt   # target node gained an outgoing edge
            sum_in += val_new
            sum_out += val_tgt
        end

        # Sample m unique targets based on out_weights
        # These are the nodes to which the new_node will connect outward.
        out_targets = sample(existing_range, out_dist, m; replace = false)

        # Add edges from new_node to out_targets
        for target in out_targets
            add_edge!(graph, new_node, target)
            # Update degrees and weights
            out_degrees[new_node] += 1
            in_degrees[target] += 1
            val_new = fitness[new_node]
            val_tgt = fitness[target]
            out_weights[new_node] += val_new  # new_node gained an outgoing edge
            in_weights[target] += val_tgt     # target node gained an incoming edge
            sum_out += val_new
            sum_in += val_tgt
        end
    end

    return graph, fitness
end

# Parameters for BB network
n = 760260  # Number of nodes
m = 2       # Initial connections per new node
alpha = 1.0  # Fitness distribution parameter

# Generate BB network using the optimized function
bb_network, fitness_values =
    bianconi_barabasi_network_directed_optimized(n, m, alpha = alpha)

# Calculate in-degrees and out-degrees for the BB network
bb_in_degree_counts = countmap(indegree(bb_network, v) for v = 1:n)
bb_out_degree_counts = countmap(outdegree(bb_network, v) for v = 1:n)

# Extract in-degree values and frequencies for BB network
bb_in_degrees = collect(keys(bb_in_degree_counts))
bb_in_frequencies = collect(values(bb_in_degree_counts))

# Extract out-degree values and frequencies for BB network
bb_out_degrees = collect(keys(bb_out_degree_counts))
bb_out_frequencies = collect(values(bb_out_degree_counts))

# Filter out zero-degree values for both in-degrees and out-degrees of BB network
valid_in_indices = bb_in_degrees .> 0
valid_out_indices = bb_out_degrees .> 0

bb_in_degrees_filtered = bb_in_degrees[valid_in_indices]
bb_in_frequencies_filtered = bb_in_frequencies[valid_in_indices]

bb_out_degrees_filtered = bb_out_degrees[valid_out_indices]
bb_out_frequencies_filtered = bb_out_frequencies[valid_out_indices]

# Initialize plot
scatter(
    in_degrees,
    in_frequencies,
    xlab = "Number of Links (k)",
    ylab = "Number of Nodes with k Links",
    title = "Degree Distribution Comparison - Original vs BB (Directed)",
    label = "Original In-Degree Distribution",
    legend = :topright,
    markersize = 2,
    markercolor = :blue,
    markerstrokecolor = :blue,
    xscale = :log10,
    yscale = :log10,
)

# Scatter plot for BB in-degree distribution
scatter!(
    bb_in_degrees_filtered,
    bb_in_frequencies_filtered,
    label = "BB In-Degree Distribution",
    markersize = 2,
    markercolor = :orange,
    markerstrokecolor = :orange,
)

# Scatter plot for NotreDame out-degree distribution
scatter(
    out_degrees,
    in_frequencies,
    xlab = "Number of Links (k)",
    ylab = "Number of Nodes with k Links",
    title = "Degree Distribution Comparison - Original vs BB (Directed)",
    label = "Original Out-Degree Distribution",
    legend = :topright,
    markersize = 2,
    markercolor = :green,
    markerstrokecolor = :green,
    xscale = :log10,
    yscale = :log10,
)

# Scatter plot for BB out-degree distribution
scatter!(
    bb_out_degrees_filtered,
    bb_out_frequencies_filtered,
    label = "BB Out-Degree Distribution",
    markersize = 2,
    markercolor = :red,
    markerstrokecolor = :red,
)

