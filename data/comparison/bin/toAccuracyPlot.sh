
ACCURACY="accuracy.txt"
#ACCURACY="accuracy_certainGT.txt"


###########
# WGS
###########
echo "WGS"
PATHL=result/1000GExtrChr6/results1000GExtrChr6
ADD="iter/collectSamples1000GExtrChr6.txt"
#ADD="supportingData/1000GenomesCertainGTG.txt"
./bin/eval.sh $PATHL $ADD > tmpWGS.txt

###########
# WES
###########
echo "WES"
PATHL=result/1000EExtrChr6/results1000EExtrChr6
ADD="iter/collectSamples1000EExtrChr6.txt" # limit to samples from exon dataset
#ADD="supportingData/1000GenomesCertainGTE.txt"
./bin/eval.sh $PATHL $ADD > tmpWES.txt

###########
# RNA
###########
echo "RNA"
PATHL=result/1000RExtrChr6/results1000RExtrChr6
ADD="iter/runRNA.txt" # limit to samples from RNA dataset
#ADD="supportingData/1000GenomesCertainGTR.txt"
./bin/eval.sh $PATHL $ADD > tmpRNA.txt

echo "Data"

echo "Tool Data Resolution Class Accuracy Success Fail" > $ACCURACY
for i in tmpWGS.txt tmpWES.txt tmpRNA.txt; do
 DATA=${i/tmp/}
 DATA=${DATA/.txt/}
 #optitype
 OP2ISA=$(sed -n 2,2p $i | gawk '{print $12*100" "$9*100}')
 OP2IISA=$(sed -n 3,3p $i | gawk '{print $12*100" "$9*100}')
 OP4ISA=$(sed -n 2,2p $i | gawk '{print $23*100" "$20*100}')
 OP4IISA=$(sed -n 3,3p $i | gawk '{print $23*100" "$20*100}')
 OPFAIL=$(sed -n 2,2p $i | gawk '{print $37}')

 #hlavbseq
 VB2ISA=$(sed -n 6,6p $i | gawk '{print $12*100" "$9*100}')
 VB2IISA=$(sed -n 7,7p $i | gawk '{print $12*100" "$9*100}')
 VB4ISA=$(sed -n 6,6p $i | gawk '{print $23*100" "$20*100}')
 VB4IISA=$(sed -n 7,7p $i | gawk '{print $23*100" "$20*100}')
 VB2ISAP=$(sed -n 9,9p $i | gawk '{print $12*100" "$9*100}')
 VB2IISAP=$(sed -n 10,10p $i | gawk '{print $12*100" "$9*100}')
 VB4ISAP=$(sed -n 9,9p $i | gawk '{print $23*100" "$20*100}')
 VB4IISAP=$(sed -n 10,10p $i | gawk '{print $23*100" "$20*100}')
 VBFAIL=$(sed -n 6,6p $i | gawk '{print $37}')

 #hlaminer asembly
 HS2ISA=$(sed -n 13,13p $i | gawk '{print $12*100" "$9*100}')
 HS2IISA=$(sed -n 14,14p $i | gawk '{print $12*100" "$9*100}')
 HS4ISA=$(sed -n 13,13p $i | gawk '{print $23*100" "$20*100}')
 HS4IISA=$(sed -n 14,14p $i | gawk '{print $23*100" "$20*100}')
 HS2ISAP=$(sed -n 19,19p $i | gawk '{print $12*100" "$9*100}')
 HS2IISAP=$(sed -n 20,20p $i | gawk '{print $12*100" "$9*100}')
 HS4ISAP=$(sed -n 19,19p $i | gawk '{print $23*100" "$20*100}')
 HS4IISAP=$(sed -n 20,20p $i | gawk '{print $23*100" "$20*100}')
 HSFAIL=$(sed -n 13,13p $i | gawk '{print $37}')

 # hlaminer alignment
 HL2ISA=$(sed -n 16,16p $i | gawk '{print $12*100" "$9*100}')
 HL2IISA=$(sed -n 17,17p $i | gawk '{print $12*100" "$9*100}')
 HL4ISA=$(sed -n 16,16p $i | gawk '{print $23*100" "$20*100}')
 HL4IISA=$(sed -n 17,17p $i | gawk '{print $23*100" "$20*100}')
 HL2ISAP=$(sed -n 22,22p $i | gawk '{print $12*100" "$9*100}')
 HL2IISAP=$(sed -n 23,23p $i | gawk '{print $12*100" "$9*100}')
 HL4ISAP=$(sed -n 22,22p $i | gawk '{print $23*100" "$20*100}')
 HL4IISAP=$(sed -n 23,23p $i | gawk '{print $23*100" "$20*100}')
 HLFAIL=$(sed -n 16,16p $i | gawk '{print $37}')

 # phlat
 PH2ISA=$(sed -n 25,25p $i | gawk '{print $12*100" "$9*100}')
 PH2IISA=$(sed -n 26,26p $i | gawk '{print $12*100" "$9*100}')
 PH4ISA=$(sed -n 25,25p $i | gawk '{print $23*100" "$20*100}')
 PH4IISA=$(sed -n 26,26p $i | gawk '{print $23*100" "$20*100}')
 PHFAIL=$(sed -n 25,25p $i | gawk '{print $37}')

 # seq2hla
 SE2ISA=$(sed -n 28,28p $i | gawk '{print $12*100" "$9*100}')
 SE2IISA=$(sed -n 29,29p $i | gawk '{print $12*100" "$9*100}')
 SE4ISA=$(sed -n 28,28p $i | gawk '{print $23*100" "$20*100}')
 SE4IISA=$(sed -n 29,29p $i | gawk '{print $23*100" "$20*100}')
 SEFAIL=$(sed -n 28,28p $i | gawk '{print $37}')


 echo "optitype $DATA 2 I $OP2ISA $OPFAIL" >> $ACCURACY
 echo "optitype $DATA 2 I+II $OP2IISA $OPFAIL" >> $ACCURACY
 echo "optitype $DATA 4 I $OP4ISA $OPFAIL" >> $ACCURACY
 echo "optitype $DATA 4 I+II $OP4IISA $OPFAIL" >> $ACCURACY

 echo "hlavbseq $DATA 2 I $VB2ISA $VBFAIL" >> $ACCURACY
 echo "hlavbseq $DATA 2 I+II $VB2IISA $VBFAIL" >> $ACCURACY
 echo "hlavbseq $DATA 4 I $VB4ISA $VBFAIL" >> $ACCURACY
 echo "hlavbseq $DATA 4 I+II $VB4IISA $VBFAIL" >> $ACCURACY

 echo "hlaminer_assembly $DATA 2 I $HS2ISA $HSFAIL" >> $ACCURACY
 echo "hlaminer_assembly $DATA 2 I+II $HS2IISA $HSFAIL" >> $ACCURACY
 echo "hlaminer_assembly $DATA 4 I $HS4ISA $HSFAIL" >> $ACCURACY
 echo "hlaminer_assembly $DATA 4 I+II $HS4IISA $HSFAIL" >> $ACCURACY

 echo "hlaminer_alignment $DATA 2 I $HL2ISA $HLFAIL" >> $ACCURACY
 echo "hlaminer_alignment $DATA 2 I+II $HL2IISA $HLFAIL" >> $ACCURACY
 echo "hlaminer_alignment $DATA 4 I $HL4ISA $HLFAIL" >> $ACCURACY
 echo "hlaminer_alignment $DATA 4 I+II $HL4IISA $HLFAIL" >> $ACCURACY

 echo "phlat $DATA 2 I $PH2ISA $PHFAIL" >> $ACCURACY
 echo "phlat $DATA 2 I+II $PH2IISA $PHFAIL" >> $ACCURACY
 echo "phlat $DATA 4 I $PH4ISA $PHFAIL" >> $ACCURACY
 echo "phlat $DATA 4 I+II $PH4IISA $PHFAIL" >> $ACCURACY

 echo "seq2hla $DATA 2 I $SE2ISA $SEFAIL" >> $ACCURACY
 echo "seq2hla $DATA 2 I+II $SE2IISA $SEFAIL" >> $ACCURACY
 echo "seq2hla $DATA 4 I $SE4ISA $SEFAIL" >> $ACCURACY
 echo "seq2hla $DATA 4 I+II $SE4IISA $SEFAIL" >> $ACCURACY

done

rm tmpWGS.txt tmpWES.txt tmpRNA.txt
