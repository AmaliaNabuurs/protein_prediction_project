#!/bin/sh
#SBATCH --time=00:10:00           
#SBATCH --mem=1G     
#SBATCH --output=/hpc/pmc_vanheesch/projects/Amalia/20230503_AN_peptide_prediction_project/20230623_AN_pipeline/log/slurm_%j.out

# script to merge several tsv files with overlapping column to a table
# $1 = input .tsv files, can be several (at least 2!)
# $2 = name of output file = resulting table

# Run the command with the input file arguments
apptainer exec -B /hpc/pmc_vanheesch:/hpc/pmc_vanheesch /hpc/local/Rocky8/pmc_vanheesch/singularity_images/merge_tsvfiles_python.sif \
    python3 /app/dataframe_merge.py \
        -i $1 $2 $3 \
        -o $4