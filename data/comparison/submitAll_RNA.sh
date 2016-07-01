#!/bin/sh -e

#################################
# Submit all for the RNAseq data
#################################

. ./config.txt

OUTDIR=result/1000RExtrChr6
QOUT=out/1000RExtrChr6

mkdir -p $OUTDIR
mkdir -p $QOUT

COUNTER=1

# get the sample IDS to run it on
#ls fastq/1000RExtrChr6/*R1* | sed 's/fastq\/1000RExtrChr6\///g' | sed 's/_R1.fastq.gz//g' > iter/runRNA.txt
ITER=iter/runRNA.txt
# Example of how to re-run it on subsets
#ITER=iter/runR_optitype.txt

MAX=$(wc -l $ITER | cut -f 1 -d " ")

for ((c=$COUNTER;c<=$MAX;c++)); do
  echo $c
  i=$(head -n ${c} $ITER | tail -1)

  NAME=$i
  READ1=fastq/1000RExtrChr6/${NAME}_${READ1NAME}.fastq.gz
  echo $NAME

  echo $READ1 $OUTDIR

  # run the HLA predictors
  sbatch --time=60:00:00 -J R${NAME}hlaminerDNAassembly -o $QOUT/${NAME}_hlaminerDNAassembly.out bin/Run_hlaminer.sbatch $READ1 $OUTDIR RNA assembly
  sbatch -J R${NAME}hlaminerDNAalignment -o $QOUT/${NAME}_hlaminerDNAalignment.out bin/Run_hlaminer.sbatch $READ1 $OUTDIR RNA alignment

  sbatch --mem=32gb -J R${NAME}optitypeDNA -o $QOUT/${NAME}_optitypeDNA.out bin/Run_optitype.sbatch $READ1 $OUTDIR RNA

  sbatch -J R${NAME}seq2hla -o $QOUT/${NAME}_seq2hla.out bin/Run_seq2hla.sbatch $READ1 $OUTDIR

  sbatch --time=12:00:00 -J R${NAME}hlavbseq -o $QOUT/${NAME}_hlavbseq.out bin/Run_hlavbseq.sbatch $READ1 $OUTDIR

  sbatch -J R${NAME}phlat -o $QOUT/${NAME}_phlat.out bin/Run_phlat.sbatch $READ1 $OUTDIR




done
