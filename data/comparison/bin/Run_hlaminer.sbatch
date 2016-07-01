#!/bin/sh -e

#SBATCH --time=14:00:00
##SBATCH --time=30:00:00
##SBATCH --time=60:00:00
#SBATCH --mem=16gb
#SBATCH --job-name=hlaminer
###SBATCH --out out/hlaminer.out
#SBATCH --out out/hlaminer_%A_%a.out
echo $SLURM_JOBID

############################################################
# NOTE: needed to alter parseXMLblast.pl and HLAminer.pl
# DATE: 2012
# DATA: DNA/RNA
# PROGRESS: confirmed working with small data; needed to rerun the provided bwa indexes...
# OUTPUT: allele specific and score-based
# USAGE: bin/Run_hlaminer.sbatch fastq/1000RExtrChr6/HG00096_R1.fastq.gz result/1000RExtr/ RNA alignment
############################################################

. ./config.txt
##SLURM_ARRAY_TASK_ID=1
#READ1=$(head -n ${SLURM_ARRAY_TASK_ID} sampeIDs.txt | tail -1)
READ1=$1
READ2=${READ1/$READ1NAME/$READ2NAME}
module unload perl
dmget $READ1 $READ2

module load use.own
module load hlaminer
module load bwa
module load bioperl
module load samtools

TOOL=hlaminer

##############
# Variables
##############
SEQTYPE=$3 # DNA/RNA
MODE=$4 # assembly/alignment


NAME=$(basename $READ1)
NAME=${NAME/$ENDING/}

echo "Run $NAME with $TOOL"
echo "$READ1 $READ2"

TMP=/flush1/bau04c/HLA/$TOOL/$RANDOM/
OUT=$2/$TOOL/


FASTA=${HLAMINER_HOME}/database/HLA-I_II_CDS.fasta # for RNA
if [ "$SEQTYPE" = "DNA" ]; then  FASTA=${HLAMINER_HOME}/database/HLA-I_II_GEN.fasta; fi #DNA

# need to rern FASTA index
#bwa index $FASTA

BLASTFILE=${HLAMINER_HOME}/bin/ncbiBlastConfig.txt
PDESIG=${HLAMINER_HOME}/database/hla_nom_p.txt

mkdir -p $TMP
mkdir -p $OUT


#############################
# From FASTQ alignment-based
#############################

if [ "$MODE" = "alignment" ]; then
  SECONDS=0
  echo "---Alignment by bwa $FASTA in $SEQTYPE mode"
  #bwa aln -e 0 -o 0 $FASTA $READ1 > $TMP/$NAME.1.sai
  #bwa aln -e 0 -o 0 $FASTA $READ2 > $TMP/$NAME.2.sai
  #bwa sampe -o 1000 $FASTA $OUT/$NAME.1.sai $OUT/$NAME.2.sai $READ1 $READ2 > $TMP/$NAME.sam
  bwa mem -a $FASTA $READ1 $READ2 > $TMP/$NAME.sam
  echo "Fixing MD tag..."
  samtools fillmd -S $TMP/$NAME.sam $FASTA > $TMP/$NAME.aln.sam  2> /dev/null
  echo "CSIRO MAPPING $SECONDS seconds"
  SECONDS=0
  ### Predict HLA
  echo "Predicting HLA..."
  HLAminerCSIRO.pl -a $TMP/$NAME.aln.sam -h $FASTA -s 500 \
    -o $OUT/${NAME}_aln_ \
    -p $PDESIG -h $FASTA
  echo "CSIRO TYPING $SECONDS seconds"
fi

#############################
# From FASTQ assebly-based
#############################
if [ "$MODE" = "assembly" ]; then

  SECONDS=0
  #need file to be unzipped
  gunzip -c -d $READ1 > $TMP/${NAME}_R1.fq
  gunzip -c -d $READ2 > $TMP/${NAME}_R2.fq
  echo "CSIRO UNZIPPING $SECONDS seconds"

  SECONDS=0
  echo "---Assembly by TASR $FASTA in $SEQTYPE mode"
  echo -e "$TMP/${NAME}_R1.fq\n$TMP/${NAME}_R2.fq" > $TMP/$NAME.fof
  #TASR Default is -k 15 for recruiting reads. You may increase k, as long as k < L/2 where L is the minimum shotgun read length
  TASR -f $TMP/$NAME.fof -m 20 -k 20 -s $FASTA -i 1 -b $TMP/$NAME
  ###Restrict 200nt+ contigs
  cat $TMP/${NAME}.contigs | perl -ne 'if(/size(\d+)/){if($1>=200){$flag=1;print;}else{$flag=0;}}else{print if($flag);}' > $TMP/${NAME}.200.contigs
  ###Create a [NCBI] blastable database
  echo "---Formatting blastable database"
  formatdb -p F -i $TMP/${NAME}.200.contigs
  ###Align HLA contigs to references
  echo "---Aligning TASR contigs to HLA references"
  parseXMLblastCSIRO.pl -c $BLASTFILE -d $FASTA -i $TMP/${NAME}.200.contigs -o 0 -a 1 > $TMP/${NAME}.tig_vs_hla-ncbi.coord
  ###Align HLA references to contigs
  echo "---Aligning HLA references to TASR contigs"
  parseXMLblastCSIRO.pl -c $BLASTFILE -i $FASTA -d $TMP/${NAME}.200.contigs -o 0 > $TMP/${NAME}.hla_vs_tig-ncbi.coord
  echo "CSIRO ASSEMBLING $SECONDS seconds"
  ###Predict HLA alleles
  SECONDS=0
  echo "---Predicting HLA alleles"
  HLAminerCSIRO.pl -b $TMP/${NAME}.tig_vs_hla-ncbi.coord \
    -p $PDESIG \
    -r $TMP/${NAME}.hla_vs_tig-ncbi.coord \
    -c $TMP/${NAME}.200.contigs \
    -h $FASTA \
    -o $OUT/${NAME}_sbly_
  echo "CSIRO TYPING $SECONDS seconds"
fi

echo "---cleanup"
rm -r $TMP

echo "FINISHED Run $NAME with $TOOL"
