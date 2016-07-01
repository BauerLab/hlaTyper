#!/bin/sh -e

#SBATCH --time=4:00:00
#SBATCH --mem=2gb
echo $SLURM_JOBID
echo $2

############################################################
# Extract info from bam files
# input bamfile
# USAGE:
# bin/extract.sbatch HG00099 fastq/1000GExtr/
############################################################

. ./config.txt

module load samtools/1.3
module load bedtools

SAMPLE=$1
DIR=/home/d/1000genomes/phase3/data/
OUTDIR=$2
TMP=/flush1/bau04c/HLA/extract/$RANDOM/

echo $SAMPLE
echo $TMP $OUTDIR

mkdir -p $OUTDIR
mkdir -p $TMP

REGIONS=$(cat $3 | gawk '{ ORS=" "; print; }')
echo $REGIONS

################################
# Low coverage and Exon
################################
MAPPED=$(find $DIR/$SAMPLE/$4/ -name *.mapped*.bam )
UNMAPPED=$(find $DIR/$SAMPLE/$4/ -name *.unmapped*.bam )
module unload perl
echo "recall files"
dmget $MAPPED* $UNMAPPED*
module load samtools/1.3
module load bedtools

NAME=$5

echo "extract mapped"
#samtools view -b $MAPPED $REGIONS | samtools rmdup -S - $TMP/${SAMPLE}_${NAME}_${READ1NAME}_mapped.bam
samtools view -b $MAPPED $REGIONS | samtools rmdup - $TMP/${SAMPLE}_${NAME}_${READ1NAME}_mapped.bam


echo "concat"
samtools cat $TMP/${SAMPLE}_${NAME}_${READ1NAME}_mapped.bam $UNMAPPED \
 | samtools sort -T $TMP -n > $TMP/${SAMPLE}_${NAME}_${READ1NAME}.srt.bam

samtools flagstat $TMP/${SAMPLE}_${NAME}_${READ1NAME}.srt.bam > $OUTDIR/${SAMPLE}_${NAME}.stats

echo "bam to fastq"
#samtools fastq $TMP/${SAMPLE}_${NAME}_${READ1NAME}.srt.bam -1 $TMP/${SAMPLE}_${NAME}_${READ1NAME}.fastq \
#  -2 $TMP/${SAMPLE}_${NAME}_${READ2NAME}.fastq
bedtools bamtofastq -i $TMP/${SAMPLE}_${NAME}_${READ1NAME}.srt.bam \
                        -fq $TMP/${SAMPLE}_${NAME}_${READ1NAME}.fastq \
                        -fq2 $TMP/${SAMPLE}_${NAME}_${READ2NAME}.fastq &> /dev/null

echo "zip"
gzip $TMP/${SAMPLE}_${NAME}_${READ1NAME}.fastq
gzip $TMP/${SAMPLE}_${NAME}_${READ2NAME}.fastq
echo "move"
mv $TMP/${SAMPLE}_${NAME}*.gz $OUTDIR/


rm -r $TMP
echo FINISHED

exit

################################
# High coverage
################################
if [ -e $DIR/$SAMPLE/high_coverage_alignment/ ]; then
  echo "high coverage exists"
  BAM=$(find $DIR/$SAMPLE/high_coverage_alignment/ -name *.bam )
  dmget $BAM*
  NAME="hc"
  #samtools view -f 1 -b $BAM $REGIONS | samtools rmdup -S - - | \
  #  samtools sort -T $TMP -n > $TMP/${SAMPLE}_${NAME}_${READ1NAME}.srt.bam
  samtools view -f 1 -b $BAM $REGIONS | samtools rmdup - - | \
      samtools sort -T $TMP -n > $TMP/${SAMPLE}_${NAME}_${READ1NAME}.srt.bam



  #samtools view -f 1 -b $BAM $REGIONS | samtools rmdup -S - - > $TMP/${SAMPLE}_${NAME}_${READ1NAME}.mpt.bam
  #samtools view -f 1 -b $BAM "*" > $TMP/${SAMPLE}_${NAME}_${READ1NAME}.umpt.bam
  #cat $TMP/${SAMPLE}_${NAME}_${READ1NAME}.mpt.bam $TMP/${SAMPLE}_${NAME}_${READ1NAME}.umpt.bam \
  #  | samtools sort -T $TMP -n > $TMP/${SAMPLE}_${NAME}_${READ1NAME}.srt.bam

  samtools flagstat $TMP/${SAMPLE}_${NAME}_${READ1NAME}.srt.bam > $OUTDIR/${SAMPLE}_${NAME}.stats

  #samtools fastq $TMP/${SAMPLE}_${NAME}_${READ1NAME}.srt.bam -1 $TMP/${SAMPLE}_${NAME}_${READ1NAME}.fastq \
  #        -2 $TMP/${SAMPLE}_${NAME}_${READ2NAME}.fastq
  bedtools bamtofastq -i $TMP/${SAMPLE}_${NAME}_${READ1NAME}.srt.bam \
                          -fq $TMP/${SAMPLE}_${NAME}_${READ1NAME}.fastq \
                          -fq2 $TMP/${SAMPLE}_${NAME}_${READ2NAME}.fastq

  echo "zip"
  gzip $TMP/${SAMPLE}_${NAME}_${READ1NAME}.fastq
  gzip $TMP/${SAMPLE}_${NAME}_${READ2NAME}.fastq
  mv $TMP/${SAMPLE}_${NAME}*.gz $OUTDIR/
fi

rm -r $TMP

echo FINISHED
