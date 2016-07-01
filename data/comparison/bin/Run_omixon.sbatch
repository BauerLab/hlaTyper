#!/bin/sh -e

#SBATCH --time=10:00:00
#SBATCH --mem=16gb
#SBATCH --job-name=omixon
###SBATCH --out out/omixon.out
#SBATCH --out out/omixon_%A_%a.out
echo $SLURM_JOBID

##echo $SLURM_ARRAY_TASK_ID
##id=$(head -n ${SLURM_ARRAY_TASK_ID} sampeIDs.txt | tail -1)

############################################################
# NOTE: Seems to be only available as GUI
#
# PROGRESS: Contacted developer for commandline
############################################################

module load use.own
module load omixon/1.9.3

TOOL=omixon
#READ1=fastqtest/Run1_read1.fastq
#READ2=fastqtest/Run1_read2.fastq
#ENDING="_read1.fastq"
. ./config.txt
echo $READ1
dmget $READ1
dmget $READ2

NAME=$(basename $READ1)
NAME=${NAME/$ENDING/}

echo "Run $NAME with $TOOL"

TMP=/flush1/bau04c/HLA/$TOOL/$RANDOM/
OUT=$2/$TOOL/

mkdir -p $TMP
mkdir -p $OUT


echo "FINISHED Run $NAME with $TOOL"
