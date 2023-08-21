#!/bin/bash

# inDropsV3 FASTQ conversion
# Bash script for converting inDrops V3 FASTQs so that they can be read by modern alignment software.
#
# This script combines inDrops V3 reads R2 and R4 into a single 'R2R4' FASTQ file in which the first
# 16bp are the cell barcode and the last 6bp is the UMI (8+8+6 = 22bp).
#
# inDrops V3:
# R1 = biological read
# R2 = gel barcode part 1 (8bp)
# R3 = library index (unnecessary post-demultiplexing)
# R4 = gel barcode part 2 (8bp) + UMI (6bp) = 14bp total
# 
# CODE:

# Merge barcode reads for each set of FASTQ files in the current working directory
for filename in *R1.fastq.gz; do

    # get the base filename for each set of reads
    basename=$(echo $filename | sed 's/R1.fastq.gz//')

    echo Combining barcodes for ${basename:0:-1}
	
    # concatenate R2 and R1 sequences
	paste <(zcat < ${basename}R2.fastq.gz) <(zcat < ${basename}R4.fastq.gz) | paste - - - - | awk -F'\t' '{OFS="\n"; print $1,$3$4,$5,$7$8}' | gzip - > ${basename}R2R4.fastq.gz

done

