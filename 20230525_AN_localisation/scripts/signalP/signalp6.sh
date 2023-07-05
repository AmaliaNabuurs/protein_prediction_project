#!/bin/bash
#SBATCH --time=01:00:00           
#SBATCH --mem=10G     

# script that executes signalp and parses results to tsv format

apptainer exec -B /hpc/pmc_vanheesch:/hpc/pmc_vanheesch /hpc/local/Rocky8/pmc_vanheesch/singularity_images/signalp-6.0-fast.sif \
    signalp6 \
        --fastafile $1 \
        --output_dir $2 \
        --format txt \
        --organism eukarya \
        --mode fast

# $1 = input fasta file
# $2 = output dir

# parse the results from SignalP to tsv

echo -e "protein_id\tsignalP_result" > $2/$3
sed 's/#//' $2/prediction_results.txt | tail -n +3 | awk '{print $1"\t"$2}' >> $2/$3


# $3 results.tsv

