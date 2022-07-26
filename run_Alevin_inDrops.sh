#!/bin/bash                        #-- what is the language of this shell
#                                  #-- Any line that starts with #$ is an instruction to SGE
#$ -S /bin/bash                    #-- the shell for the job
#$ -o alevin_log                   #-- output directory
#$ -e alevin_err                   #-- error directory
#$ -cwd                            #-- tell the job that it should start in your working directory
#$ -r y                            #-- tell the system that if a job crashes, it should be restarted
#$ -j y                            #-- tell the system that the STDERR and STDOUT should be joined
#$ -l mem_free=2G                  #-- submits on nodes with enough free memory (required)
#$ -l scratch=50G                  #-- SGE resources (home and scratch disks)
#$ -l h_rt=2:00:00                #-- runtime limit (hr:min:sec)


# Use this bash script for aligning an inDrops V2020 library to a Salmon index using Alevin
#
# Salmon-Alevin requires all metadata sequences (cell barcodes and UMI) to be contained within a single FASTQ file
# inDrops libraries, however, collect barcode information from two FASTQ files (R2 and R4). FASTQ files for 
# R2 and R4 must therefore be merged prior to running this script, using "convert_inDropsFASTQVX_to_Alevin.sh"
#
# REQUIRED INPUTS:
# 1. A FASTQ file containing biological reads, e.g. DEW101.R1.fastq.gz
# 2. A FASTQ file containing metadata reads (cell barcodes + UMI), e.g. DEW101.R2R4.fastq.gz 
# 3. A prebuilt Salmon index
# 4. A transcript-to-gene mapping file
#
# USAGE:
# Complete the user specified inputs below.
# This script can process a single library or a list of libraries.
# For each basename appearing in "list_of_fastq_basenames", this script expects two FASTQ files named as:
# (1) basename.R1.FASTQ.gz
# (2) basename.R2R4.FASTQ.gz
#

# User-specified inputs:
list_of_fastq_basenames=(DEW042 DEW043 DEW044 DEW045)
path_to_fastq_files='/wynton/home/wagner/dwagner/fastq/Wagner2018/'
path_to_salmon_index='/wynton/home/wagner/dwagner/references/salmon_index_grcz11_combined_FP'
path_to_t2g_map='/wynton/home/wagner/dwagner/references/salmon_index_grcz11_combined_FP/txp2gene.tsv'
output_path='/wynton/home/wagner/dwagner/projects/DEW/220715.Wagner2018/'  
bc_geometry='1[1-16]'
umi_geometry='1[17-22] '
read_geometry='2[1-end]'
forceCells='20000'
numThreads='32'


# CODE TO EXECUTE ALEVIN (don't edit this part)

date
hostname
module load CBI
module load salmon

for bname in ${list_of_fastq_basenames[@]}
do        
    echo Mapping $bname 
	salmon alevin -lISR -i $path_to_salmon_index --tgMap $path_to_t2g_map -1 $path_to_fastq_files/${bname}.R2R4.fastq.gz -2 $path_to_fastq_files/${bname}.R1.fastq.gz -o $output_path/$bname --read-
geometry $read_geometry --bc-geometry $bc_geometry --umi-geometry $umi_geometry -p $numThreads --forceCells $forceCells --dumpFeatures --dumpMtx 
done
