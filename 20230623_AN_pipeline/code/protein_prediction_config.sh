#!/bin/bash

###############################
### To be changed every run ###
###############################

export wd="/hpc/pmc_vanheesch/projects/Amalia/protein_prediction_project/20230623_AN_pipeline"
export project_data_folder="${wd}/data/raw"
export outdir="${wd}/analysis"
export scriptdir="${wd}/code"
export input_fasta="${project_data_folder}/20230306_NBL_peptide_seq.fasta"
export apptainer_dir="/hpc/local/Rocky8/pmc_vanheesch/singularity_images"

#######################
### Reference files ###
#######################

export model_omegafold="${project_data_folder}/omegafold_model/model2.pt"

#######################
### Module versions ###
#######################

export python_version=3.11.3
export r_version=4.3.0

###########################
### Resource allocation ###
###########################

# low_mem=8G
# medium_mem=48G
# high_mem=200G
# low_cpu=1
# medium_cpu=6
# high_cpu=16