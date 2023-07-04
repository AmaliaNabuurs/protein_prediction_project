#!/bin/bash

######################################################################
# 
# Protein prediction project pipeline
# <short description of pipeline here>
#
# Resources 
# Resources need to be alted depending on the size of the input fasta
# the BLASTp, deepTMHMM and merging of files don't need a lot of resources
# so this can stay the same. However every protein in the fasta files 
# takes 1 to 5 mins and around 1 GB memory, this had to be altered. 
#
# List of output files:
# OmegaFold:    .pdb file per microprotein sequence
# BLASTp:       all hits found with BLASTp
# DeepTMHMM:    3 files containing info about whether there is a trans 
#               membrane domain present. 
# 
# Author:   Amalia Nabuurs (A.J.M.Nabuurs-3@prinsesmaximacentrum.nl)
# Date:     26-06-2023
#
######################################################################

set -euo pipefail

function usage() {
    cat <<EOF
SYNOPSIS
  protein_prediction_pipeline.sh [-c <config file>] [-h]
DESCRIPTION
  Run the protein prediction pipeline consisting of the following steps:
  1. Predict 3D structure with OmegaFold
  2. Check for homology with BLASTp
  3. Look for transmembrane domains with DeepTMHMM
OPTIONS
  -c, --config <file>    Configuration file to use
  -h, --help             Display this help message
AUTHOR
  Amalia Nabuurs
EOF
}

# Parse command-line arguments
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -c|--config)
    CONFIG="$2"
    shift
    shift
    ;;
    -h|--help)
    usage
    exit
    ;;
    "")
    echo "Error: no option provided"
    usage
    exit 1
    ;;
    *)
    echo "Unknown option: $key"
    usage
    exit 1
    ;;
esac
done

# Check that configuration file is provided
if [[ -z ${CONFIG+x} ]]; then 
    echo "Error: no configuration file provided"
    usage
    exit 1
fi

# Load configuration variables
source $CONFIG


# Create a unique prefix for the names for this run of the pipeline
# This makes sure that runs can be identified
export run=$(uuidgen | tr '-' ' ' | awk '{print $1}')

######################################################################

# Step 1: running of several tools
# Run OmegaFold

omegafold_jobid=$(sbatch --parsable \
    -p gpu \
    -c 2 \
    --gpus-per-node=1 \
    --mem=15G \
    --time=1:00:00 \
    --job-name=${run}.omegafold \
    --output=${wd}/log/omegafold/%A.out \
    --export=ALL \
    "${scriptdir}/omegafold/omegafold_model2.sh")
echo "OmegaFold jobid: ${omegafold_jobid}"

# Run BLASTp

BLASTp_jobid=$(sbatch --parsable \
    --mem=10G \
    --time=1:00:00 \
    --job-name=${run}.BLASTp \
    --output=${wd}/log/BLASTp/%A.out \
    --export=ALL \
    "${scriptdir}/BLASTp/BLASTp_remote.sh")
echo "BLASTp jobid: ${BLASTp_jobid}"

# Run DeepTMHMM

deepTMHMM_jobid=$(sbatch --parsable \
    --mem=10G \
    --time=1:00:00 \
    --job-name=${run}.deepTMHMM \
    --output=${wd}/log/deepTMHMM/%A.out \
    --export=ALL \
    "${scriptdir}/deepTMHMM/deepTMHMM.sh")
echo "DeepTMHMM jobid: ${deepTMHMM_jobid}"

# Step 2: combine the results

sbatch --dependency=afterok:${omegafold_jobid},${BLASTp_jobid},${deepTMHMM_jobid} \
    --mem=10G \
    --time=1:00:00 \
    --job-name=${run}.merge_files \
    --output=${wd}/log/%A.out \
    --export=ALL \
    "${scriptdir}/merge_files.sh"