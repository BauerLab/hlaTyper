#!/bin/sh -e

#################################
# RNA
#################################

. ./config.txt

OUTDIR=result/1000RExtrChr6
QOUT=out/1000RExtrChr6

mkdir -p $OUTDIR
mkdir -p $QOUT

COUNTER=1

#ls fastq/1000RExtrChr6/*R1* | sed 's/fastq\/1000RExtrChr6\///g' | sed 's/_R1.fastq.gz//g' > iter/runRNA.txt
ITER=iter/runRNA.txt
#ITER=iter/runR_optitype.txt
#ITER=iter/runR_hlaminerDNAalignment.txt
#ITER=iter/runR_hlaminerDNAassembly.txt
#ITER=iter/runR_hlavbseq.txt

MAX=$(wc -l $ITER | cut -f 1 -d " ")

for ((c=$COUNTER;c<=$MAX;c++)); do
  echo $c
  i=$(head -n ${c} $ITER | tail -1)

  NAME=$i
  READ1=fastq/1000RExtrChr6/${NAME}_${READ1NAME}.fastq.gz
  echo $NAME

  echo $READ1 $OUTDIR

  # run the HLA predictors
  #sbatch --time=60:00:00 -J R${NAME}hlaminerDNAassembly -o $QOUT/${NAME}_hlaminerDNAassembly.out bin/Run_hlaminer.sbatch $READ1 $OUTDIR RNA assembly
  #sbatch -J R${NAME}hlaminerDNAalignment -o $QOUT/${NAME}_hlaminerDNAalignment.out bin/Run_hlaminer.sbatch $READ1 $OUTDIR RNA alignment

  #sbatch --mem=32gb -J R${NAME}optitypeDNA -o $QOUT/${NAME}_optitypeDNA.out bin/Run_optitype.sbatch $READ1 $OUTDIR RNA

  # asked by developer not to include
  ##sbatch -J R${NAME}hlaforest -o $QOUT/${NAME}_hlaforest.out bin/Run_hlaforest.sbatch $READ1 $OUTDIR

  sbatch -J R${NAME}seq2hla -o $QOUT/${NAME}_seq2hla.out bin/Run_seq2hla.sbatch $READ1 $OUTDIR

  # not running...
  ##sbatch -J R${NAME}athlates -o $QOUT/${NAME}_athlates.out bin/Run_athlates.sbatch $READ1 $OUTDIR

  #sbatch --time=12:00:00 --mem=64gb -J R${NAME}hlavbseq -o $QOUT/${NAME}_hlavbseq.out bin/Run_hlavbseq.sbatch $READ1 $OUTDIR

  #RECIPT=$(sbatch $WAIT --mem=64gb --time=8:00:00 -J R${NAME}hlavbseq -o $QOUT/${NAME}_hlavbseq.out bin/Run_hlavbseq.sbatch $READ1 $OUTDIR)
  #JOBID=$(echo "$RECIPT" | awk '{print $4}')
  #WAIT="-d afterany:${JOBID} --kill-on-invalid-dep=yes"


  #sbatch -J R${NAME}phlat -o $QOUT/${NAME}_phlat.out bin/Run_phlat.sbatch $READ1 $OUTDIR




done
