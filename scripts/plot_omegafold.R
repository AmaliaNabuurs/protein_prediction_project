# loda packages
library(ggplot2)
library(dplyr)
library(tidyverse)

# load files with the names of the pdbs
# set directory where files are located
directory <- "protein_prediction_project/20230503_AN_OmegaFold/data/processed/20231204_model2_OmegaFold"

# get the list of files paths 
file_list <- list.files(directory, pattern = "*.pdb", full.names = TRUE)

# create empty list to store data
omegafold_list <- list()

for (i in seq_along(file_list)) {
  file <- file_list[i]
  data <- read.delim(file, header = FALSE, sep = "")
  name <- tools::file_path_sans_ext(basename(file))
  omegafold_list[[name]] <- data
}

# Define a function to keep the first occurrence of each unique value in column V6 for a single dataframe
subset_df <- function(df) {
  df %>%
    group_by(V6) %>%
    slice(1)
}

# Apply the function to each dataframe in the list using map()
subset_omegafold_list <- map(omegafold_list, subset_df)

# Create graph

# Create an empty list to store the plots
plot_list_omegafold <- list()

# Generate a plot for each data file with the corresponding name in the title
for (i in seq_along(omegafold_list)) {
  data <- omegafold_list[[i]]
  
  # Extract the name from the list element
  name <- names(omegafold_list)[i]
  
  # Create the plot with the name in the title
  p <- ggplot(data, aes(x = V6, y = V11)) +
    geom_line() +
    ylim(0,100) +
    geom_hline(yintercept=70, color = "orange", linetype = "dashed") +
    geom_hline(yintercept=90, color = "green", linetype = "dashed") +
    geom_hline(yintercept=50, color = "red", linetype = "dashed") +
    geom_hline(yintercept=0, color = "darkred", linetype = "dashed") +
    scale_x_continuous(breaks = data$V6, labels = data$V4) +
    xlab("Residue") +
    ylab("pLDDT score") +
    ggtitle(paste(name)) 
  
  # Store the plot in the list
  plot_list_omegafold[[i]] <- p
}

print(plot_list_omegafold)

# Create graph -> for the subset plot

# Create an empty list to store the plots
plot_list_omegafold_subset <- list()

# Generate a plot for each data file with the corresponding name in the title
for (i in seq_along(subset_omegafold_list)) {
  data <- subset_omegafold_list[[i]]
  
  # Extract the name from the list element
  name <- names(subset_omegafold_list)[i]
  
  # Create the plot with the name in the title
  p <- ggplot(data, aes(x = V6, y = V11)) +
    geom_line() +
    ylim(0,100) +
    geom_hline(yintercept=70, color = "orange", linetype = "dashed") +
    geom_hline(yintercept=90, color = "green", linetype = "dashed") +
    geom_hline(yintercept=50, color = "red", linetype = "dashed") +
    geom_hline(yintercept=0, color = "darkred", linetype = "dashed") +
    scale_x_continuous(breaks = data$V6, labels = data$V4) +
    xlab("Residue") +
    ylab("pLDDT score") +
    ggtitle(paste(name)) 
  
  # Store the plot in the list
  plot_list_omegafold_subset[[i]] <- p
}

print(plot_list_omegafold_subset)

