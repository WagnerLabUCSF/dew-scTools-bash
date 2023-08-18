#!/bin/bash

# inDropsV2020 FASTQ conversion
# Bash script for converting inDrops V3 FASTQs so that they can be read by modern alignment software.
#
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
# The script will automatically detect sets of FASTQ files in the current working directory with shared
# base filenames and writes a merged '*R1R2.fastq.gz' file for each.
# 
# CODE:

for filename in *R1.fastq.gz; do

    # get the base filename for each set of reads
    basename=$(echo $filename | sed 's/R1.fastq.gz//')

    echo Combining barcodes for ${basename:0:-1}
	
	# concatenate R2 and R1 sequences for each read; revcomp R2
	seqkit concat <(seqkit seq --reverse --complement --seq-type 'dna' ${basename}R2.fastq.gz) ${basename}R1.fastq.gz \
    	--out-file ${basename}R1R2.fastq.gz \
    	--line-width 0 \
    	--threads 16

done


