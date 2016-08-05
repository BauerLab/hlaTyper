#!/bin/sh
VERIFY=""

module load python

GS=../goldstandard/goldstandard.csv
#full
#PATHL=result/1000GExtrChr6/results1000GExtrChr6
#HC
#PATHL=result/1000GExtrChr6HC/1000GExtrChr6HC
#comp LC
#PATHL=result/1000GExtrChr6HC/1000GExtrChr6

###########
# WGS
###########
#PATHL=result/1000GExtrChr6/results1000GExtrChr6
#ADD="-s iter/collectSamples1000GExtrChr6.txt"
#ADD="-s supportingData/1000GenomesAlignments.txt" # limit to samples with aligment information in 1000 genomes
#ADD="-s supportingData/1000GenomesCov5xAlignments.txt" # limit to only 5x coverage samples
#ADD="-s supportingData/1000GenomesCov10xAlignments.txt" # limit to only 5x coverage samples

###########
# WES
###########
#PATHL=result/1000EExtrChr6/results1000EExtrChr6
#ADD="-s iter/collectSamples1000EExtrChr6.txt" # limit to samples from exon dataset

###########
# RNA
###########
#PATHL=result/1000RExtrChr6/results1000RExtrChr6
#ADD="-s iter/runRNA.txt" # limit to samples from RNA dataset

PATHL=$1
ADD="-s $2"

#########
#rmdup no -S
#ADD="-s iter/collectSamplesNS.txt"
#PATHL=result/1000GExtrChr6NS/1000GExtrChr6NS


############################
# Eyeball HLA assigment is correct
if [ -n "$VERIFY" ]; then
#  SAMPLE=HG00101
  SAMPLE=HG00096
  python bin/evaluatePredictions.py $ADD -i result/1000GExtrChr6/results1000GExtrChr6.phlat.txt \
    -t phlat -g ../goldstandard/goldstandard.csv -n -r | grep $SAMPLE
  cat result/1000GExtrChr6/phlat/${SAMPLE}_lc_HLA.sum
  grep ${SAMPLE} result/1000GExtrChr6/results1000GExtrChr6.phlat.txt
  echo "-------------------"
  python bin/evaluatePredictions.py $ADD -i result/1000GExtrChr6/results1000GExtrChr6.optitype.txt \
    -t optitype -g ../goldstandard/goldstandard.csv -n -r | grep $SAMPLE
  cat result/1000GExtrChr6/optitype/${SAMPLE}*/*/*.tsv
  grep ${SAMPLE} result/1000GExtrChr6/results1000GExtrChr6.optitype.txt
  echo "-------------------"
  python bin/evaluatePredictions.py $ADD -i result/1000GExtrChr6/results1000GExtrChr6.hlavbseqTop2.txt \
    -t hlavbseq -g ../goldstandard/goldstandard.csv -n -r | grep $SAMPLE
  cat result/1000GExtrChr6/hlavbseq/${SAMPLE}_lc_HLA.txt | gawk '{if ($2>0){print $0}}'
  grep ${SAMPLE} result/1000GExtrChr6/results1000GExtrChr6.hlavbseqTop2.txt
  echo "-------------------"
  python bin/evaluatePredictions.py $ADD -i result/1000GExtrChr6/results1000GExtrChr6.hlaminersblyTop.txt \
    -t hlaminer -g ../goldstandard/goldstandard.csv -n -r | grep $SAMPLE
  cat result/1000GExtrChr6/hlaminer/${SAMPLE}_lc_sbly_HLAminer_HPTASR.csv | grep Prediction -A2
  grep ${SAMPLE} result/1000GExtrChr6/results1000GExtrChr6.hlaminersblyTop.txt


  exit

fi

#######################
# Full evaluation
#
echo "opti"
python bin/evaluatePredictions.py $ADD -i $PATHL.optitype.txt     -t optitype -g $GS -v -n -l >$PATHL.optitype.evalCI.txt
python bin/evaluatePredictions.py $ADD -i $PATHL.optitype.txt     -t optitype -g $GS -v -n  >$PATHL.optitype.evalCII.txt
tail -n 1 $PATHL.optitype.evalCI.txt
tail -n 1 $PATHL.optitype.evalCII.txt
#echo Latex $(tail -n 1 $PATHL.optitype.evalN.txt | cut -f 6,20 -d ' ')

echo hlavbseq
for i in Top2 Top5; do
  echo $i
#python bin/evaluatePredictions.py -i $PATHL.hlavbseq$i.txt -t hlavbseq -g $GS -v >$PATHL.hlavbseq$i.eval.txt
#tail -n 1 $PATHL.hlavbseq$i.eval.txt
python bin/evaluatePredictions.py $ADD -i $PATHL.hlavbseq$i.txt -t hlavbseq -g $GS -v -n -l >$PATHL.hlavbseq$i.evalCI.txt
python bin/evaluatePredictions.py $ADD -i $PATHL.hlavbseq$i.txt -t hlavbseq -g $GS -v -n >$PATHL.hlavbseq$i.evalCII.txt
tail -n 1 $PATHL.hlavbseq$i.evalCI.txt
tail -n 1 $PATHL.hlavbseq$i.evalCII.txt
done

echo hlaminer
for i in Top Top3; do
  for j in sbly aln; do
    echo $i $j
#python bin/evaluatePredictions.py -i $PATHL.hlaminer$j$i.txt -t hlaminer -g $GS -v >$PATHL.hlaminer$j$i.eval.txt
#tail -n 1 $PATHL.hlaminer$j$i.eval.txt
python bin/evaluatePredictions.py $ADD -i $PATHL.hlaminer$j$i.txt -t hlaminer -g $GS -v -n -l >$PATHL.hlaminer$j$i.evalCI.txt
python bin/evaluatePredictions.py $ADD -i $PATHL.hlaminer$j$i.txt -t hlaminer -g $GS -v -n >$PATHL.hlaminer$j$i.evalCII.txt
tail -n 1 $PATHL.hlaminer$j$i.evalCI.txt
tail -n 1 $PATHL.hlaminer$j$i.evalCII.txt
done
done

echo "phlat"
python bin/evaluatePredictions.py $ADD -i $PATHL.phlat.txt     -t phlat -g $GS -v -n -l >$PATHL.phlat.evalCI.txt
python bin/evaluatePredictions.py $ADD -i $PATHL.phlat.txt     -t phlat -g $GS -v -n >$PATHL.phlat.evalCII.txt
tail -n 1 $PATHL.phlat.evalCI.txt
tail -n 1 $PATHL.phlat.evalCII.txt


echo "seq2hla"
for i in Top Top3; do
  echo $i
python bin/evaluatePredictions.py $ADD -i $PATHL.seq2hla$i.txt     -t seq2hla -g $GS -v -n -l >$PATHL.seq2hla$i.evalCI.txt
python bin/evaluatePredictions.py $ADD -i $PATHL.seq2hla$i.txt     -t seq2hla -g $GS -v -n >$PATHL.seq2hla$i.evalCII.txt
tail -n 1 $PATHL.seq2hla$i.evalCI.txt
tail -n 1 $PATHL.seq2hla$i.evalCII.txt
done
