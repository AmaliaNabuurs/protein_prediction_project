#!/bin/bash
#SBATCH --time=01:00:00      
#SBATCH --gres=tmpspace:10G      
#SBATCH --mem=10G 

fasta_file=$1

# Read the FASTA file line by line
while IFS= read -r line
do
  # Check if the line starts with '>'
  if [[ $line == ">"* ]]; then
    # Extract the protein sequence ID
    sequence_id="${line:1}"
    echo "Submitting sequence: $sequence_id"
  else
    # Create a temporary file with the protein sequence
    tmp_file=$(mktemp)
    echo "$line" > "$tmp_file"

    apptainer exec -B /hpc/pmc_vanheesch:/hpc/pmc_vanheesch,$TMPDIR:$TMPDIR /hpc/local/Rocky8/pmc_vanheesch/singularity_images/iupred-3.0.sif\
        python3 /app/iupred3.py "$tmp_file" short > "/hpc/pmc_vanheesch/projects/Amalia/protein_prediction_project/20230715_AN_IUPred3/analysis/${sequence_id}.txt"
    
    rm "$tmp_file"
  fi
done < "$fasta_file"


# create file with paths to the created pdb files
ls -1 /hpc/pmc_vanheesch/projects/Amalia/protein_prediction_project/20230715_AN_IUPred3/analysis/*.txt > /hpc/pmc_vanheesch/projects/Amalia/protein_prediction_project/20230715_AN_IUPred3/analysis/overview_scores.tsv

# A simple bash loop to calculate the mean pLDDT score of a predicted OmegaFold structure
# Initialize variables
output_file="/hpc/pmc_vanheesch/projects/Amalia/protein_prediction_project/20230715_AN_IUPred3/analysis/parsed_iupred3.tsv"

# Add the header to the output file
echo -e "protein_id\tmean_iupred3_score" > "${output_file}"

# Read each line from the file specified in $2/overview_pdb_files.txt
while IFS= read -r line
do
  # Calculate the average of the 11th column using awk
  average=$(awk 'NR > 12 { total += $3; count++ } END { print total/count }' $line)
  
  # Extract the protein_id from the line
  protein_id=$(basename $line | sed 's/\.txt$//')
  
  # Append the protein_id and average to the output file
  echo -e "${protein_id}\t${average}" >> "${output_file}" 
done < /hpc/pmc_vanheesch/projects/Amalia/protein_prediction_project/20230715_AN_IUPred3/analysis/overview_scores.tsv