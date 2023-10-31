#!/bin/bash

###############################
### To be changed every run ###
###############################

export wd="/hpc/pmc_vanheesch/projects/Amalia/protein_prediction_project/20230623_AN_pipeline"
export project_data_folder="${wd}/data/raw"
export outdir="${wd}/analysis"
export scriptdir="${wd}/code"
export input_fasta="${project_data_folder}/NBL_patient_sequences_subset_full.fasta"
export apptainer_dir="/hpc/local/Rocky8/pmc_vanheesch/singularity_images"

#######################
### Reference files ###
#######################

export model_omegafold="${project_data_folder}/omegafold_model/model2.pt"
export elm_classes="${project_data_folder}/elm_classes.tsv"

#######################
### Module versions ###
#######################

export python_version=3.11.3
export r_version=4.3.0