#!/bin/sh -e

#SBATCH --time=2:00:00
#SBATCH --mem=16gb
##SBATCH --cpus-per-task=8
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=20
#SBATCH --job-name=hlavbseq
###SBATCH --out out/hlavbseq.out
#SBATCH --out out/hlavbseq_%A_%a.out
echo $SLURM_JOBID

############################################################
# NOTE: Straight forward
# cd supportingData/hlavbseq/
# wget http://nagasakilab.csml.org/hla/hla_all.fasta
# wget http://nagasakilab.csml.org/hla/parse_result.pl
# wget http://nagasakilab.csml.org/hla/Allelelist.txt
# DATE: 2015
# DATA: DNA
# PROGRESS: DONE - FINISHED confirmed
# OUTPUT: not allele specific but score based
############################################################


. ./config.txt

##############
# Variables
##############
INTYPE=$3 #FASTQ/BAM

##SLURM_ARRAY_TASK_ID=1
#READ1=$(head -n ${SLURM_ARRAY_TASK_ID} sampeIDs.txt | tail -1)
READ1=$1
READ2=${READ1/$READ1NAME/$READ2NAME}
BAM=$1
module unload perl
dmget $READ1 $READ2

module load use.own
module load hlavbseq/20151204
module load bwa
module load perl

TOOL=hlavbseq



NAME=$(basename $READ1)
NAME=${NAME/$ENDING/}

echo "Run $NAME with $TOOL"
echo "$READ1 $READ2"

FASTA=supportingData/$TOOL/hla_all.fasta
TMP=/flush1/bau04c/HLA/$TOOL/$RANDOM/
OUT=$2/$TOOL/
PARSER=supportingData/$TOOL/parse_result.pl
ALLELLIST=supportingData/$TOOL/Allelelist.txt

mkdir -p $TMP
mkdir -p $OUT

JAVAPARAMS="-Xmx14g -Djava.io.tmpdir="$TMP"  -XX:ConcGCThreads=1 -XX:ParallelGCThreads=1"
unset _JAVA_OPTIONS
echo "JAVAPARAMS "$JAVAPARAMS


#############################
# From BAM alignment-based
#############################
if [ "$INTYPE" = "BAM" ]; then
  SECONDS=0
  samtools view $BAM chr6:29907037-29915661 chr6:31319649-31326989 chr6:31234526-31241863 \
          chr6:32914391-32922899 chr6:32900406-32910847 chr6:32969960-32979389 chr6:32778540-32786825 \
          chr6:33030346-33050555 chr6:33041703-33059473 chr6:32603183-32613429 chr6:32707163-32716664 \
          chr6:32625241-32636466 chr6:32721875-32733330 chr6:32405619-32414826 chr6:32544547-32559613 \
          chr6:32518778-32554154 chr6:32483154-32559613 chr6:30455183-30463982 chr6:29689117-29699106 \
          chr6:29792756-29800899 chr6:29793613-29978954 chr6:29855105-29979733 chr6:29892236-29899009 \
          chr6:30225339-30236728 chr6:31369356-31385092 chr6:31460658-31480901 chr6:29766192-29772202 \
          chr6:32810986-32823755 chr6:32779544-32808599 chr6:29756731-29767588 \
          | awk '{print $$1}' | sort | uniq > $TMP/${NAME}_partial.txt

  #Build read name index and search read pairs and their sequences on HLA loci
  java -jar -Xmx64g -Xms64g ${HLAVBSEQ_HOME}/bin/bamNameIndex.jar index $BAM --indexFile $BAM.idx
  java -jar ${HLAVBSEQ_HOME}/bin/bamNameIndex.jar search $BAM --name $TMP/${NAME}_partial.txt --output $TMP/${NAME}_partial.sam
  java -jar ${HLAVBSEQ_HOME}/bin/SamToFastq.jar I=$TMP/${NAME}_partial.sam F=$TMP/${NAME}_partial_1.fastq F2=$TMP/${NAME}_partial_2.fastq

  #Extract unmapped reads
  samtools view -bh -f 12 $BAM > $TMP/${NAME}.sorted_unmapped.bam
  java -jar ${HLAVBSEQ_HOME}/bin/SamToFastq.jar I=$TMP/${NAME}.sorted_unmapped.bam F=$TMP/${NAME}_unmapped_1.fastq F2=$TMP/${NAME}_unmapped_2.fastq
  #Combine reads in FASTQ format
  cat $TMP/${NAME}_partial_1.fastq $TMP/${NAME}_unmapped_1.fastq > $TMP/${NAME}_part_1.fastq
  cat $TMP/${NAME}_partial_2.fastq $TMP/${NAME}_unmapped_2.fastq > $TMP/${NAME}_part_2.fastq
  echo "CSIRO EXTRACTING $SECONDS seconds"

fi


#############################
# From FASTQ alignment-based
#############################
SECONDS=0
echo "---Alignment by BWA-MEM allowing multiple alignments for each read"
if [ ! -e $FASTA.amb ]; then echo "index"; bwa index $FASTA; fi
bwa mem -t 8 -P -L 10000 -a $FASTA $READ1 $READ2 > $TMP/${NAME}_part.sam
echo "CSIRO MAPPING $SECONDS seconds"

SECONDS=0
echo "---Estimation of HLA types by HLA-VBSeq"
command="java -jar ${HLAVBSEQ_HOME}/bin/HLAVBSeq.jar $FASTA $TMP/${NAME}_part.sam $OUT/${NAME}_freq.txt --alpha_zero 0.01 --is_paired"
echo $command && eval $command

echo "---Parse results"
command="perl $PARSER $ALLELLIST $OUT/${NAME}_freq.txt > $OUT/${NAME}_HLA.txt"
echo $command && eval $command

echo "CSIRO TYPING $SECONDS seconds"


echo "---cleanup"
rm -r $TMP

echo "FINISHED Run $NAME with $TOOL"
