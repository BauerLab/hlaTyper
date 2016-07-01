#!/bin/sh -e

##SBATCH --time=3:00:00
#SBATCH --time=6:00:00
#SBATCH --mem=16gb
#SBATCH --job-name=optitype
###SBATCH --out out/optitype.out
#SBATCH --out out/optitype_%A_%a.out
echo $SLURM_JOBID

############################################################
# NOTE:
# DATE: 2014
# DATA: DNA/RNA
# PROGRESS: DONE FINISHED confirmed
# OUTPUT: 2016_01_18_20_21_20_result.tsv
# OUTPUT: allele specifc only one predicition
############################################################


. ./config.txt

##SLURM_ARRAY_TASK_ID=1
#READ1=$(head -n ${SLURM_ARRAY_TASK_ID} sampeIDs.txt | tail -1)
READ1=$1
READ2=${READ1/$READ1NAME/$READ2NAME}
module unload perl
dmget $READ1 $READ2

module load use.own
module load optitype/1.0
module load razers3/3.5.0
module load samtools/1.2.1

TOOL=optitype

##############
# Variables
##############
SEQTYPE=$3 #DNA/RNA




NAME=$(basename $READ1)
NAME=${NAME/$ENDING/}
FASTA=${OPTITYPE_HOME}/data/hla_reference_dna.fasta
if [ "$SEQTYPE" = "RNA" ]; then
  FASTA=${OPTITYPE_HOME}/data/hla_reference_rna.fasta
fi

echo "Run $NAME with $TOOL"
echo "$READ1 $READ2"

TMP=/flush1/bau04c/HLA/$TOOL/$RANDOM/
OUT=$2/$TOOL/

mkdir -p $TMP
mkdir -p $OUT

#############################
# From FASTQ alignment-based
#############################

SECONDS=0
# Optional filtering
echo "filter Read1"
razers3 -i 95 -m 1 -dr 0 -o $TMP/${NAME}_1.bam $FASTA $READ1
samtools bam2fq $TMP/${NAME}_1.bam > $TMP/${NAME}_1.fq
echo "filter Read2"
razers3 -i 95 -m 1 -dr 0 -o $TMP/${NAME}_2.bam $FASTA $READ2
samtools bam2fq $TMP/${NAME}_2.bam > $TMP/${NAME}_2.fq
echo "CSIRO FILTERING $SECONDS seconds"

SECONDS=0
if [ "$SEQTYPE" = "DNA" ]; then
  python ${OPTITYPE_HOME}/OptiTypePipeline.py \
    -i $TMP/${NAME}_1.fq $TMP/${NAME}_2.fq --dna -v \
    -o $OUT/$NAME/ --config supportingData/optitype/config.ini
fi

if [ "$SEQTYPE" = "RNA" ]; then
  python ${OPTITYPE_HOME}/OptiTypePipeline.py \
    -i $TMP/${NAME}_1.fq $TMP/${NAME}_2.fq --rna -v \
    -o $OUT/$NAME/ --config supportingData/optitype/config.ini
fi
echo "CSIRO TYPING $SECONDS seconds"

echo "---cleanup"
rm -r $TMP

echo "FINISHED Run $NAME with $TOOL"
