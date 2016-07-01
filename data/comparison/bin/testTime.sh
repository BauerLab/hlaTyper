#!/bin/sh

#SBATCH --time=3:00:00
#SBATCH --mem=4gb
#SBATCH --job-name=testTime
#SBATCH --out out/testTime.out

################
# DNA
################
#RUN=1000GExtrChr6
#RESULTS=resources$RUN.txt
#PROGRAMS="hlaminerDNAalignment hlaminerDNAassembly hlavbseq seq2hla optitypeDNA phlat"
#DATA="WGS"

################
# Exon
################
#RUN=1000EExtrChr6
#RESULTS=resources$RUN.txt
#PROGRAMS="hlaminerDNAalignment hlaminerDNAassembly hlavbseq seq2hla optitypeDNA phlat"
#DATA="WES"


################
# RNA
################
RUN=1000RExtrChr6
RESULTS=resources$RUN.txt
PROGRAMS="hlaminerDNAalignment hlaminerDNAassembly hlavbseq seq2hla optitypeDNA phlat"
DATA="RNA"



#echo "successful"
#for i in $(ls out/$RUN/*.out); do
#  tail $i | grep FINISHED -l
#done | wc -l

echo "Tool Sample Type Value original ID Data" > $RESULTS

if [ -n "$PROGRAMS" ]; then
#for p in athlates hlaminerDNAalignment hlaminerDNAassembly hlavbseq optitypeDNA; do
for p in $PROGRAMS; do
  echo $p
  for  i in $(ls out/$RUN/*_$p.out); do
    FINISHED=$(tail -n 1 $i | grep FINISHED -l)
    if [ -z "$FINISHED" ];then continue; fi
    NAME=$(basename $i)
    NAME=${NAME/_*/}
    #echo $NAME
    SLURMID=$(head -n 1 $i)
    grep -w CSIRO $i | sed 's/CSIRO/'$p" "$NAME'/g' | sed 's/ seconds//g' | gawk -v V=$SLURMID -v V2=$DATA '{print $0" "V" 0 "V2}' >> $RESULTS
    # bring all to KB unit
    MEM=$(sacct -j $SLURMID -p | tail -n 1 | cut -d'|' -f 10 \
      | gawk '{if ($0~"G"){print $0*1000000" "$0} else { if ($0~"M"){ print $0*1000" "$0} else {print $0*1" "$0}}}')
    #TIME=$(sacct -j $SLURMID -p | tail -n 1 | cut -d'|' -f 7)
    echo "$p $NAME mem $MEM $SLURMID $DATA" >>$RESULTS
    #echo "$p $NAME Time $TIME" >>$RESULTS
  done
done
fi

#ls $RESULTS
#tail +2 resources1000GExtrChr6.txt  >> resources.txt
cat resources1000GExtrChr6.txt > resources.txt
tail +2 resources1000EExtrChr6.txt >> resources.txt
tail +2 resources1000RExtrChr6.txt >> resources.txt

gawk '{if (NF==7) {print $0}}' resources.txt > resources2.txt

exit

for i in $(ls out/1000GExtr/extract* ); do
  SLURMID=$(head -n 1 $i)
  MEM=$(sacct -j $SLURMID -p | grep COMPLETED | tail -n 1 | cut -d'|' -f 10 | sed 's/K//g')
  TIME=$(sacct -j $SLURMID -p | grep COMPLETED | tail -n 1 | cut -d'|' -f 7)
  echo $MEM $TIME
done
