#!/bin/sh

#################################
# Run on the 1000 genomes on a fastq file that was created by extracting info
# from exome bam file
#################################

. ./config.txt

DIR=/home/d/1000genomes/phase3/data/

DIRDERIVED=fastq/1000EExtrChr6/
OUTDIR=result/1000EExtrChr6
QOUT=out/1000EExtrChr6
REGIONS=supportingData/hlaLocsChr6.txt

mkdir -p $OUTDIR
mkdir -p $QOUT

COUNTER=1

# get the sample IDS to run it on
ITER=iter/iterateExtract.txt

# Example of how to re-run it on subsets
#ITER=iter/runE_phlat.txt

MAX=$(wc -l $ITER | cut -f 1 -d " ")

for ((c=$COUNTER;c<=$MAX;c++)); do
  echo $c
  i=$(head -n ${c} $ITER | tail -1)

  NAME=$(basename $i)
  READ1=$DIRDERIVED/${NAME}_WES_${READ1NAME}.fastq.gz
  echo $NAME
  WAIT=""

  #if [ -e $READ1 ]; then
  # continue
  #fi
  #
  # NAS=$(grep -s $NAME out/1000EExtrChr6log/noalignmentavail.txt)
  # if [ -n "$NAS" ]; then
  #   grep $NAME out/1000EExtrChr6log/noalignmentavail.txt
  #   continue
  # fi
  #
  # echo missing $NAME

  if [ ! -e $READ1 ]; then
    # extract files
    command="sbatch -J $NAME -o $QOUT/extract_${NAME}.out bin/extract.sbatch $NAME $DIRDERIVED $REGIONS exome_alignment WES"
    echo $command
    RECIPT=$($command)
    JOBID=$(echo "$RECIPT" | awk '{print $4}')
    WAIT="-d afterok:${JOBID} --kill-on-invalid-dep=yes"
  fi

  echo $READ1 $OUTDIR $JOBID $WAIT


  # run the HLA predictors
  #echo -e "submitting the following \n \n"
  sbatch $WAIT --time=60:00:00 -J E${NAME}hlaminerDNAassembly -o $QOUT/${NAME}_hlaminerDNAassembly.out bin/Run_hlaminer.sbatch $READ1 $OUTDIR DNA assembly
  sbatch $WAIT -J E${NAME}hlaminerDNAalignment -o $QOUT/${NAME}_hlaminerDNAalignment.out bin/Run_hlaminer.sbatch $READ1 $OUTDIR DNA alignment

  sbatch $WAIT --time=60:00:00 -J E${NAME}optitypeDNA -o $QOUT/${NAME}_optitypeDNA.out bin/Run_optitype.sbatch $READ1 $OUTDIR DNA

  sbatch $WAIT --mem=64gb -J E${NAME}hlavbseq -o $QOUT/${NAME}_hlavbseq.out bin/Run_hlavbseq.sbatch $READ1 $OUTDIR

  sbatch $WAIT -J E${NAME}phlat -o $QOUT/${NAME}_phlat.out bin/Run_phlat.sbatch $READ1 $OUTDIR

  sbatch $WAIT -J E${NAME}seq2hla -o $QOUT/${NAME}_seq2hla.out bin/Run_seq2hla.sbatch $READ1 $OUTDIR

done
