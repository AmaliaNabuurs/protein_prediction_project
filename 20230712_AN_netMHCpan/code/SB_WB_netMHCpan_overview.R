library(tidyverse)
library(magrittr)

# define the arguments needed to run the script
args <- commandArgs(trailingOnly = TRUE)

if (length(args) < 2) {
  stop("Usage: Rscript SB_WB_netMHCpan_overview.R input_file output_file")
}

input_file <- args[1]
output_file <- args[2]

# Load in the data
netMHCpan_output <- read.table(input_file, sep = '\t', 
                               header = TRUE)

# Group and summarize for strong binders
filtered_netMHCpan_strongbinders <- netMHCpan_output %>%
  filter(rowSums(select(., starts_with("HLA")) < 0.5) >= 1)

netMHCpan_overview_SB <- filtered_netMHCpan_strongbinders %>%
  group_by(ID) %>%
  summarize(Peptides_SB = paste(trimws(Peptide), collapse = ","))

# Group and summarize for weak binders
filtered_netMHCpan_weakbinders <- netMHCpan_output %>%
  filter(rowSums(select(., starts_with("HLA")) > 0.5 & select(., starts_with("HLA")) < 2, na.rm = TRUE) >= 1)

netMHCpan_overview_WB <- filtered_netMHCpan_weakbinders %>%
  group_by(ID) %>%
  summarize(Peptides_WB = paste(trimws(Peptide), collapse = ","))

# Merge strong and weak binders data
SB_WB_netMHCpan <- merge(netMHCpan_overview_SB, netMHCpan_overview_WB, by = "ID", all = TRUE)

# Rename ID column of protein_id
SB_WB_netMHCpan %<>%
  rename(
    protein_id = ID
  )

# Write results to analysis directory on HPC
write.table(SB_WB_netMHCpan, file = output_file, sep = '\t', quote = FALSE, row.names = FALSE)
