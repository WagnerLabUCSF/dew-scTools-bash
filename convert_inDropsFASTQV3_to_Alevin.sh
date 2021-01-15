#!/bin/bash

# InDropsV3 FASTQ conversion
# Bash script for converting inDrops V3 FASTQs so that they can be read by Salmon-Alevin
#
# inDrops V3:
# R1 = biological read
# R2 = gel barcode part 1 (8bp)
# R3 = library index (unnecessary post-demultiplexing)
# R4 = gel barcode part 2 ; UMI (8 + 6 = 14bp total)
# 
# Salmon-Alevin requires all of the barcode information to be present on a in a single FASTQ read.  
# This script combines R2 and R4 into a single 'R2R4' FASTQ file where each read is now 8+8+6 = 22bp
# 
# Examples: 
# 'source convert_inDropsFASTQV3_to_Alevin.sh DEW101'
# This will combine metadata reads DEW101.R2.fastq.gz and DEW101.R4.fastq.gz and write the file DEW101.R2R4.fastq.gz
# 
# 'source convert_inDropsFASTQV3_to_Alevin.sh DEW101 DEW102 DEW103'
# This will perform multiple conversions for each set of FASTQ files

# CODE:
# input the user-specified FASTQ file basenames as an array
input=( "$@" )

# loop through each set of FASTQ files
for bname in ${input[@]}
do    
    
    echo Combining barcodes for $bname 
	
	# concatenate R2 and R4 sequences for each read
	paste <(zcat < ${bname}.R2.fastq.gz) <(zcat < ${bname}.R4.fastq.gz) | paste - - - - | awk -F'\t' '{OFS="\n"; print $1,$3$4,$5,$7$8}' | gzip - > ${bname}.R2R4.fastq.gz

done