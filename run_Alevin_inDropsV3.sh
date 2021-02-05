
#!/bin/bash

# Bash script for aligning an inDrops V3 library to a Salmon index using Alevin
#
# Salmon-Alevin requires all metadata sequences (cell barcodes and UMI) to be contained within a single FASTQ file
# inDropsV3 libraries, however, collect barcode information from two FASTQ files (R2 and R4). FASTQ files for 
# R2 and R4 must therefore be merged prior to running this script, using "convert_inDropsFASTQV3_to_Alevin.sh"
#
# REQUIRED INPUTS:
# 1. A FASTQ file containing biological reads, e.g. DEW101.R1.fastq.gz
# 2. A FASTQ file containing metadata reads (cell barcodes + UMI), e.g. DEW101.R2R4.fastq.gz 
# 3. A prebuilt Salmon index
# 4. A transcript-to-gene mapping file
# 5. An inDrops V3 barcode whitelist 
#
# USAGE:
# Complete the user specified inputs below.
# This script can process a single library or a list of libraries.
# For each basename appearing in "list_of_fastq_basenames", this script expects two FASTQ files named as:
# (1) basename.R1.FASTQ.gz
# (2) basename.R2R4.FASTQ.gz
#

# User-specified inputs:
list_of_fastq_basenames=(DEW102)
path_to_fastq_files='/Users/dwagner2/Dropbox/Postdoc/Data/FASTQ/180503_zf2018/FASTQs'
path_to_salmon_index='/Users/dwagner2/Box/Box_Home/WAGNER_LAB_SHARED/Dan_Wagner/TRANSCRIPTOME_REFS/salmon_index_grcz11_combined'
path_to_t2g_map='/Users/dwagner2/Box/Box_Home/WAGNER_LAB_SHARED/Dan_Wagner/TRANSCRIPTOME_REFS/salmon_index_grcz11_combined/txp2gene.tsv'
path_to_whitelist='/Users/dwagner2/Box/Box_Home/WAGNER_LAB_SHARED/Dan_Wagner/TRANSCRIPTOME_REFS/inDrops_whitelists/inDropsv3_whitelist.txt' 
output_path='/Users/dwagner2/Code/Salmon/Alevin-Mappings'  

# CODE TO EXECUTE ALEVIN (don't edit this part)
eval "$(conda shell.bash hook)"
conda activate salmon

for bname in ${list_of_fastq_basenames[@]}
do        
    echo Mapping $bname 
	salmon alevin -lISR -1 $path_to_fastq_files/${bname}.R2R4.fastq.gz -2 $path_to_fastq_files/${bname}.R1.fastq.gz --read-geometry 2[1-end] --bc-geometry 1[1-16] --umi-geometry 1[17-22] -i $path_to_salmon_index --whitelist $path_to_whitelist -p 8 -o $output_path/$bname --tgMap $path_to_t2g_map --dumpMtx
done