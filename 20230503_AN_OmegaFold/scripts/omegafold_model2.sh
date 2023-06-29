#!/bin/sh
#SBATCH -p gpu
#SBATCH -c 2
#SBATCH --time=01:00:00      # All omegafold runs are between 1 and 5 minutes depending on the amount of residues adjust time accordingly
#SBATCH --gres=tmpspace:10G
#SBATCH --gpus-per-node=1
#SBATCH --mem=15G            # Adjust to fit memory, around 1 GB per predicted structure
#SBATCH --output=/hpc/pmc_vanheesch/projects/Amalia/20230503_AN_peptide_prediction_project/20230503_AN_OmegaFold/log/slurm_%j.out

apptainer exec -B /hpc:/hpc /hpc/local/Rocky8/pmc_vanheesch/singularity_images/omegafold-1.0.0.sif \
    omegafold \
        --weights_file=/hpc/pmc_vanheesch/projects/Amalia/20230503_AN_peptide_prediction_project/20230503_AN_OmegaFold/model2.pt \
        --model 2 \
        $1 \
        $2

# Script that executes OmegaFold and predicts 3D structure with it
# $1 = input fasta file
# $2 = output directory (full path so /hpc/pmc_vanheesch/the/rest/here is needed)

ls -1 $2/*.pdb > $2/overview_pdb_files.txt

# A simple bash loop to calculate the mean pLDDT score of a predicted OmegaFold structure
# $3 is the output file you can name yourself

while IFS= read -r line
do
  awk -v line="$line" '{ total += $11; count++ } END { print line "\t" total/count }' $line >> $2/$3
done < $2/overview_pdb_files.txt

# remove paths
sed -i 's:.*/::' $2/$3