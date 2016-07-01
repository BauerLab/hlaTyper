RUNEXTRACT=""
RUNHLAVBSEQ="1" #G4 #R46
RUNOPTITYPE="1"
RUNHLAMINER="1"
RUNPHLAT="1"
RUNSEQ2HLA="1"

#cut -d'/' -f3 | cut -f 1 -d '_'

#Full
#RUN=1000GExtrChr6
#OUT=out/${RUN}log
#mkdir -p $OUT
#grep FINISHED out/$RUN/extract*.out >iter/collectSamples.txt
#ITER=iter/collectSamples.txt
#command="cat out/1000GExtrChr6log/hlavbseqInvocationTargetException.txt out/1000GExtrChr6log/hlavbseqCmdLineException.txt | cut -d'/' -f3 | cut -f 1 -d '_' > iter/run_hlavbseq.txt; wc -l iter/run_hlavbseq.txt"

#Exon
# remove NA19318
RUN=1000EExtrChr6
OUT=out/${RUN}log
mkdir -p $OUT
#grep FINISHED out/$RUN/extract*.out | grep -v "NA19318" | sed 's/out\/1000EExtrChr6\/extract_//g' | sed 's/.out:FINISHED//g' >iter/collectSamples$RUN.txt
ITER=iter/collectSamples$RUN.txt


#RNAseq
#RUN=1000RExtrChr6
#OUT=out/${RUN}log
#mkdir -p $OUT
## cp iter/runRNA.txt iter/collectSamples$RUN.txt
#ITER=iter/collectSamples$RUN.txt
#command="cat out/1000RExtrChr6log/hlavbseqInvocationTargetException.txt out/1000RExtrChr6log/hlavbseqCmdLineException.txt | cut -d'/' -f3 | cut -f 1 -d '_' > iter/runR_hlavbseq.txt; wc -l iter/runR_hlavbseq.txt"


# HC
#ls fastq/1000GExtrChr6/*hc*_R1* | sed 's/fastq\/1000GExtrChr6\///g' | sed 's/_hc_R1.fastq.gz//g' | grep -P -v "(NA19238|NA19239|NA19240)" > iter/runHC.txt
#ITER=iter/runHC.txt


#############################
# check output from the extraction
#############################
if [ -n "$RUNEXTRACT" ]; then
  UNSUCCESFUL=$(for i in $(ls out/$RUN/extract*.out); do
    if [[ $(tail $i | grep FINISHED -L) ]]; then
      echo $i
    fi
   done)

  echo total samples $(ls out/$RUN/extract_* | wc -l)
  echo extract unsuccessful $(echo $UNSUCCESFUL | wc -w)

  NOALIGNMENTAVAIL=$OUT/"noalignmentavail.txt"
  rm -f $NOALIGNMENTAVAIL
  for i in $UNSUCCESFUL; do
    grep "No such file or directory" $i -l >> $NOALIGNMENTAVAIL
    grep "No such file or directory" $i -L
  done

  echo "no alignment available"
  wc -l $OUT/"noalignmentavail.txt"
  echo "------------------------------"
fi

#############################
# check output from hlavbseq
#############################
if [ -n "$RUNHLAVBSEQ" ]; then
  rm -f $OUT/hlavbseq*.txt

