

echo "type reads paired" > result/BamCoverage.stats

for i in $( ls fastq/1000GExtrChr6/*_lc.stats | grep -v -P "(NA19238|NA19239|NA19240)" ); do
  READLC=$(cat $i | grep "in total" | cut -f 1 -d " ")
  PAIRLC=$(cat $i | grep "properly paired" | cut -f 1 -d " ")

  HC=${i/lc/hc}
  READHC="NA"
  PAIRHC="NA"
  if [ -e $HC ]; then
    READHC=$(cat $HC | grep "in total" | cut -f 1 -d " ")
    PAIRHC=$(cat $i | grep "properly paired" | cut -f 1 -d " ")
  fi

  echo "\"low Coverage\"" $READLC $PAIRLC >> result/BamCoverage.stats
  echo "\"high Coverage\"" $READHC $PAIRHC >> result/BamCoverage.stats

done
