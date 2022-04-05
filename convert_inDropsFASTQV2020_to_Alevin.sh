#!/bin/bash

# InDropsV2020-Alevin FASTQ conversion
# Bash script for converting inDrops V2020 FASTQs so that they can be read by Salmon-Alevin
#
# Salmon-Alevin requires all of the barcode information to be present on a in a single FASTQ read.  
# This script combines inDrops V2020 reads R1 and R2 into a single 'R1R2' FASTQ file in which the first
# 16bp are the cell barcode and the last 8bp is the UMI (8+8+8 = 24bp).
#
# inDrops V3:
# R1 = gel barcode part 2 (8bp) + UMI (8bp) = 16bp total 
# R2 = gel barcode part 1 (8bp)
# R3 = biological read
# I1 = library index (unnecessary post-demultiplexing)
#
# Usage: 
# 'source convert_inDropsFASTQV2020_to_Alevin.sh scNAS001_S1'
# This will combine metadata reads scNAS001_S1_R2_001.fastq.gz and scNAS001_S1_R1_001.fastq.gz and write the file scNAS001_S1_R1R2_001.fastq.gz
# 
# 'source convert_inDropsFASTQV2020_to_Alevin.sh scNAS001 scNAS002 scNAS003'
# This will perform multiple conversions for each set of FASTQ files

# CODE:
# input the user-specified FASTQ file basenames as an array
input=( "$@" )

# loop through each set of FASTQ files
for bname in ${input[@]}
do    
    
    echo Combining barcodes for $bname 
	
	# concatenate R2 and R1 sequences for each read
	paste <(zcat < ${bname}_R2_001.fastq.gz) <(zcat < ${bname}_R1_001.fastq.gz) | paste - - - - | awk -F'\t' '{OFS="\n"; print $1,$3$4,$5,$7$8}' | gzip - > ${bname}_R1R2.fastq.gz

done