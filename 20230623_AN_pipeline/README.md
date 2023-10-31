# Protein prediction pipeline
## Introduction
All code for the protein prediction pipeline is on this github. The pipeline is created to predict and calculate several characteristics of (micro)proteins. These characteristics can be important gain in insight in their potential function or localisation. The pipeline makes predictions based on amino acid sequence of the proteins, as input a fasta file with amino acid sequences is needed. Several tools are ran parallel. These tools include, BLASTp[^1], IUPred 3.0[^2], SignalP 6.0[^3], DeepTMHMM[^4], OmegaFold[^5], netMHCpan[^6], SLiM search[^7] and a R script that  predicts several characteristics as their hydophobicity, charge etc [^8].  

The code for running the protein prediction pipeline can be found in the /code directory. The code is seperated per part of the pipeline.

## Before running the pipeline
### Important apptainer containers
Containers that are needed for the pipeline with corresponding docker links:
- ncbi BLAST container
- signalP container
- deepTMHMM container
- OmegaFold container
- R container
    - magrittr
    - tidyverse
    - Biostrings
    - stringr
    - dplyr 
    - Peptides
    - ggplot2
- Python container
    - requirements.txt file
- IUPred 3.0 container
- netMHCpan container
The containers made specifically for the project can be found on git@github.com:AmaliaNabuurs/dockerfiles.git 

The containers need to be installed with docker or apptainer for the code to work. In this case the whole pipeline is written to be used with apptainer containers that are in one directory.

### Important download files that the pipeline needs
Download files that are needed for the pipeline:
- Weighted model of OmegaFold (this automaticallhy gets downloaded the first time you run the pipeline)
    - Model 2 is used for the report and in the pipeline
    - Weights file can also be found under /data/raw/model-2.pt
- ELM classes file in tsv format
    - Version used for the report can be found on github /data/raw/elm_classes.tsv and is downloaded on 
    - Currens version can be downloaded on http://elm.eu.org/downloads.html#classes under /elms/elms_index.tsv

The download files will also be downloaded when this git is cloned.

### Config file for the pipeline
Per run the config_file.sh must be altered to represent the directories you are working in and the input fasta.
Important things for every run: 
- Input fasta file
- Paths to the code
Important things for the first time use:
- Check whether the apptainer images are downloaded and in the right container
- Check whether the downloaded files that are needed are present
- Test pipeline with example fasta file and check with example results

## Running the pipeline
If all the files are present and checked you can simply run the pipeline with:
sh /path/to/protein_prediction_pipeline.sh -c /path/to/config/config_file.sh

## Limits of the pipeline
Current version of the pipeline, version 1.0 has limits in size of the input fasta file and minimal length of the proteins. A protein has to be at least 19 amino acids long for IUPred 3.0 to use. When a shorter protein is present the pipeline fails at the moment.
There is a maximum file size that can be used in the pipeline, when the fasta file exceeds this file size it is advised to split it in multiple smaller fasta files. 

## Outfile file format
The output file of the pipeline is in tsv format and consist of 25 columns. Every row in the output tsv file is one of the input (micro)proteins.
The column names and what is in every column:
- protein_id: the protein ID that is in the input fasta file.
- protein_sequence: the protein sequence, as in the input fasta file,
- length: the number of amino acids of the protein.
- hydrophobicity: The hydrophobicity of the protein.
- moleculairweight: The predicted moleculairweight based on the amino acid sequence of the protein.
- mass_over_charge: The mass over charge of the protein.
- instability: Instability index calculated over the protein. 
- pi_isoelectricpoint: The isoelectric point of the protein.
- charge: The charge of the protein.
- mean_pLDDT_OmegaFold: the mean pLDDT (predicted local distance difference test) score that is predicted by OmegaFold. The score ranges between 0 and 100. 
- value_per_residue_OmegaFold: the pLDDT (predicted local distance difference test) score that is predicted by OmegaFold comma seperated by residue. The score ranges between 0 and 100.
- DeepTMHMM_prediction: The prediction of DeepTMHMM which can be TM (transmembrane) GLOB (globular) SP (signal peptide) or TM+SP (transmembrane + signal peptide). 
- signalP_result: The prediction of SignalP 6.0 which can be SP (signal peptide) or NO_SP (no signal peptide).
- mean_iupred3_score: Mean iupred3 score predicted for the protein. 
- value_per_residue_iupred3: Comma seperated list of values that are the disorder scores per residue of the protein.
- Peptides_SB: All peptides comma seperated that are predicted as strong binders by netMHCpan.
- Number_SB: The sum of all strong binding peptides per protein.
- Peptides_WB: All peptides comma seperated that are predicted as weak binders by netMHCpan.
- Number_WB: The sum of all weak binding peptides per protein.
- Regex_Names_WP: The ELM classes that are found in the whole protein, names are from the elm_classes.tsv file.
- Sequences_WP: The corresponding sequences that match the regex pattern of the ELM classes from the Regex_Names_WP column.
- Regex_Count_WP: The sum of ELM classes that is found in a protein.
- Regex_Names_DP: The ELM classes that are found in the disorderd protein parts, names are from the elm_classes.tsv file.
- Sequences_DP: The corresponding sequences that match the regex pattern of the ELM classes from the Regex_Names_DP column.
- Regex_Count_DP: The sum of ELM classes that is found in the disorderd parts of the protein.

[^1]:
[^2]:
[^3]:
[^4]:
[^5]:
[^6]:
[^7]:
[^8]: