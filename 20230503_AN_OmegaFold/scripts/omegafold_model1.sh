#!/bin/sh
#SBATCH -p gpu
#SBATCH -c 2
#SBATCH --time=01:00:00      # All omegafold runs are between 1 and 5 minutes depending on the amount of residues adjust time accordingly
#SBATCH --gres=tmpspace:10G
#SBATCH --gpus-per-node=1
#SBATCH --mem=15G            # Adjust to fit memory, around 1 GB per predicted structure

apptainer exec -B /hpc:/hpc /hpc/local/Rocky8/pmc_vanheesch/singularity_images/omegafold-1.0.0.sif omegafold --weights_file=/hpc/pmc_vanheesch/projects/Amalia/20230503_AN_peptide_prediction_project/20230503_AN_OmegaFold/model1.pt --model 1 $1 $2

# 14-06-2023 AN
# Script that executes OmegaFold and predicts 3D structure with it
# $1 = input fasta file
# $2 = output directory
# run script with: 'sbatch omegafold_model1.sh input_fasta output_dir'