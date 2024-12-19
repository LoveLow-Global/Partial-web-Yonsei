using Graphs # barabasi_albert
using GraphRecipes  # For graph plotting
using Plots # For plotting
using CSV # For reading CSV files
using DataFrames # DataFrames
using StatsBase

file_path = "C:\\Users\\WINDOWS11\\Desktop\\2024-2\\CTM3020\\Research\\web-Yonsei\\web_yonsei_72h_id.csv"

# Data
data = CSV.read(file_path, DataFrame)

# Building graph using adjacency
#connections = vcat(data.id_1, data.id_2)
connections = vcat(data.FromNodeId, data.ToNodeId)
unique_nodes = unique(connections)
degree_counts = countmap(connections)

degree_distribution = [count for (node, count) in degree_counts]

# Sort degree distribution for better visualization
sorted_degrees = sort(degree_distribution, rev = true)

# Create a scatter plot for the degree distribution with logarithmic scale
scatter(
    1:length(sorted_degrees),
    sorted_degrees,
    xlab = "Node Rank",
    ylab = "Degree",
    title = "Degree Distribution Scatter Plot (Log Scale)",
    label = "Degree Distribution",
    legend = false,
    markersize = 3,
    markerstrokecolor = :auto,
    xscale = :log10,
    yscale = :log10,
)

scatter(
    1:length(sorted_degrees),
    sorted_degrees,
    xlab = "Node Rank",
    ylab = "Degree",
    title = "Degree Distribution Scatter Plot (Plain)",
    label = "Degree Distribution",
    legend = false,
    markersize = 3,
    markerstrokecolor = :auto,
)
