using Pkg
Pkg.activate("C:\\Users\\WINDOWS11\\Desktop\\2024-2\\CTM3020")

# Calling Packages
using Graphs
using GraphRecipes  # For graph plotting
using Plots # For plotting
using DataFrames
using StatsBase
using CSV

##### CSV - Original Network ##### 

# Read CSV file
file_path = "C:\\Users\\WINDOWS11\\Desktop\\2024-2\\CTM3020\\Research\\web-Yonsei\\web_yonsei_72h_id.csv"

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

##### BA Network Generation and Plotting ##### 

# Set parameters for BA network
n = 760260  # Number of nodes
total_edges = 46256733  # Target number of edges
m = Int(round(2 * total_edges / n))  # Calculate m (approximate number of edges per new node)

# Create a Barabási-Albert network with n nodes and each new node connecting to m existing nodes
ba_network = barabasi_albert(n, m)

# Efficiently calculate in-degrees and out-degrees for BA network
ba_in_degree_counts = Dict{Int,Int}()
ba_out_degree_counts = Dict{Int,Int}()

for node = 1:n
    in_deg = indegree(ba_network, node)
    out_deg = outdegree(ba_network, node)

    # Update in-degree frequency counts
    if haskey(ba_in_degree_counts, in_deg)
        ba_in_degree_counts[in_deg] += 1
    else
        ba_in_degree_counts[in_deg] = 1
    end

    # Update out-degree frequency counts
    if haskey(ba_out_degree_counts, out_deg)
        ba_out_degree_counts[out_deg] += 1
    else
        ba_out_degree_counts[out_deg] = 1
    end
end

# Extract in-degree values and frequencies for BA network
ba_in_degrees = collect(keys(ba_in_degree_counts))
ba_in_frequencies = collect(values(ba_in_degree_counts))

# Extract out-degree values and frequencies for BA network
ba_out_degrees = collect(keys(ba_out_degree_counts))
ba_out_frequencies = collect(values(ba_out_degree_counts))

# Filter out zero-degree values for both in-degrees and out-degrees of BA network
valid_in_indices = ba_in_degrees .> 0
valid_out_indices = ba_out_degrees .> 0

ba_in_degrees_filtered = ba_in_degrees[valid_in_indices]
ba_in_frequencies_filtered = ba_in_frequencies[valid_in_indices]

ba_out_degrees_filtered = ba_out_degrees[valid_out_indices]
ba_out_frequencies_filtered = ba_out_frequencies[valid_out_indices]

##### Plotting Degree Distributions ##### 

# Scatter plot for NotreDame in-degree distribution
scatter(
    in_degrees,
    in_frequencies,
    xlab = "Number of Links (k)",
    ylab = "Number of Nodes with k Links",
    title = "In-Degree Dist - Original vs BA (Directed)",
    label = "Original In-Degree Distribution",
    legend = :topright,
    markersize = 2,
    markercolor = :blue,
    markerstrokecolor = :blue,
    xscale = :log10,
    yscale = :log10,
)

# Scatter plot for BA in-degree distribution
scatter!(
    ba_in_degrees_filtered,
    ba_in_frequencies_filtered,
    label = "BA In-Degree Distribution",
    markersize = 2,
    markercolor = :orange,
    markerstrokecolor = :orange,
)

# Scatter plot for Yonsei out-degree distribution
scatter(
    out_degrees,
    out_frequencies,
    xlab = "Number of Links (k)",
    ylab = "Number of Nodes with k Links",
    title = "Out-Degree Dist - Original vs BA (Directed)",
    label = "Original Out-Degree Distribution",
    legend = :topright,
    markersize = 2,
    markercolor = :green,
    markerstrokecolor = :green,
    xscale = :log10,
    yscale = :log10,
)


# Scatter plot for BA out-degree distribution
scatter!(
    ba_out_degrees_filtered,
    ba_out_frequencies_filtered,
    label = "BA Out-Degree Distribution",
    markersize = 2,
    markercolor = :red,
    markerstrokecolor = :red,
)
