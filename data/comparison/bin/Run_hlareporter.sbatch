#!/bin/sh -e

#SBATCH --time=10:00:00
#SBATCH --mem=16gb
#SBATCH --job-name=hlareporter
###SBATCH --out out/hlareporter.out
#SBATCH --out out/hlareporter_%A_%a.out
echo $SLURM_JOBID

##echo $SLURM_ARRAY_TASK_ID
##id=$(head -n ${SLURM_ARRAY_TASK_ID} sampeIDs.txt | tail -1)

############################################################
# NOTE: I cannot get the example to run
# DATE: 2015
# DATA: DNA
# PROGRESS: Obtained password (Yang Wanling <yangwl@hku.hk>)
############################################################

module load use.own
module load hlareporter

TOOL=hlareporter
READ1=fastqtest/Run1_read1.fastq
READ2=fastqtest/Run1_read2.fastq
ENDING="_read1.fastq"

NAME=$(basename $READ1)
NAME=${NAME/$ENDING/}

echo "Run $NAME with $TOOL"

TMP=/flush1/bau04c/HLA/$TOOL/$RANDOM/
OUT=$2/$TOOL/

mkdir -p $TMP
mkdir -p $OUT


#############################
# From FASTQ
#############################
SECONDS=0
echo "CSIRO TYPING $SECONDS seconds"

rm -r $TMP

##submit array
# sbatch -a 1-4 template.qsub
