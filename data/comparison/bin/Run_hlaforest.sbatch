#!/bin/sh

#SBATCH --time=10:00:00
#SBATCH --mem=16gb
#SBATCH --job-name=hlaforest
###SBATCH --out out/hlaforest.out
#SBATCH --out out/hlaforest_%A_%a.out
echo $SLURM_JOBID

############################################################
# NOTE: hardcoded paths needed to be modified in two scripts
# DATE: 2013
# DATA: RNA
# PROGRESS: possibly running on real data - testing with 64
# USAGE: bin/Run_hlaforest.sbatch fastq/1000RExtrChr6/HG00097_R1.fastq.gz result/1000RExtrChr6/
############################################################


. ./config.txt

##SLURM_ARRAY_TASK_ID=1
#READ1=$(head -n ${SLURM_ARRAY_TASK_ID} sampeIDs.txt | tail -1)
READ1=$1
READ2=${READ1/$READ1NAME/$READ2NAME}
module unload perl
dmget $READ1 $READ2

module load use.own
module load hlaforest/20130211
module load bowtie/1.1.2

TOOL=hlaforest








NAME=$(basename $READ1)
NAME=${NAME/$ENDING/}

echo "Run $NAME with $TOOL"
echo "$READ1 $READ2"

TMP=/flush1/bau04c/HLA/$TOOL/$RANDOM/
OUT=$2/$TOOL/

mkdir -p $TMP
mkdir -p $OUT

#############################
# From FASTQ
#############################
SECONDS=0
#need file to be unzippedls
gunzip -c -d $READ1 > $TMP/${NAME}_R1.fq
gunzip -c -d $READ2 > $TMP/${NAME}_R2.fq
echo "CSIRO UNZIPPING $SECONDS seconds"

SECONDS=0
CallHaplotypesPECSIRO.sh $OUT/$NAME $TMP/${NAME}_R1.fq $TMP/${NAME}_R2.fq $TMP
echo "CSIRO TYPING $SECONDS seconds"

# move result files
mv $TMP/${NAME}/haplotypes.txt $OUT/${NAME}.haplotypes.txt

echo "---cleanup"
rm -r $TMP

echo "FINISHED Run $NAME with $TOOL"
