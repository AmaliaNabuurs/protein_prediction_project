#!/bin/sh
#SBATCH --time=00:30:00         # time also depends on the servers can be quick <2 mins or take longer because of the que
#SBATCH --mem=1G     
#SBATCH --output=/hpc/pmc_vanheesch/projects/Amalia/20230503_AN_peptide_prediction_project/20230623_AN_pipeline/log/BLASTp/slurm_%j.out

# node needed for executing apptainer, but due to using the -remote flag it will be submitted on the 
# blast servers which means there are minimal resouces needed to run this job

# apptainer executes command to perform remote blastp search on fasta file containing protein sequences
# it outputs a tsv file containing only the proteins WITH hits

apptainer exec -B /hpc/pmc_vanheesch:/hpc/pmc_vanheesch /hpc/local/Rocky8/pmc_vanheesch/singularity_images/ncbi_blast-2.14.0.sif \
    blastp \
        -db nr \
        -query $1 \
        -out $2 \
        -remote \
        -evalue 0.05 \
        -max_target_seqs 100 \
        -seg yes \
        -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qseq sseq"

# $1 = input fasta
# $2 = output file from the blastp search

# put header line on top of the output file

sed '1i qseqid  sseqid  pident  length  mismatch    gapopen qstart  qend    sstart  send    evalue  bitscore    qseq    sseq' $2

# script to iterate over results to find proteins that do have and that do not have results

apptainer exec -B /hpc/pmc_vanheesch:/hpc/pmc_vanheesch /hpc/local/Rocky8/pmc_vanheesch/singularity_images/blast_parser_python-1.0.sif \
    python3 /app/blastout_to_list.py \
        -b $2 \
        -f $1 \
        -o $3

# $3 = output file with the identifier and wether there is homology found for one or not
