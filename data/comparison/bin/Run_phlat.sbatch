#!/bin/sh -e

##SBATCH --time=1:00:00 - all except two
#SBATCH --time=2:00:00
#SBATCH --mem=16gb
#SBATCH --job-name=phlat
##SBATCH --cpus-per-task=8
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=20
###SBATCH --out phlat.out
#SBATCH --out out/phlat_%A_%a.out
echo $SLURM_JOBID

############################################################
# NOTE:
# DATE: 2014
# DATA: DNA/RNA
# PROGRESS: Contacted developer for password, running on example, running on data
# bin/Run_phlat.sbatch fastq/1000EExtrChr6/HG00100_WES_R1.fastq.gz result/1000EExtr/
############################################################


TOOL=phlat
. ./config.txt

READ1=$1
READ2=${READ1/$READ1NAME/$READ2NAME}
module unload perl
dmget $READ1 $READ2

module load use.own
module load bowtie/2.2.6
module load python
module load phlat/release

NAME=$(basename $READ1)
NAME=${NAME/$ENDING/}

echo "Run $NAME with $TOOL"
echo "$READ1 $READ2"

TMP=/flush1/bau04c/HLA/$TOOL/$RANDOM/
OUT=$2/$TOOL/

#echo $TMP

PHLATDIR=${PHLAT_HOME}/phlat-release/
indexdir=${PHLAT_HOME}/phlat-release/b2folder

#mkdir -p $TMP
mkdir -p $OUT

#############################
# From FASTQ alignment-based
#############################

SECONDS=0

command="python -O ${PHLATDIR}/dist/PHLAT.py -1 $READ1 -2 $READ2 \
  -index ${PHLATDIR}/b2folder -p 8 \
  -b2url bowtie2 -orientation "--fr" -tag $NAME -e $PHLATDIR -o $OUT"

echo $command && eval $command

echo "CSIRO TYPING $SECONDS seconds"

#echo "---cleanup"
#rm -r $TMP

echo "FINISHED Run $NAME with $TOOL"
