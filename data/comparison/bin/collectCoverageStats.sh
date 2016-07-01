COVCOLLECT=""

if [ -n "$COVCOLLECT" ]; then
  for RUN in 1000EExtrChr6 1000GExtrChr6  1000RExtrChr6; do
    echo $RUN
    echo "sample type avCov sdCov" > result/BamAvCoverage$RUN.stats
#    for i in $( ls fastq/$RUN/*bam.stats ); do

#      SAMPLE=$(basename $i)
#      SAMPLE=${SAMPLE/.bam.stats/}

    for SAMPLE in $(cat iter/collectSamples$RUN.txt); do
      echo $SAMPLE
      i=$(ls fastq/$RUN/$SAMPLE.bam.stats | grep -v "lc" | grep -v "hc")
      COVLC="NA NA"
      if [ -s $i ]; then
        COVLC=$(gawk 'ORS=" "{print $3}' $i)
      fi

    #  HC=${i/lc/hc}
    #  READHC="NA"
    #  PAIRHC="NA"
    #  if [ -e $HC ]; then
    #    READHC=$(cat $HC | grep "in total" | cut -f 1 -d " ")
    #    PAIRHC=$(cat $i | grep "properly paired" | cut -f 1 -d " ")
    #  fi

      echo $SAMPLE $RUN $COVLC >> result/BamAvCoverage$RUN.stats
    #  echo "$SAMPLE \"low Coverage\"" $COVLC >> result/BamAvCoverage$RUN.stats
    #  echo "\"high Coverage\"" $READHC $PAIRHC >> result/BamAvCoverage.stats

    done
  done
fi

# collect the samples with coverage >5
#tail -n+2 result/BamAvCoverage.stats | gawk '{if ($4>5){print $0}}' | cut -f 1 -d " " > supportingData/1000GenomesCov5xAlignments.txt
# table with coverage vs accuracy
for RUN in 1000EExtrChr6 1000GExtrChr6  1000RExtrChr6; do
	grep -v sample result/BamAvCoverage$RUN.stats | sort -k 1 > result/BamAvCoverage$RUN.stats.srt.tmp
	for i in hlamineralnTop hlaminersblyTop hlavbseqTop2 optitype phlat seq2hla; do
	  grep "SUM" result/$RUN/results$RUN.$i.evalCII.txt | cut -f 2,12,23 -d " " | sort -k 1 > result/BamAvCoverage$RUN.tool.srt.tmp
	  join -1 1 -2 1 result/BamAvCoverage$RUN.stats.srt.tmp result/BamAvCoverage$RUN.tool.srt.tmp > result/BamAvCoverage$RUN.jnd.tmp
	  mv result/BamAvCoverage$RUN.jnd.tmp result/BamAvCoverage$RUN.stats.srt.tmp
	done
	echo "sample type coverage cov.sd hlamineralnTop.2 hlamineralnTop.4 hlaminersblyTop.2 hlaminersblyTop.4 hlavbseqTop2.2 hlavbseqTop2.4 optitype.2 optitype.4 phlat.2 phlat.4 seq2hla.2 seq2hla.4" > result/BamAvCoverageNacc$RUN.txt
	cat result/BamAvCoverage$RUN.stats.srt.tmp >> result/BamAvCoverageNacc$RUN.txt
	rm result/BamAvCoverage$RUN.stats.srt.tmp result/BamAvCoverage$RUN.tool.srt.tmp

	head result/BamAvCoverageNacc$RUN.txt
done

cat result/BamAvCoverageNacc1000EExtrChr6.txt result/BamAvCoverageNacc1000RExtrChr6.txt result/BamAvCoverageNacc1000GExtrChr6.txt | sort -u -r > result/BamAvCoverageacc.txt.tmp
gawk '{if (NF==16){print $0}}' result/BamAvCoverageacc.txt.tmp > result/BamAvCoverageacc.txt
rm result/BamAvCoverageacc.txt.tmp
rm result/BamAvCoverageNacc1000EExtrChr6.txt result/BamAvCoverageNacc1000RExtrChr6.txt result/BamAvCoverageNacc1000GExtrChr6.txt


cat result/BamAvCoverage1000GExtrChr6.stats > result/BamAvCoverage.stats.tmp
tail -n+2 result/BamAvCoverage1000EExtrChr6.stats >> result/BamAvCoverage.stats.tmp
tail -n+2 result/BamAvCoverage1000RExtrChr6.stats >> result/BamAvCoverage.stats.tmp
gawk '{if (NF==4){print $0}}' result/BamAvCoverage.stats.tmp > result/BamAvCoverage.stats
rm result/BamAvCoverage.stats.tmp
