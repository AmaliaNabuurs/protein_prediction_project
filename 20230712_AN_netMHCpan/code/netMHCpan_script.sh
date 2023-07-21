#!/bin/bash
#SBATCH --time=01:00:00      
#SBATCH --gres=tmpspace:10G      
#SBATCH --mem=10G    

# $1 = input fasta file
# $2 = intermediate output_fasta file
# $3 = intermediate table_file which contains the name pairs
# $4 = output .xls file -> 1 big table all HLA types after eachother

fasta_file=$1
output_fasta=$2
name_table=$3
output_file=$4

# Check if output files exist already
if [[ -f "$output_fasta" || -f "$name_table" ]]; then
    read -p "The output files already exist. Do you want to overwrite them? (y/n): " overwrite_choice

    if [[ $overwrite_choice != "y" && $overwrite_choice != "Y" ]]; then
        echo "Operation aborted. Please choose different names for output files."
        exit 1
    fi
fi

# Create a temp name file and fasta file because NetMHCPan cant handle long input names in the fasta
counter=1

while IFS= read -r line; do
    if [[ $line =~ ^\>(.*)$ ]]; then
        name="${BASH_REMATCH[1]}"
        new_name=$(printf "%015d" $counter)
        echo -e "$name\t$new_name" >> "$name_table"
        echo ">$new_name" >> "$output_fasta"
        ((counter++))
    else
        echo "$line" >> "$output_fasta"
    fi
done < "$fasta_file"

# Run NetMHCpan
apptainer exec -B /hpc/pmc_vanheesch:/hpc/pmc_vanheesch,$TMPDIR:$TMPDIR /hpc/local/Rocky8/pmc_vanheesch/singularity_images/netmhcpan-4.1b.sif \
    /app/package/netMHCpan-4.1/netMHCpan \
        -BA \
        -a HLA-A01:01,HLA-A02:01,HLA-A03:01,HLA-A24:02,HLA-A26:01,HLA-B07:02,HLA-B08:01,HLA-B27:05,HLA-B39:01,HLA-B40:01,HLA-B58:01,HLA-B15:01 \
        -xls -xlsfile "${output_file}_temp.tsv" \
        -f "$output_fasta" 

# Change the names back to the original long names

# Step 2: Use awk to process the temp_file and replace the spaces with tabs
awk -F"\t" 'FNR==NR { map[$2]=$1; next } FNR==NR { print; next } { if ($3 in map) $3=map[$3]} 1' "$name_table" "${output_file}_temp.tsv" | awk 'BEGIN { OFS="\t" } { gsub(/ /, "\t"); print }' > "${output_file}.tsv"

# print fragment number, peptide, ID and count of binders.
# copy columns of interest with awk (this changes when the amount of HLA changes)
# awk '{print $1,"\t",$2,"\t",$3,"\t",$NF}' $1 > $2

echo -e "Pos\tPeptide\tID\tHLA-A01:01\tHLA-A02:01\tHLA-A03:01\tHLA-A24:02\tHLA-A26:01\tHLA-B07:02\tHLA-B08:01\tHLA-B27:05\tHLA-B39:01\tHLA-B40:01\tHLA-B58:01\tHLA-B15:01" > "${output_file}_summary.tsv"
tail -n +3 "${output_file}.tsv" | awk 'BEGIN { OFS="\t" } {print $1, $2, $3, $7, $13, $19, $25, $31, $37, $43, $49, $55, $61, $67, $73}' >> "${output_file}_summary.tsv"

# Cleanup: Remove the temporary file
rm "$temp_file"
rm "${output_file}_temp.tsv"
rm "$name_table"
rm "$output_fasta"

# Run the R script to make a overview table with ORF_id column and a column with the weak binding peptides and a column with the strong binding peptides
# Rscript SB_WB_netMHCpan_overview.R "${output_file}_summary.tsv" "${output_file}_SB_WB.tsv"
apptainer exec -B /hpc/pmc_vanheesch:/hpc/pmc_vanheesch,$TMPDIR:$TMPDIR,/hpc/local/Rocky8/pmc_vanheesch/Rstudio_Server_Libs/Rstudio_4.3.0_libs:/usr/local/lib/R/site-library /hpc/local/Rocky8/pmc_vanheesch/singularity_images/rstudio_4.3.0_bioconductor.sif \
    Rscript /hpc/pmc_vanheesch/projects/Amalia/protein_prediction_project/20230712_AN_netMHCpan/code/SB_WB_netMHCpan_overview.R \
        "${output_file}_summary.tsv" \
        "${output_file}_SB_WB.tsv"
