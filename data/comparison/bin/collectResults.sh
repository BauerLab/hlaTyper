#
# Collect results from all runs before the accuracy is evaluated.
#


########
# For rmdups without -S
########
#RUN=1000GExtrChr6NS
#TYPE="_lc_"
#RESULT=result/1000GExtrChr6NS/$RUN

#####
# For WGS
#####
RUN=1000GExtrChr6
TYPE="_lc"
RESULT=result/$RUN/results$RUN
ITER=iter/collectSamples$RUN.txt

#####
# For WES
#####
#RUN=1000EExtrChr6
#TYPE="WES"
#RESULT=result/$RUN/results$RUN
#ITER=iter/collectSamples$RUN.txt

#####
# For RNA
#####
#RUN=1000RExtrChr6
#TYPE=""
#RESULT=result/$RUN/results$RUN
#ITER=iter/runRNA.txt


#RUN=1000GExtrChr6HC
#TYPE="_hc_"
#RESULT=result/1000GExtrChr6HC/$RUN
#RESULT=result/1000GExtrChr6/$RUN
#RESULT=result/1000GExtrChr6HC/results1000GExtrChr6
mkdir -p result/$RUN/
# for only high coverage ones
# exclude NA19238 NA19239 NA19240 because they don't have reads in their bamfile
#ls fastq/1000GExtrChr6/*hc*_R1* | sed 's/fastq\/1000GExtrChr6\///g' | sed 's/_hc_R1.fastq.gz//g' | grep -v -P "(NA19238|NA19239|NA19240)" > iter/collectSamplesHC.txt
#ITER=iter/collectSamplesHC.txt

# Extract information from the result file and bring them in the same format
#
rm $(ls $RESULT.*.txt | grep -v "eval")
TMP=/flush1/bau04c/HLA/collectResult$RUN/
rm -fr $TMP
mkdir -p $TMP
for i in $(cat $ITER ); do
  SAMPLE=${i/*_/}
  SAMPLE=${SAMPLE/.*/}
  echo $SAMPLE

  #seq2hla
  LIST=""
  for t in A B C DRB1 DQB1 DQA1 ; do
     grep -w $t"/*" result/$RUN/seq2hla/${SAMPLE}*${TYPE}.HLAgenotype4digits | cut -f 2,4 \
      | sed 's/'$t'\*//g' | sed 's/\t/|/g'| sed "s/'//g" > $TMP/$SAMPLE.seq2hla.$t.tmp
     if [ ! -s $TMP/$SAMPLE.seq2hla.$t.tmp ]; then echo -e "|" > $TMP/$SAMPLE.seq2hla.$t.tmp; fi
     LIST=$LIST" "$TMP/$SAMPLE.seq2hla.$t.tmp
  done
  OUT=$(cat $LIST | paste -d "|" - - - - - -)
  echo $SAMPLE $OUT >> $RESULT.seq2hlaTop.txt
  FL=$(ls result/$RUN/seq2hla/${SAMPLE}*${TYPE}.HLAgenotype4digits)
  python bin/parseSeq2hla.py -i ${FL/.HLAgenotype4digits/} -s $SAMPLE -t 3 >> $RESULT.seq2hlaTop3.txt

  #phlat A B C DQA1 DQB1 DRB1
  LIST=""
  for t in A B C DRB1 DQB1 DQA1 ; do
     grep -w $t"/*" result/$RUN/phlat/${SAMPLE}*${TYPE}*HLA.sum | cut -f 2,3 \
      | sed 's/'$t'\*//g' | sed 's/\t/|/g' > $TMP/$SAMPLE.phlat.$t.tmp
     if [ ! -s $TMP/$SAMPLE.phlat.$t.tmp ]; then echo -e "|" > $TMP/$SAMPLE.phlat.$t.tmp; fi
     LIST=$LIST" "$TMP/$SAMPLE.phlat.$t.tmp
  done
  OUT=$(cat $LIST | paste -d "|" - - - - - -)
  echo -e $SAMPLE $OUT >> $RESULT.phlat.txt
  rm $TMP/$SAMPLE.phlat.*.tmp

  #optitype  A1 A2 B1 B2 C1 C2
  #cat result/1000GExtr/optitype/HG00097_lc/2016_01_18_17_19_46/2016_01_18_17_19_46_result.tsv
  cat result/$RUN/optitype/${SAMPLE}*${TYPE}/*/*.tsv | tail -n 1 | sed 's/[ABC]\*//g' \
    | gawk -v V=$SAMPLE '{print V" "$2" "$3" "$4" "$5" "$6" "$7}' >> $RESULT.optitype.txt


  #hlavbseq A B C DQA1 DQB1 DRB1
  #gawk '{if ($2!=0){print $0}}' result/1000GExtr/hlavbseq/HG00097_lc_HLA.txt
  gawk '{if ($2!=0){print $0}}' result/$RUN/hlavbseq/${SAMPLE}*${TYPE}*HLA.txt > $TMP/$SAMPLE.hlavbseq.part.tmp
  OUTTWO=$(for t in A B C DRB1 DQB1 DQA1 ; do
     grep -w $t"/*" $TMP/$SAMPLE.hlavbseq.part.tmp | gawk '{if ($2!=0) {print $0}}' \
      | sort -gk 2 -r | head -n 2 \
      | sed 's/'$t'\*//g' | cut -f 1 \
      | gawk '{ORS="/"; print}END{print " "}'
    done | sed 's/\/ \// /g' | sed 's/ *$//')
  OUTFIVE=$(for t in A B C DRB1 DQB1 DQA1 ; do
     grep -w $t"/*" $TMP/$SAMPLE.hlavbseq.part.tmp | gawk '{if ($2!=0) {print $0}}' \
      | sort -gk 2 -r | head -n 5 \
      | sed 's/'$t'\*//g' | cut -f 1 \
      | gawk '{ORS="/"; print}END{print " "}'
    done | sed 's/\/ \// /g' | sed 's/ *$//')
  echo $SAMPLE $OUTTWO >> $RESULT.hlavbseqTop2.txt
  echo $SAMPLE $OUTFIVE >> $RESULT.hlavbseqTop5.txt
  rm $TMP/$SAMPLE.hlavbseq.part.tmp

  #hlaminer
  for m in aln sbly; do
    python bin/parseHLAminer.py -i result/$RUN/hlaminer/${SAMPLE}*${TYPE}*${m}*.csv -s $SAMPLE -t 1 >>$RESULT.hlaminer${m}Top.txt
    python bin/parseHLAminer.py -i result/$RUN/hlaminer/${SAMPLE}*${TYPE}*${m}*.csv -s $SAMPLE -t 3 >>$RESULT.hlaminer${m}Top3.txt
  done

done



rm -fr $TMP
