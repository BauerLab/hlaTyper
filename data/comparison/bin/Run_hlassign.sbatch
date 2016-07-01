#!/bin/sh -e

#SBATCH --time=2:00:00
#SBATCH --mem=16gb
#SBATCH --job-name=hlassign
##SBATCH --cpus-per-task=8
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=20
#SBATCH --out hlassign.out
##SBATCH --out out/hlassign_%A_%a.out


############################################################
# NOTE:
# DATE: 2015
# DATA: ?
# PROGRESS:
# bin/Run_hlassign.sbatch fastq/1000GExtr/HG00099_lc_R1.fastq.gz result/1000GExtr/
############################################################


TOOL=hlassign
. ./config.txt

#READ1=$1
READ1=fastq/1000GExtr/HG00099_lc_R1.fastq.gz
READ2=${READ1/$READ1NAME/$READ2NAME}
module unload perl
dmget $READ1 $READ2

module load use.own
module load hlassign/pilot
module load ucsctools/326
module load R

NAME=$(basename $READ1)
NAME=${NAME/$ENDING/}

echo "Run $NAME with $TOOL"
echo "$READ1 $READ2"

TMP=/flush1/bau04c/HLA/$TOOL/$RANDOM/
#TMP=/flush1/bau04c/HLA/hlassign/25130/
#OUT=$2/$TOOL/
OUT=result/1000GExtr/$TOOL/

echo $TMP

mkdir -p $TMP
mkdir -p $OUT

#############################
# From FASTQ alignment-based
#############################

SECONDS=0

#1. Filter for reads that passed QC
#This step is optional, but we've always filtered our fastq files. With the most recent casava pipeline, the filtering should be performed by default.
# Not sure what filtering refers to here

#2. extract and truncate the fastq reads
echo "---extract and truncate"
# assuming your fastq files are packed as gz archive and you have a read length of 100, run following command to prepare your fastq file(s)
for i in $READ1 $READ2; do
  R=$(basename $i)
  R=${R/$E/}
  echo $R
  zcat $i | awk '{if( (NR+3)%4==0 || (NR+1)%4==0) {print$0} if( (NR+2)%4==0 || NR%4==0 ) {print(substr($0,1,100))}}' > ${TMP}/$R.fastq

  echo "---run prefilterhlareads"
  # Now pass the reads to the prefilterhlareads software. The file HLA_v3.12_block_wise.fasta is part of the source package
  prefilterhlareads --Ref ${HLASSIGN_HOME}/HLA_v3.12_block_wise.fasta \
    --fastq ${TMP}/$R.fastq --read_length 100 --min_alignment 30 \
    --on-target ${TMP}/$R.ontarget.fastq \
    --off-target ${TMP}/$R.offtarget.fastq
done


#3. Run the analysis
echo "---extract"
# extract the fastq files:
#zcat ${TMP}/*.ontarget.fastq.gz > ${TMP}/all_in_one.fastq
cat ${TMP}/*.ontarget.fastq > ${TMP}/all_in_one.fastq


# prefilter again for better run time. Replace THELOCUS in the following commands with the locus name that you are interested in (e.g. A, B or DRB1)
# replace 100 with the appropriate read length, if required ...
echo "---call"
for i in A B C DRB1 DPA DPB DQA DQB; do
  gethlamultialignexonwise ${HLASSIGN_HOME}/IMGTv312/${i}_nuc.txt > ${TMP}/${i}_hlp.txt

  prefilterhlareads --Ref ${TMP}/${i}_hlp.txt \
    --fastq ${TMP}/all_in_one.fastq --read_length 100 --min_alignment 30 \
    --on-target ${TMP}/${i}_reads_to_map.fastq \
    --off-target ${TMP}/${i}_reads_to_skip.fastq

  # this was wrong on readme - would have produced empty output
  #awk '{if( (NR+3)%4==0 ) {split($0, a, " "); print">"a[1]"/"NR} if( (NR+2)%4==0 ) {print(substr($0,1,100))}}' ${TMP}/${i}_reads_to_map.fastq > ${TMP}/${i}_reads_to_map.fasta

  awk '{if( (NR+3)%4==0 ) {split($0, a, " "); print">"a[1]"/"NR} if( (NR+2)%4==0 ) {print(substr($0,1,100))}}' ${TMP}/${i}_reads_to_map.fastq > ${TMP}/${i}_reads_to_map2.fasta
  mv ${TMP}/${i}_reads_to_map2.fasta ${TMP}/${i}_reads_to_map.fasta

done

cd ${TMP}
mkdir -p ${TMP}/pics
mkdir -p ${TMP}/scratch

echo "---collect"
for i in A B C DRB1 DPA DPB DQA DQB; do
  echo $i
  # run the analysis
  # the files incomplete_alleles.txt and ambiguity_table.txt come with the source package. make sure to set the right path
  # the parameter --gDNA is a remaining of our first attempts. It must be set but will noz be considered during the analysis ....
  nextcallhla --cDNA ${HLASSIGN_HOME}/IMGTv312/${i}_nuc.txt --gDNA ${TMP}/${i}_gen.txt \
    --scratch ${TMP}/scratch --out ${TMP}/result.txt \
    --outPic ${TMP}/pics/ --bias-alleles ${HLASSIGN_HOME}/incomplete_alleles.txt \
    --amb-table ${HLASSIGN_HOME}/ambiguity_table.txt \
    --reads ${TMP}/${i}_reads_to_map.fasta --read-length 100

  cp ${TMP}/pics/* ${OUT}/$NAME/
  cp ${TMP}/result.txt ${OUT}/${NAME}_${i}_calls_unsorted.txt
done

rm -f ${OUT}/${NAME}_the_calls.txt
#4. extract results
# extract calls and store in a file called the_calls.txt
echo "---extract"
for j in A B C DRB1 DPA DPB DQA DQB
do
   THECALL=`grep -A 1 "[Result]" ${OUT}/${NAME}_${j}_calls_unsorted.txt | tail -1`
   echo $NAME $j $THECALL | awk 'BEGIN {IFS=" "}; END {if( NF <= 7 ){print $0} else {print $1" "$2" nocall nocall - -"}}' >> ${OUT}/${NAME}_the_calls.txt
   for k in `sort -k 8,8n ${OUT}/${NAME}_${j}_calls_unsorted.txt | awk '{if( NF == 8 && $8 != 0){print $0}}' | head -5 | cut -f 1 | sed -re 's/\*/-/g'`
   do
      # we copy all pictures, that may be needed for manual verification, to a separate folder
      mkdir -p ${THERESULTDIR}/verify/
      cp ${THERESULTDIR}/pics/${k}.png ${THERESULTDIR}/verify/${i}
  done
done


echo "CSIRO TYPING $SECONDS seconds"

#echo "---cleanup"
#rm -r $TMP

echo "FINISHED Run $NAME with $TOOL"
