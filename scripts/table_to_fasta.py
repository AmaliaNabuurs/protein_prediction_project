import pandas as pd
import os
import argparse

#Add parser
parser = argparse.ArgumentParser()
parser.add_argument("-i","--input_file",
                    help="input file, must be a CSV or TSV file", 
                    required = True)
parser.add_argument("-o", "--output_file",
                    help="name of the file outputted by the script, must be in FASTA format", 
                    required = True)
parser.add_argument("--ID_header",
                    help="name of the header used for the IDs of the proteins, default = ORF_ID", 
                    default = 'ORF_ID' ,required = False)
parser.add_argument("--sequence_header",
                    help="name of the header used for the sequences, default = protein", 
                    default = 'protein' ,required = False)
args = parser.parse_args()

#Specify the input file
input_file = args.input_file

#Check the file extension and read the file accordingly
if os.path.splitext(input_file)[1] == ".csv":
    df = pd.read_csv(input_file)
elif os.path.splitext(input_file)[1] == ".tsv":
    df = pd.read_csv(input_file, sep="\t")
else:
    raise ValueError("Input file must be in CSV or TSV format")

#Use the header names to extract the right columns
col_IDs = args.ID_header
col_sequences = args.sequence_header
headers = df[col_IDs].tolist()
sequences = df[col_sequences].tolist()

#Write the sequences to a FASTA file
with open(args.output_file, "w") as output_fasta:
    for i in range(len(headers)):
        output_fasta.write(">{}\n{}\n".format(headers[i], sequences[i]))