using Pkg
Pkg.activate("C:\\Users\\WINDOWS11\\Desktop\\2024-2\\CTM3020")

# Calling Packages
using Graphs
using GraphRecipes  # For graph plotting
using Plots # For plotting
using DataFrames
using StatsBase
using CSV
using LinearAlgebra

file_path = "C:\\Users\\WINDOWS11\\Desktop\\2024-2\\CTM3020\\Research\\web-Yonsei\\web_yonsei_72h_id.csv"

# Data, Number of Links
data = CSV.read(file_path, DataFrame)

# Number of nodes
max_value = maximum(vcat(data.ToNodeId, data.FromNodeId))

# Calculate in-degrees and out-degrees
in_degree_counts = countmap(data.ToNodeId)
out_degree_counts = countmap(data.FromNodeId)

# Frequency count for each in-degree (degree distribution)
in_degree_values = collect(values(in_degree_counts))
in_degree_hist = countmap(in_degree_values)

# Extract in-degrees and their frequencies
in_degrees = collect(keys(in_degree_hist))  # Different in-degree values
in_frequencies = collect(values(in_degree_hist))  # Num. of nodes with each in-degree


# Frequency count for each out-degree (degree distribution)
out_degree_values = collect(values(out_degree_counts))
out_degree_hist = countmap(out_degree_values)

# Extract out-degrees and their frequencies
out_degrees = collect(keys(out_degree_hist))  # Different out-degree values
out_frequencies = collect(values(out_degree_hist))  # Num. of nodes with each out-degree

# Log-log scatter plot for in-degree distribution
scatter(
    in_degrees,
    in_frequencies,
    xlab = "Number of Links (k)",
    ylab = "Number of Nodes with k Links",
    title = "Partial Web Graph of Yonsei - In-Degree",
    label = "In-Degree Distribution",
    legend = :topright,
    markersize = 2,
    markercolor = :aqua,
    markerstrokecolor = :aqua,
    xscale = :log10,
    yscale = :log10,
)

# Log-log scatter plot for out-degree distribution

scatter(
    out_degrees,
    out_frequencies,
    xlab = "Number of Links (k)",
    ylab = "Number of Nodes with k Links",
    title = "Partial Web Graph of Yonsei - Out-Degree",
    label = "Out-Degree Distribution",
    legend = :topright,
    markersize = 2,
    markercolor = :orange,
    markerstrokecolor = :orange,
    xscale = :log10,
    yscale = :log10,
)

# Fitting Power-Law for In-Degree Distribution
log_in_degrees = log10.(in_degrees)
log_in_frequencies = log10.(in_frequencies)

# Remove any -Inf values (due to log10(0)) 
valid_in_indices = (log_in_degrees .> -Inf) .& (log_in_frequencies .> -Inf)
filtered_log_in_degrees = log_in_degrees[valid_in_indices]
filtered_log_in_frequencies = log_in_frequencies[valid_in_indices]

# Fit a linear model to the log-log data (Linear regression for in-degree)
X_in = hcat(ones(length(filtered_log_in_degrees)), filtered_log_in_degrees) # Add bias for intercept
coeffs_in = X_in \ filtered_log_in_frequencies  # linear regression for slope and intercept

slope_in, intercept_in = coeffs_in[2], coeffs_in[1]

println("In-Degree Slope: ", slope_in, " In-Degree Intercept: ", intercept_in)

# Plot the fitted line for In-Degree (Power-Law) on top of the scatter plot
fitted_line_in = intercept_in .+ slope_in .* log_in_degrees
plot!(
    in_degrees,
    10 .^ fitted_line_in, # Convert back from log10 values
    label = "in degrees",
    linewidth = 2,
    linecolor = :blue,
)

# Fitting Power-Law for Out-Degree Distribution
log_out_degrees = log10.(out_degrees)
log_out_frequencies = log10.(out_frequencies)

# Remove any -Inf values (due to log10(0)) 
valid_out_indices = (log_out_degrees .> -Inf) .& (log_out_frequencies .> -Inf)
filtered_log_out_degrees = log_out_degrees[valid_out_indices]
filtered_log_out_frequencies = log_out_frequencies[valid_out_indices]

# Fit a linear model to the log-log data (Linear regression for out-degree)
X_out = hcat(ones(length(filtered_log_out_degrees)), filtered_log_out_degrees) # Add bias for intercept
coeffs_out = X_out \ filtered_log_out_frequencies  # linear regression for slope and intercept

slope_out, intercept_out = coeffs_out[2], coeffs_out[1]

println("Out-Degree Slope: ", slope_out, " Out-Degree Intercept: ", intercept_out)

# Plot the fitted line for Out-Degree (Power-Law) on top of the scatter plot
fitted_line_out = intercept_out .+ slope_out .* log_out_degrees
plot!(
    out_degrees,
    10 .^ fitted_line_out, # Convert back from log10 value,
    label = "out degrees",
    linewidth = 2,
    linecolor = :red,
)
