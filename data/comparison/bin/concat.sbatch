#!/bin/sh -e

#SBATCH --time=50:00:00
#SBATCH --mem=2gb
echo $SLURM_JOBID
echo $2

############################################################
# Concat all fastq files from the 1000 genomes project
############################################################

. ./config.txt

SAMPLE=$1
echo $SAMPLE
DIRORIGIN=/home/d/1000genomes/phase3/data/
TMP=/flush1/bau04c/HLA/gzip/
DIRDERIVED=/home/d/1000genomes/phase3_derived

module unload perl

# get experiment id of illumina reads that are not withdrawn and from the low coverage
# experiment
LCIDS=$(grep -w $SAMPLE /home/d/1000genomes/1000genomes.sequence.index | \
  grep -w ILLUMINA | grep "low coverage" | gawk -F\\t '{if($21==0){print $0}}' | \
  cut -f 3 | sort -u)

echo $LCIDS

READ1S=$(for i in $LCIDS; do ls $DIRORIGIN/$SAMPLE/sequence_read/${i}*_1*.fastq.gz; done)
READ2S=$(for i in $LCIDS; do ls $DIRORIGIN/$SAMPLE/sequence_read/${i}*_2*.fastq.gz; done)

echo $READ1S
echo $READ2S

dmget -a $READ1S $READ2S

mkdir -p $TMP

echo "read1"
command="zcat $READ1S | gzip -1 > ${TMP}/${SAMPLE}_R1.fastq.gz"
echo $command && eval $command
echo "read2"
command="zcat $READ2S | gzip -1 > ${TMP}/${SAMPLE}_R2.fastq.gz"
echo $command && eval $command

wc -l ${TMP}/${SAMPLE}_R1.fastq.gz | gawk -v V="Read1" '{print V" "$1/4}' > $DIRDERIVED/${SAMPLE}.stats
wc -l ${TMP}/${SAMPLE}_R2.fastq.gz | gawk -v V="Read2" '{print V" "$1/4}' >> $DIRDERIVED/${SAMPLE}.stats

mv ${TMP}/${SAMPLE}*.gz $DIRDERIVED/

echo "FINISHED"
