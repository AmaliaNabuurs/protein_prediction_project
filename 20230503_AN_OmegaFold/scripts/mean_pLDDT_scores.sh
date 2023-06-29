#!/bin/bash

# 14-06-2023 AN
# A simple bash loop to calculate the mean pLDDT score of a predicted OmegaFold structure
# $1 is the input file, this is a txt file with per line the location of the pdb file predicted by OmegaFold (can be created by: ls -1 /hpc/...)
# $2 is the output file you can name yourself

# Initialize variables
output_file="$1/$2"

# Add the header to the output file
echo -e "protein_id\tmean_pLDDT_OmegaFold" > "$output_file"

# Read each line from the file specified in $2/overview_pdb_files.txt
while IFS= read -r line
do
  # Calculate the average of the 11th column using awk
  average=$(awk '{ total += $11; count++ } END { print total/count }' "$line")
  
  # Extract the protein_id from the line
  protein_id=$(basename "$line" | sed 's/\.pdb$//')
  
  # Append the protein_id and average to the output file
  echo -e "$protein_id\t$average" >> "$output_file"
done < "$1/overview_pdb_files.txt"