# InDropsV3-FASTQ-Conversion
Command line tool for converting legacy inDrops FASTQ's (V1/V2) into V3-compatible format 

# Description:
This shell script will convert a metadata FASTQ file from legacy inDrops libraries (V1 or V2) into two V3-compatible FASTQ files.  
Legacy metadata reads contain the cell barcode split into two parts, a fixed "W1" sequence, and the UMI. In inDrops V1/V2, barcode part 1 lengths are variable 8-11bp, 
but only the first 8bp are required.
This script will split this large metadata read into a V3-like R2 file (cell barcode part 1 -8bp), and a V3-like R4 file (cell barcode part 2 - 8bp, and the UMI -6bp).
For V1 libraries, R1 is the metadata read. For V2 libraries, R2 is the metadata read.
 
# Dependencies:
This script uses command line tools: cutadapt, seqkit, and seqtk. Install these tools in a dedicated conda environment as follows:
conda create --name seqtools python=3.7
conda activate seqtools
conda config --add channels conda-forge
conda config --add channels bioconda
conda install seqtk seqkit cutadapt

# Usage:
Run this script by typing "source", followed by the name of this script, followed by the names of one or more metadata FASTQ files for conversion (wildcards accepted).
Example: 
"source convert_metadata_to_V3.sh DEW016.V2.R2.fastq.gz DEW017.V2.R2.fastq.gz"
"source convert_metadata_to_V3.sh DEW0*.V2.R2.fastq.gz"
