#!/bin/sh
#SBATCH -p gpu
#SBATCH -c 2
#SBATCH --time=01:00:00      # All omegafold runs are between 1 and 5 minutes depending on the amount of residues adjust time accordingly
#SBATCH --gpus-per-node=1
#SBATCH --mem=15G            # Adjust to fit memory, around 1 GB per predicted structure
#SBATCH --output=/hpc/pmc_vanheesch/projects/Amalia/20230503_AN_peptide_prediction_project/20230623_AN_pipeline/log/omegafold/slurm_%j.out

apptainer exec -B /hpc:/hpc /hpc/local/Rocky8/pmc_vanheesch/singularity_images/omegafold-1.0.0.sif \
    omegafold \
        --weights_file=/hpc/pmc_vanheesch/projects/Amalia/20230503_AN_peptide_prediction_project/20230503_AN_OmegaFold/model2.pt \
        --model 2 \
        $1 \
        $2/pdb_files

# Script that executes OmegaFold and predicts 3D structure with it
# $1 = input fasta file
# $2 = output directory (full path so /hpc/pmc_vanheesch/the/rest/here is needed)

ls -1 $2/pdb_files/*.pdb > $2/overview_pdb_files.txt

# A simple bash loop to calculate the mean pLDDT score of a predicted OmegaFold structure
# $3 is the output file you can name yourself

# Initialize variables
output_file="$2/$3"

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
done < "$2/overview_pdb_files.txt"