#  for i in $(grep FINISHED out/$RUN/extract*.out); do
  for i in $(cat $ITER); do
    ID=${i/*_/}
    ID=${ID/.out*/}
    if [ ! -e out/$RUN/$ID*hlavbseq*.out ]; then
        echo /home/d/1000genomes/phase3/data/$ID >> $OUT/"hlavbseq_missing.txt"
    fi
  done
  echo "hlavbseq rerun (missing)" $(wc -l $OUT/hlavbseq_missing.txt)

  UNSUCCESFUL=$(for i in $(ls out/$RUN/*hlavbseq*.out); do
    if [[ $(tail $i | grep FINISHED -L) ]]; then
      echo $i
    fi
   done)

  echo total samples $(ls out/$RUN/*hlavbseq* | wc -l)
  echo hlavbseq unsuccessful $(echo $UNSUCCESFUL | wc -w)

  HLAVBSEQKNOWN1=$OUT/"hlavbseqInvocationTargetException.txt"
  HLAVBSEQKNOWN2=$OUT/"hlavbseqCmdLineException.txt"
  for i in $UNSUCCESFUL; do
    grep "InvocationTargetException" $i -l >> $HLAVBSEQKNOWN1
    grep "CmdLineException" $i -l >> $HLAVBSEQKNOWN2
    grep -P "(InvocationTargetException|CmdLineException)" $i -L
  done
  echo "hlavbseq hlavbseqInvocationTargetException"
  wc -l $OUT/"hlavbseqInvocationTargetException.txt"
  echo "hlavbseq hlavbseqCmdLineException"
  wc -l $OUT/"hlavbseqCmdLineException.txt"
  echo "------------------------------"

fi

#############################
# check output from optitype
#############################
if [ -n "$RUNOPTITYPE" ]; then

  rm -f $OUT/optitype*.txt

  #for i in $(grep FINISHED out/$RUN/extract*.out); do
  for i in $(cat $ITER); do
    ID=${i/*_/}
    ID=${ID/.out*/}
    if [ ! -e out/$RUN/$ID*optitype*.out ]; then
        echo /home/d/1000genomes/phase3/data/$ID >> $OUT/"optitype_missing.txt"
    fi
  done
  echo "optitype rerun (missing)" $(wc -l $OUT/optitype_missing.txt)

  UNSUCCESFUL=$(for i in $(ls out/$RUN/*optitypeDNA*.out); do
    if [[ $(tail $i | grep FINISHED -L) ]]; then
      echo $i
    fi
   done)

  echo total samples $(ls out/$RUN/*optitypeDNA* | wc -l)
  echo optitypeDNA unsuccessful $(echo $UNSUCCESFUL | wc -w)

  OPTITYPEKNOWN1=$OUT/"optitypeunpaired_weight.txt"
  OPTITYPEKNOWN2=$OUT/"optitypeoptimization.txt"
  OPTITYPEKNOWN3=$OUT/"optitypeHiddenFiles.txt"
  OPTITYPRERUN=$OUT/"optitype_rerun.txt"
  for i in $UNSUCCESFUL; do
    grep "unpaired_weight" $i -l >> $OPTITYPEKNOWN1
    grep "Infeasible" $i -l >> $OPTITYPEKNOWN2
    grep "Directory not empty" $i -l >> $OPTITYPEKNOWN3
    grep "DUE TO TIME LIMIT" $i -l >> $OPTITYPRERUN
    grep -P "(unpaired_weight|DUE TO TIME LIMIT|Infeasible|Directory not empty)" $i -L
  done
  echo "optitypeDNA optitypeunpaired_weight"
  wc -l $OUT/"optitypeunpaired_weight.txt"
  echo "optitypeDNA optitypeoptimization"
  wc -l $OUT/"optitypeoptimization.txt"
  echo "optitypeDNA optitypeHiddenFiles"
  wc -l $OUT/"optitypeHiddenFiles.txt"
  echo "RERUN optitype timelimit"
  wc -l $OUT/"optitype_rerun.txt"
  echo "------------------------------"

fi

#############################
# check output from hlaminer
#############################
if [ -n "$RUNHLAMINER" ]; then

  for t in alignment assembly; do
    rm -f $OUT/hlaminer*$t*.txt

  #  for i in $(grep FINISHED out/$RUN/extract*.out); do
    for i in $(cat $ITER); do
      ID=${i/*_/}
      ID=${ID/.out*/}
      if [ ! -e out/$RUN/$ID*hlaminerDNA${t}*.out ]; then
          echo /home/d/1000genomes/phase3/data/$ID >> $OUT/"hlaminer${t}_missing.txt"
      fi
    done
    echo "hlaminer${t} rerun (missing)" $(wc -l $OUT/hlaminer${t}_missing.txt)

    UNSUCCESFUL=$(for i in $(ls out/$RUN/*hlaminerDNA${t}*.out); do
      if [[ $(tail $i | grep FINISHED -L) ]]; then
        echo $i
      fi
     done)

    echo total ${t} samples $(ls out/$RUN/*hlaminerDNA${t}* | wc -l)
    echo hlaminer${t} unsuccessful $(echo $UNSUCCESFUL | wc -w)
    HLAMINERKNOWN1=$OUT/"hlaminerHiddenFiles${t}.txt"
    HLAMINERKNOWN2=$OUT/"hlaminerDivByZero${t}.txt"
    HLAMINERRUN=$OUT/"hlaminer${t}_rerun.txt"

    for i in $UNSUCCESFUL; do
      grep "Directory not empty" $i -l >> $HLAMINERKNOWN1
      grep "Illegal division by zero at" $i -l  >> $HLAMINERKNOWN2
      grep "DUE TO TIME LIMIT" $i -l | >> $HLAMINERRUN
      grep -P "(Directory not empty| DUE TO TIME LIMIT|Illegal division by zero at)" $i -L
    done
    echo "hlaminer${t} hlaminerHiddenFiles"
    wc -l $OUT/"hlaminerHiddenFiles${t}.txt"
    echo "hlaminer hlaminerDivByZero"
    wc -l $OUT/"hlaminerDivByZero${t}.txt"
    echo "RERUN hlaminer timelimit"
    wc -l $OUT/"hlaminer${t}_rerun.txt"
    #sed -i 's/out\/1000GExtrChr6/\/home\/d\/1000genomes\/phase3\/data\//g' hlaminerassembly_rerun.txt | sed -i 's/_hlaminerDNAassembly.out//g'
    echo "------------------------------"
  done

fi


#############################
# check output from phlat
#############################
if [ -n "$RUNPHLAT" ]; then
  rm -f $OUT/phlat*.txt

#  for i in $(grep FINISHED out/$RUN/extract*.out); do
  for i in $(cat $ITER); do
    ID=${i/*_/}
    ID=${ID/.out*/}
    if [ ! -e out/$RUN/$ID*phlat*.out ]; then
        echo /home/d/1000genomes/phase3/data/$ID >> $OUT/"phlat_missing.txt"
    fi
  done
  echo "phlat rerun (missing)" $(wc -l $OUT/phlat_missing.txt)

  UNSUCCESFUL=$(for i in $(ls out/$RUN/*phlat*.out); do
    if [[ $(tail $i | grep FINISHED -L) ]]; then
      echo $i
    fi
   done)

  echo total samples $(ls out/$RUN/*phlat* | wc -l)
  echo phlat unsuccessful $(echo $UNSUCCESFUL | wc -w) add the error ones too

  PHLATKNOWN1=$OUT/"phlat_rerun.txt"
  PHLATKNOWN2=$OUT/"phlat_error.txt"
  for i in $UNSUCCESFUL; do
    grep "DUE TO TIME LIMIT" $i -l >> $PHLATKNOWN1
    grep -P "(DUE TO TIME LIMIT)" $i -L
  done
  grep ERROR out/$RUN/*phlat*.out > $PHLATKNOWN2
  echo "phlat rerun timelimit "
  wc -l $OUT/"phlat_rerun.txt"
  echo "phlat error "
  wc -l $OUT/"phlat_error.txt"
  echo "------------------------------"
fi

#############################
# check output from phlat
#############################
if [ -n "$RUNSEQ2HLA" ]; then
  rm -f $OUT/seq2hla*.txt

#    for i in $(grep FINISHED out/$RUN/extract*.out); do
  for i in $(cat $ITER); do
    ID=${i/*_/}
    ID=${ID/.out*/}
    if [ ! -e out/$RUN/$ID*seq2hla*.out ]; then
        echo /home/d/1000genomes/phase3/data/$ID >> $OUT/"seq2hla_missing.txt"
    fi
  done
  echo "seq2hla rerun (missing)" $(wc -l $OUT/seq2hla_missing.txt)

  UNSUCCESFUL=$(for i in $(ls out/$RUN/*seq2hla*.out); do
    if [[ $(tail $i | grep FINISHED -L) ]]; then
      echo $i
    fi
   done)

  echo total samples $(ls out/$RUN/*seq2hla* | wc -l)
  echo seq2hla unsuccessful $(echo $UNSUCCESFUL | wc -w)

  SEQ2HLAKNOWN1=$OUT/"seq2hla_rerun.txt"
  for i in $UNSUCCESFUL; do
    grep "list index out of range" $i -l >> $SEQ2HLAKNOWN1
    grep -P "(list index out of range)" $i -L
  done
  echo "seq2hla rerun list index out of range "
  wc -l $SEQ2HLAKNOWN1
  echo "------------------------------"

fi

eval $command


exit

echo "successful"
for i in $(ls out/$RUN/*.out); do
  tail $i | grep FINISHED -l
done | wc -l
