#!/bin/sh
#SBATCH --time=01:00:00      
#SBATCH --gres=tmpspace:10G      
#SBATCH --mem=10G     

# script that executes deepTMHMM and parses results to tsv format
# it is NOT runned locally, we can change this with machin = 'local' in the python script if we want to

apptainer exec -B /hpc/pmc_vanheesch:/hpc/pmc_vanheesch /hpc/local/Rocky8/pmc_vanheesch/singularity_images/deepTMHMM-1.0.24.sif \
    python3 /app/deeptmhmm.py \
        -i $1 \
        -o $2

# $1 = input fasta file
# $2 = output dir

# parse the results from deepTMHMM to format we need/want

apptainer exec -B /hpc/pmc_vanheesch:/hpc/pmc_vanheesch /hpc/local/Rocky8/pmc_vanheesch/singularity_images/parser_deepTMHMM-1.0.sif \
    python3 /app/results_parser.py \
        -i $2/predicted_topologies.3line \
        -o $2/$3

# $3 = name output.txt