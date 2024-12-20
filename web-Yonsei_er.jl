# Calling Packages
using Graphs
using GraphRecipes  # For graph plotting
using Plots # For plotting
using DataFrames
using StatsBase
using CSV

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

# Set parameters for ER network
n = 760260  # Number of nodes
m = 46256733  # Number of edges

# Create a directed Erdős-Rényi network with n nodes and m edges
er_network = erdos_renyi(n, m, is_directed = true)

# Efficiently calculate in-degrees and out-degrees
er_in_degree_counts = Dict{Int,Int}()
er_out_degree_counts = Dict{Int,Int}()

for node = 1:n
    in_deg = indegree(er_network, node)
    out_deg = outdegree(er_network, node)

    # Update in-degree frequency counts
    if haskey(er_in_degree_counts, in_deg)
        er_in_degree_counts[in_deg] += 1
    else
        er_in_degree_counts[in_deg] = 1
    end

    # Update out-degree frequency counts
    if haskey(er_out_degree_counts, out_deg)
        er_out_degree_counts[out_deg] += 1
    else
        er_out_degree_counts[out_deg] = 1
    end
end

# Extract in-degree values and frequencies for ER network
er_in_degrees = collect(keys(er_in_degree_counts))
er_in_frequencies = collect(values(er_in_degree_counts))

# Extract out-degree values and frequencies for ER network
er_out_degrees = collect(keys(er_out_degree_counts))
er_out_frequencies = collect(values(er_out_degree_counts))

# Filter out zero-degree values for both in-degrees and out-degrees of ER network
valid_in_indices = er_in_degrees .> 0
valid_out_indices = er_out_degrees .> 0

er_in_degrees_filtered = er_in_degrees[valid_in_indices]
er_in_frequencies_filtered = er_in_frequencies[valid_in_indices]

er_out_degrees_filtered = er_out_degrees[valid_out_indices]
er_out_frequencies_filtered = er_out_frequencies[valid_out_indices]

# Scatter plot for original in-degree distribution
scatter(
    in_degrees,
    in_frequencies,
    xlab = "Number of Links (k)",
    ylab = "Number of Nodes with k Links",
    title = "Degree Distribution Comparison - Original vs ER (Directed)",
    label = "Original In-Degree Distribution",
    legend = :topright,
    markersize = 2,
    markercolor = :blue,
    markerstrokecolor = :blue,
    xscale = :log10,
    yscale = :log10,
)

# Scatter plot for ER in-degree distribution (filtered for valid values)
scatter!(
    er_in_degrees_filtered,
    er_in_frequencies_filtered,
    label = "ER In-Degree Distribution",
    markersize = 2,
    markercolor = :orange,
    markerstrokecolor = :orange,
)

# Scatter plot for original out-degree distribution
scatter(
    out_degrees,
    out_frequencies,
    xlab = "Number of Links (k)",
    ylab = "Number of Nodes with k Links",
    title = "Degree Distribution Comparison - Original vs ER (Directed)",
    label = "Original In-Degree Distribution",
    legend = :topright,
    markersize = 2,
    markercolor = :green,
    markerstrokecolor = :green,
    xscale = :log10,
    yscale = :log10,
)

# Scatter plot for ER out-degree distribution (filtered for valid values)
scatter!(
    er_out_degrees_filtered,
    er_out_frequencies_filtered,
    label = "ER Out-Degree Distribution",
    markersize = 2,
    markercolor = :red,
    markerstrokecolor = :red,
)
