#!/bin/bash

######################################################################
#
# Authors: A.J.M.nabuurs-3@prinsesmaximacentrum.nl
# Date:    26-06-2023
#
######################################################################

set -uo pipefail

# $1 is the input fasta file with microprotein amino acid sequence, it will be used as input for all tools
# $2 is the output directory, in this a directory per tool will be made (when it is not present already) in which the output (intermediate files)
#       will be located after the pipeline is ran
# $3 a run identifier can be used to be used in the names of the output files
# $4 name of the output.tsv file

fasta="$1"
outdir="$2"
run_identifier="$3"
output_file="$4"

# submit BLASTp script
# $ = input fasta
# $ = output.tsv of blast
# $ = output.tsv parsed

omegafold_id=$(sbatch --parsable /hpc/pmc_vanheesch/projects/Amalia/20230503_AN_peptide_prediction_project/20230623_AN_pipeline/code/omegafold/omegafold_model2.sh \
    "$fasta" \
    "$outdir/omegafold" \
    "parsed_omegafold_$run_identifier.tsv")

# submit OmegaFold script
# $ = input fasta
# $ = output dir
# $ = output.tsv parsed

BLASTp_id=$(sbatch --parsable /hpc/pmc_vanheesch/projects/Amalia/20230503_AN_peptide_prediction_project/20230623_AN_pipeline/code/BLASTp/BLASTp_remote.sh \
    "$fasta" \
    "$outdir/BLASTp/BLASTp_$run_identifier.out" \
    "$outdir/BLASTp/parsed_BLASTp_$run_identifier.tsv")

# submit deepTMHMM script
# $ = input fasta
# $ = output dir
# $ = output.tsv parsed

deepTMHMM_id=$(sbatch --parsable /hpc/pmc_vanheesch/projects/Amalia/20230503_AN_peptide_prediction_project/20230623_AN_pipeline/code/deepTMHMM/deepTMHMM.sh \
    "$fasta" \
    "$outdir/deepTMHMM" \
    "parsed_deepTMHMM_$run_identifier.tsv")

# submit script that merges all output files together into a big file
# $ = all output.tsv parsed
# $ = out_file.tsv

sbatch --dependency=afterok:$omegafold_id,$BLASTp_id,$deepTMHMM_id /hpc/pmc_vanheesch/projects/Amalia/20230503_AN_peptide_prediction_project/20230623_AN_pipeline/code/merge_files.sh \
    "$outdir/omegafold/parsed_omegafold_$run_identifier.tsv" "$outdir/BLASTp/parsed_BLASTp_$run_identifier.tsv" "$outdir/deepTMHMM/parsed_deepTMHMM_$run_identifier.tsv" \
    "$outdir/$output_file"