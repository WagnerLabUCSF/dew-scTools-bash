#!/bin/bash

# InDropsV3 FASTQ Conversion
# Bash script for converting legacy inDrops FASTQ's (V1/V2) into a V3-compatible format 
#
# Description:
# This shell script will convert a metadata FASTQ file from legacy inDrops libraries (V1 or V2) into two V3-compatible FASTQ files.  
# Legacy metadata reads contain the cell barcode split into two parts, a fixed "W1" sequence, and the UMI. In inDrops V1/V2, barcode part 1 lengths are variable 8-11bp, 
# however only the first 8bp are needed to distinguish barcodes.
#
# This script will split this large metadata read into a V3-like R2 file (cell barcode part 1 -8bp), and a V3-like R4 file (cell barcode part 2 - 8bp, and the UMI -6bp).
# For V1 libraries, the combined metadata read is R1. For V2 libraries, the metadata read is R2.
# 
# Dependencies:
# Dependencies include cutadapt, seqkit, and/or seqtk. One can install these tools in a dedicated conda environment that will be accessed by the script:
# conda create --name seqtools python=3.7
# conda activate seqtools
# conda config --add channels conda-forge
# conda config --add channels bioconda
# conda install seqtk seqkit cutadapt
#
# Usage:
# Names of one or more metadata FASTQ files for conversion are inputted directly from the command line - wildcards accepted.  
# Examples: 
# source convert_inDropsFASTQV1V2_to_V3.sh DEW016.V2.R2.fastq.gz DEW017.V2.R2.fastq.gz
# source convert_inDropsFASTQV1V2_to_V3.sh DEW0*.V2.R2.fastq.gz
#
# Output files will be written with the suffices "basename.V3.R2.fastq.gz" and "basename.V3.R4.fastq.gz". The "basename" is inferred from the first input file.
#


# CODE:
# activate a prebuilt conda environment containing the required packages
eval "$(conda shell.bash hook)"
conda activate seqtools

# input the user-specified filenames as an array
input=( "$@" )

# loop through each file and parse into V3-like R2 and R4 FASTQs
for fname in ${input[@]}
do    
    echo Parsing $fname
    
    # basename for output files is the input filename up to the first ".", "_", or "-" 
    basename=$(echo $fname | awk -F '[._-]' '{print $1 }')
    
    # generate V3-like R4 fastq file (extracts 14 bases to the right of the W1 sequence)
	cutadapt -j 0 -g GAGTGATTGCTTGTGACGCCTT -e 0.2 -l 14 $fname | gzip > $basename.V3.R4.fastq.gz
    
    # generate V3-like R2 fastq file (extracts 8 bases to the left of the W1 sequence - all on the reverse complement strand)
	seqkit seq --reverse --complement --seq-type dna -v -j 2 $fname | cutadapt -j 0 -g AAGGCGTCACAAGCAATCACTC -e 0.2 -l 8 - | gzip > $basename.V3.R2.fastq.gz
    
    # generate V3-like R2 fastq file (alternate command using seqtk; WARNING - seqtk is faster than seqkit, but will corrupt the FASTQ file format if/when it encounters rare empty reads)
	#seqtk seq -r $fname | cutadapt -j 0 -g AAGGCGTCACAAGCAATCACTC -e 0.2 -l 8 - | gzip > $basename.V3.R2.fastq.gz

done

