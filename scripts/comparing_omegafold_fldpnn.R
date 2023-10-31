# load packages
library(ggplot2)
library(tidyverse)
library(readr)
library(dplyr)
library(grid)
library(lattice)
library(gridExtra)

# read csv file
fldpnn_results <- read_csv("protein_prediction_project/20230503_AN_flDPnn/analysis/fldpnn_results.csv", 
                           col_names = FALSE, locale = locale())

# writing the csv file to a list of dataframes
write.table(fldpnn_results, "protein_prediction_project/20230503_AN_flDPnn/analysis/tmp.csv", na ="", row.names = FALSE, 
            col.names = FALSE, sep = ",")

tmp_csv <- read_csv("protein_prediction_project/20230503_AN_flDPnn/analysis/tmp.csv", col_names = F)

tmp <- readLines("protein_prediction_project/20230503_AN_flDPnn/analysis/tmp.csv")

# start of each df
sof <- grep(">", tmp)

# the actual start is one past that
real_start <- sof + 1

# figure out the end of each unique df
real_end <- c(sof[-1] - 1, length(tmp))

# the number of rows to read in
to_read <- real_end - real_start

# a list to store data.frames
my_dfs <- vector("list", length = length(real_start))
for(i in 1:length(my_dfs)){
  # suppressing warnings, as there are a lot that come up when a column header is not in a specific data.frame
  my_dfs[[i]] <- suppressWarnings(
    data.table::fread("protein_prediction_project/20230503_AN_flDPnn/analysis/tmp.csv",
                      skip = sof[i],
                      nrows = to_read[i],
                      fill = FALSE,
                      check.names = FALSE,
                      data.table = FALSE,
                      select = c("Residue Number", "Residue Type", "Predicted Score for Disorder", "Binary Prediction for Disorder", "rdp_r", "rdp_d", "rdp_p", "dfl", "fmorf")
    )
  )
}

# fixing the names of the data frames as ORF_IDs
df_names <- tmp_csv[sof,] 
names(my_dfs) <- gsub(">", "", df_names$X1)

colnames <- c("Residue_Type", "Predicted_Score_for_Disorder", "Binary_Prediction_for_Disorder", "rdp_r", "rdp_d", "rdp_p", "dfl")

#seperate the different dataframes in seperate dataframes
my_dfs_right_name <- lapply(my_dfs, setNames, colnames)
#list2env(lapply(my_dfs, setNames, colnames), .GlobalEnv)

# Plotting the disorder scores of the proteins with plot titles
graph <- lapply(seq_along(my_dfs_right_name), function(i) {
  x <- my_dfs_right_name[[i]]
  data <- x %>%
    mutate(Position = row_number()) %>%
    arrange(Position)
  ggplot(data, aes(x = Position, y = Predicted_Score_for_Disorder)) +
    geom_line() + 
    ylim(0, 1) +
    theme_bw() +
    xlab("Residue") +
    geom_hline(yintercept = 0.33, color = "red") +
    scale_x_continuous(breaks = data$Position, labels = data$Residue_Type) +
    ggtitle(names(my_dfs_right_name)[i])
})

print(graph)

