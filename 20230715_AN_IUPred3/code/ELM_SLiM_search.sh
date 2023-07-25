#!/bin/bash
#SBATCH --time=01:00:00      
#SBATCH --gres=tmpspace:10G      
#SBATCH --mem=10G  

# $1 input file fasta
# #2 input directory with disorder files
# $3 input elm_classes.tsv file
# $4 output file


# Run the R script to make a overview table with ORF_id column and a column with the weak binding peptides and a column with the strong binding peptides
# Rscript SB_WB_netMHCpan_overview.R "${output_file}_summary.tsv" "${output_file}_SB_WB.tsv"
apptainer exec -B /hpc/pmc_vanheesch:/hpc/pmc_vanheesch,$TMPDIR:$TMPDIR,/hpc/local/Rocky8/pmc_vanheesch/Rstudio_Server_Libs/Rstudio_4.3.0_libs:/usr/local/lib/R/site-library /hpc/local/Rocky8/pmc_vanheesch/singularity_images/rstudio_4.3.0_bioconductor.sif \
    Rscript /hpc/pmc_vanheesch/projects/Amalia/protein_prediction_project/20230715_AN_IUPred3/code/ELM_SLiM_search.R \
        $1 \
        $2 \
        $3 \
        $4
