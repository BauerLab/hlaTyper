#!/bin/sh -e

#SBATCH --time=1:00:00
#SBATCH --mem=16gb
#SBATCH --job-name=seq2hla
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=20
###SBATCH --out out/seq2hla.out
#SBATCH --out out/seq2hla_%A_%a.out
echo $SLURM_JOBID

##echo $SLURM_ARRAY_TASK_ID
##id=$(head -n ${SLURM_ARRAY_TASK_ID} sampeIDs.txt | tail -1)

############################################################
# NOTE: straight forward
# DATE: 2012
# DATA: RNA
# PROGRESS: DONE
# USAGE: bin/Run_seq2hla.sbatch fastq/1000RExtrChr6/HG00096_R1.fastq.gz result/1000RExtrChr6/
############################################################

#module load use.own
#module load seq2hla/2.2


TOOL=seq2hla


. ./config.txt

##SLURM_ARRAY_TASK_ID=1
#READ1=$(head -n ${SLURM_ARRAY_TASK_ID} sampeIDs.txt | tail -1)
READ1=$1
READ2=${READ1/$READ1NAME/$READ2NAME}
module unload perl
dmget $READ1 $READ2

module load use.own
module load seq2hla/2.2
module load bowtie/1.1.2


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
# -3 <int>
# -p Threads for bowtie
SECONDS=0
python ${SEQ2HLA_HOME}/seq2HLA.py -1 $READ1 -2 $READ2 -r $TMP/${NAME} -p 8
echo "CSIRO TYPING $SECONDS seconds"

# move result files
#cat result/1000RExtrChr6/seq2hla/${NAME}*.digitalhaplotype* > $OUT/$NAME.digitalhaplotype
#cat result/1000RExtrChr6/seq2hla/${NAME}*.expression* > $OUT/$NAME.expression
cat $TMP/${NAME}-Class*.HLAgenotype4digits > $OUT/$NAME.HLAgenotype4digits
cat $TMP/${NAME}.ambiguity > $OUT/$NAME.ambiguity

echo "---cleanup"
rm -r $TMP

echo "FINISHED Run $NAME with $TOOL"
