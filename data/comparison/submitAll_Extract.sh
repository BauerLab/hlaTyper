#!/bin/sh -e

#################################
# Run on the 1000 genomes on a fastq file that was created by extracting info
# from bam file
# 25 Jan potential issue with 1146 /home/d/1000genomes/phase3/data/NA19152
#################################

. ./config.txt

DIR=/home/d/1000genomes/phase3/data/

#DIRDERIVED=fastq/1000GExtr/
#OUTDIR=result/1000GExtr
#QOUT=out/1000GExtr
#REGIONS=supportingData/hlaLocsNoun.txt

DIRDERIVED=fastq/1000GExtrChr6/
OUTDIR=result/1000GExtrChr6
QOUT=out/1000GExtrChr6
#DIRDERIVED=fastq/1000GExtrChr6NS/
#OUTDIR=result/1000GExtrChr6NS
#QOUT=out/1000GExtrChr6NS
REGIONS=supportingData/hlaLocsChr6.txt

mkdir -p $OUTDIR
mkdir -p $QOUT

COUNTER=1

#find /home/d/1000genomes/phase3/data/ -maxdepth 1 -type d | tail -n +1 | sed 's/\/home\/d\/1000genomes\/phase3\/data\///g'> iter/iterateExtract.txt
#ls /home/d/1000genomes/phase3/data/ >iter/iterateExtract.txt
ITER=iter/collectSamples1000GExtrChr6.txt
#ITER=iter/iterateExtract.txt
# RERUN after alignment extraction drop out
#cat out/1000GExtrChr6log/*_missing.txt | sort -u > iterateRerun10missing.txt
#ITER=iterateRerun10missing.txt
# RERUN PHLAT - increase timelimit
#ITER=phlat_rerun.txt
# RERUN HLAMINER ASSEMBLY - REASON just failed without error message
#ITER=iter/run_rlaminer_assembly.txt
# RERUN HLAMINER ALIGNMENT - REASON error in code
#ITER=iter/run_rlaminer_alignment.txt
# RERUN optitype
#ITER=optitype_rerun.txt
#ITER=hc_rerun.txt
#ITER=iter/runG_phlat.txt
#ITER=iter/collectSamples1000GExtrChr6.txt
#ITER=iter/run_hlavbseq.txt
#ITER=iter/run_optitype.txt
#WAIT="-d afterany:118547 --kill-on-invalid-dep=yes"


MAX=$(wc -l $ITER | cut -f 1 -d " ")
#MAX=1

for ((c=$COUNTER;c<=$MAX;c++)); do
  echo $c
  i=$(head -n ${c} $ITER | tail -1)

  NAME=$(basename $i)
  READ1=$DIRDERIVED/${NAME}_lc_${READ1NAME}.fastq.gz
  #READ1=$DIRDERIVED/${NAME}_hc_${READ1NAME}.fastq.gz
  echo $NAME
  #WAIT=""

  if [ ! -e $READ1 ]; then
    # concatinate files
    command="sbatch -J $NAME -o $QOUT/extract_${NAME}.out bin/extract.sbatch $NAME $DIRDERIVED $REGIONS alignment lc"
    echo $command
    RECIPT=$($command)
    JOBID=$(echo "$RECIPT" | awk '{print $4}')
    WAIT="-d afterok:${JOBID} --kill-on-invalid-dep=yes"
  fi

  echo $READ1 $OUTDIR $JOBID $WAIT

  # run the HLA predictors
  #echo -e "above is jsut a command echo \n"
  #echo -e "submitting the following \n \n"
  #sbatch $WAIT --time=160:00:00 -J ${NAME}hlaminerDNAassembly -o $QOUT/${NAME}_hlaminerDNAassembly.out bin/Run_hlaminer.sbatch $READ1 $OUTDIR DNA assembly
#  sbatch $WAIT -J ${NAME}hlaminerDNAalignment -o $QOUT/${NAME}_hlaminerDNAalignment.out bin/Run_hlaminer.sbatch $READ1 $OUTDIR DNA alignment

  #sbatch $WAIT -J ${NAME}optitypeDNA -o $QOUT/${NAME}_optitypeDNA.out bin/Run_optitype.sbatch $READ1 $OUTDIR DNA

#  sbatch $WAIT -J ${NAME}athlates -o $QOUT/${NAME}_athlates.out bin/Run_athlates.sbatch $READ1 $OUTDIR

  #sbatch $WAIT --time=8:00:00 -J ${NAME}hlavbseq -o $QOUT/${NAME}_hlavbseq.out bin/Run_hlavbseq.sbatch $READ1 $OUTDIR
  #RECIPT=$(sbatch $WAIT --mem=64gb --time=8:00:00 -J ${NAME}hlavbseq -o $QOUT/${NAME}_hlavbseq.out bin/Run_hlavbseq.sbatch $READ1 $OUTDIR)
  #JOBID=$(echo "$RECIPT" | awk '{print $4}')
  #WAIT="-d afterany:${JOBID} --kill-on-invalid-dep=yes"

  #sbatch $WAIT -J ${NAME}phlat -o $QOUT/${NAME}_phlat.out bin/Run_phlat.sbatch $READ1 $OUTDIR


  # RNA
  #sbatch $WAIT -J ${NAME}hlaforest -o $QOUT/${NAME}_hlaforest.out bin/Run_hlaforest.sbatch $READ1 $OUTDIR
  sbatch -J R${NAME}seq2hla -o $QOUT/${NAME}_seq2hla.out bin/Run_seq2hla.sbatch $READ1 $OUTDIR


done
