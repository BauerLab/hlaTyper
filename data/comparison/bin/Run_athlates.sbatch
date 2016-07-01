#!/bin/sh -e

#SBATCH --time=3:00:00
#SBATCH --mem=32gb
#SBATCH --job-name=athlates
###SBATCH --out out/athlates.out
#SBATCH --out out/athlates_%A_%a.out
echo $SLURM_JOBID

############################################################
# NOTE: needed to change bamtools index from BAMTOOLS to
# STANDARD in bam_manip.cpp for bamtools version 2.25.0.
# Also only HLA-A .. C match up the rest have no clean corresp.
# alignment (http://hla.alleles.org/data/) has new matching info
# but the bed files cannot be matched up (for HLA-C).
# For the extracted reads it does not work, complains that bam file
# is not namesorted (was namesort the default in older samtool versions?)
# DATE: 2013
# DATA: DNA
# STATUS: not actively maintained (Chang Liu, MD, PhD.)
# PROGRESS: DONE - extracting reads does not work
# USAGE: bin/Run_athlates.sbatch fastq/1000GExtr/HG00099_lc_R1.fastq.gz result/1000GExtr/
############################################################

TOOL=athlates
ALNTYPE="MOSAIK"
. ./config.txt

READ1=$1
READ2=${READ1/$READ1NAME/$READ2NAME}
module unload perl
dmget $READ1 $READ2


module load use.own
module load athlates/20140426_BAMTOOLS
module load mosaik
module load samtools/1.3
module load bamtools/2.3.0
module list

NAME=$(basename $READ1)
NAME=${NAME/$ENDING/}

echo "Run $NAME with $TOOL"
echo "$READ1 $READ2"

TMP=/flush1/bau04c/HLA/$TOOL/$RANDOM/
#TMP=/flush1/bau04c/HLA/athlates/12967/
OUT=$2/$TOOL/

echo $TMP

FASTA=${ATHLATES_HOME}/db/ref/hla.clean.fasta
BED=${ATHLATES_HOME}/db/bed/ #Bed location of the differnt genes
# Athlates MSA are from 2012, here we use the version from 2015 October 10
# however C does not match
MSA=${ATHLATES_HOME}/db/msa/ #Nucleotide specific to the HLA types
#MSA=supportingData/hla_MSA/
PEANN=/flush2/bau04c/apps/mosaik/MOSAIK/src/networkFile/2.1.26.pe.100.0065.ann
SEANN=/flush2/bau04c/apps/mosaik/MOSAIK/src/networkFile/2.1.26.se.100.005.ann

mkdir -p $TMP
mkdir -p $OUT

export MOSAIK_TMP=$TMP

#############################
# From FASTQ alignment-based
#############################

if [ "$ALNTYPE" = "MOSAIK" ]; then
  echo "---Alignment by Mosaik as per Athlates documenation"
  if [ ! -e $FASTA.mosaik.dat ]; then
    # convert reference to Mosaik format
    MosaikBuild -fr $FASTA -oa $FASTA.mosaik.dat
    # Not needed HLA is tiny
    # MosaikJump -ia $TMP/$(basename $FASTA).mosaik.dat -hs 15 -out $TMP/$(basename $FASTA).mosaik -mem 2gb
  fi

  SECONDS=0
  # convert reads to Mosaik format
  MosaikBuild -q $READ1 -q2 $READ2 -out $TMP/$NAME.mkb -st illumina -mfl 500
  # aligns
  MosaikAligner -in $TMP/$NAME.mkb -out $TMP/$NAME -ia $FASTA.mosaik.dat \
    -minp 0.4 -p 10 -mms -3 -ms 1 -hgop 4 -gop 5 -gep 2 -m all -bw 29 -a all \
    -act 20 -mm 0 \
    -annpe $PEANN -annse $SEANN
    #  -j $TMP/$(basename $FASTA).mosaik

  echo "---Sort"
  samtools sort -o $TMP/${NAME}_sorted.bam $TMP/$NAME.bam
  echo "MAPPING $SECONDS seconds"
fi

if [ "$ALNTYPE" = "BWA" ]; then
  if [ ! -e $FASTA.amb ]; then echo "index"; bwa index $FASTA; fi
  SECONDS=0
  bwa mem -a $FASTA $READ1 $READ2 | samtools view -b - | samtools sort -o $TMP/${NAME}_sorted.bam
  echo "CSIRO MAPPING $SECONDS seconds"
fi

SECONDS=0
echo "---Extract"
for i in $BED/hla.A.bed $BED/hla.non-A.bed ; do
#for i in $( ls $BED/*.bed ); do
  TYP=$(basename $i)
  TYP=${TYP/hla./}
  TYP=${TYP/.bed/}
  echo $TYP
  samtools view -b -L $i $TMP/${NAME}_sorted.bam > $TMP/${NAME}_${TYP}.bam
  samtools view -h -o $TMP/${NAME}_${TYP}.sam $TMP/${NAME}_${TYP}.bam
  sort -k 1,1 -k 3,3 $TMP/${NAME}_${TYP}.sam > $TMP/${NAME}_${TYP}_sorted.sam
  #CSIRO: include because of "name" sort warning
  #samtools sort -n $TMP/${NAME}_${TYP}.sam > $TMP/${NAME}_${TYP}_sorted.sam
  samtools view -bS $TMP/${NAME}_${TYP}_sorted.sam > $TMP/${NAME}_${TYP}_sorted.bam
  #bamtools index -in $TMP/${NAME}_${TYP}_sorted.bam
done
echo "CSIRO EXTRACTING $SECONDS seconds"


SECONDS=0
echo "---Type"
for i in $( ls $MSA/*.txt); do
  echo $i
  TYP=$(basename $i)
  TYP=${TYP/_nuc.txt/}
  echo $TYPE
  command="typing -bam $TMP/${NAME}_${TYP}_sorted.bam \
    -exlbam $TMP/${NAME}_non-${TYP}_sorted.bam \
    -msa $i -o $OUT/${NAME}_${TYP} > $OUT/${NAME}_${TYP}.log.txt"
  echo $command && eval $command
done
echo "CSIRO TYPING $SECONDS seconds"

echo "---cleanup"
#rm -r $TMP

echo "FINISHED Run $NAME with $TOOL"
