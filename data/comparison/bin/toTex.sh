###########
# WGS
###########
echo "WGS"
PATHL=result/1000GExtrChr6/results1000GExtrChr6
ADD="iter/collectSamples1000GExtrChr6.txt"
./bin/eval.sh $PATHL $ADD > tmpWGS.txt
###########
# WES
###########
echo "WES"
PATHL=result/1000EExtrChr6/results1000EExtrChr6
ADD="iter/collectSamples1000EExtrChr6.txt" # limit to samples from exon dataset
./bin/eval.sh $PATHL $ADD > tmpWES.txt
###########
# RNA
###########
echo "RNA"
PATHL=result/1000RExtrChr6/results1000RExtrChr6
ADD="iter/runRNA.txt" # limit to samples from RNA dataset
./bin/eval.sh $PATHL $ADD > tmpRNA.txt

FULL="1"

echo "Data"
for i in tmpWGS.txt tmpWES.txt tmpRNA.txt; do
	TYPE=${i/.txt/}
	TYPE=${TYPE/tmp/}
  echo "######################################"
  echo "#" $i
  echo "######################################"
  #optitype
  OP2ISA=$(sed -n 2,2p $i | gawk '{print $12*100"\\% ("$9*100"\\%)"}')
  OP2IISA=$(sed -n 3,3p $i | gawk '{print $12*100"\\% ("$9*100"\\%)"}')
  OP4ISA=$(sed -n 2,2p $i | gawk '{print $23*100"\\% ("$20*100"\\%)"}')
  OP4IISA=$(sed -n 3,3p $i | gawk '{print $23*100"\\% ("$20*100"\\%)"}')
  OPFAIL=$(sed -n 2,2p $i | gawk '{print $37}')

  #hlavbseq
  VB2ISA=$(sed -n 6,6p $i | gawk '{print $12*100"\\% ("$9*100"\\%)"}')
  VB2IISA=$(sed -n 7,7p $i | gawk '{print $12*100"\\% ("$9*100"\\%)"}')
  VB4ISA=$(sed -n 6,6p $i | gawk '{print $23*100"\\% ("$20*100"\\%)"}')
  VB4IISA=$(sed -n 7,7p $i | gawk '{print $23*100"\\% ("$20*100"\\%)"}')
  VB2ISAP=$(sed -n 9,9p $i | gawk '{print $12*100"\\% ("$9*100"\\%)"}')
  VB2IISAP=$(sed -n 10,10p $i | gawk '{print $12*100"\\% ("$9*100"\\%)"}')
  VB4ISAP=$(sed -n 9,9p $i | gawk '{print $23*100"\\% ("$20*100"\\%)"}')
  VB4IISAP=$(sed -n 10,10p $i | gawk '{print $23*100"\\% ("$20*100"\\%)"}')
  VBFAIL=$(sed -n 6,6p $i | gawk '{print $37}')

  #hlaminer asembly
  HS2ISA=$(sed -n 13,13p $i | gawk '{print $12*100"\\% ("$9*100"\\%)"}')
  HS2IISA=$(sed -n 14,14p $i | gawk '{print $12*100"\\% ("$9*100"\\%)"}')
  HS4ISA=$(sed -n 13,13p $i | gawk '{print $23*100"\\% ("$20*100"\\%)"}')
  HS4IISA=$(sed -n 14,14p $i | gawk '{print $23*100"\\% ("$20*100"\\%)"}')
  HS2ISAP=$(sed -n 19,19p $i | gawk '{print $12*100"\\% ("$9*100"\\%)"}')
  HS2IISAP=$(sed -n 20,20p $i | gawk '{print $12*100"\\% ("$9*100"\\%)"}')
  HS4ISAP=$(sed -n 19,19p $i | gawk '{print $23*100"\\% ("$20*100"\\%)"}')
  HS4IISAP=$(sed -n 20,20p $i | gawk '{print $23*100"\\% ("$20*100"\\%)"}')
   HSFAIL=$(sed -n 13,13p $i | gawk '{print $37}')

  # hlaminer alignment
  HL2ISA=$(sed -n 16,16p $i | gawk '{print $12*100"\\% ("$9*100"\\%)"}')
  HL2IISA=$(sed -n 17,17p $i | gawk '{print $12*100"\\% ("$9*100"\\%)"}')
  HL4ISA=$(sed -n 16,16p $i | gawk '{print $23*100"\\% ("$20*100"\\%)"}')
  HL4IISA=$(sed -n 17,17p $i | gawk '{print $23*100"\\% ("$20*100"\\%)"}')
  HL2ISAP=$(sed -n 22,22p $i | gawk '{print $12*100"\\% ("$9*100"\\%)"}')
  HL2IISAP=$(sed -n 23,23p $i | gawk '{print $12*100"\\% ("$9*100"\\%)"}')
  HL4ISAP=$(sed -n 22,22p $i | gawk '{print $23*100"\\% ("$20*100"\\%)"}')
  HL4IISAP=$(sed -n 23,23p $i | gawk '{print $23*100"\\% ("$20*100"\\%)"}')
  HLFAIL=$(sed -n 16,16p $i | gawk '{print $37}')

  # phlat
  PH2ISA=$(sed -n 25,25p $i | gawk '{print $12*100"\\% ("$9*100"\\%)"}')
  PH2IISA=$(sed -n 26,26p $i | gawk '{print $12*100"\\% ("$9*100"\\%)"}')
  PH4ISA=$(sed -n 25,25p $i | gawk '{print $23*100"\\% ("$20*100"\\%)"}')
  PH4IISA=$(sed -n 26,26p $i | gawk '{print $23*100"\\% ("$20*100"\\%)"}')
  PHFAIL=$(sed -n 25,25p $i | gawk '{print $37}')

  # seq2hla
  SE2ISA=$(sed -n 29,29p $i | gawk '{print $12*100"\\% ("$9*100"\\%)"}')
  SE2IISA=$(sed -n 30,30p $i | gawk '{print $12*100"\\% ("$9*100"\\%)"}')
  SE4ISA=$(sed -n 29,29p $i | gawk '{print $23*100"\\% ("$20*100"\\%)"}')
  SE4IISA=$(sed -n 30,30p $i | gawk '{print $23*100"\\% ("$20*100"\\%)"}')
	SE2ISAP=$(sed -n 32,32p $i | gawk '{print $12*100"\\% ("$9*100"\\%)"}')
  SE2IISAP=$(sed -n 33,33p $i | gawk '{print $12*100"\\% ("$9*100"\\%)"}')
  SE4ISAP=$(sed -n 32,32p $i | gawk '{print $23*100"\\% ("$20*100"\\%)"}')
  SE4IISAP=$(sed -n 33,33p $i | gawk '{print $23*100"\\% ("$20*100"\\%)"}')
  SEFAIL=$(sed -n 29,29p $i | gawk '{print $37}')

	if [ -n "$FULL" ]; then
  echo "optitype & 2 & I & $OP2ISA & &  $OPFAIL \\\\"
  echo "optitype & 2 & I+II & $OP2IISA & &  $OPFAIL \\\\"
  echo "optitype & 4 & I & $OP4ISA & &  $OPFAIL \\\\"
  echo "optitype & 4 & I+II & $OP4IISA & &  $OPFAIL \\\\"

  echo "hlavbseq & 2 & I & $VB2ISA & $VB2ISAP &  $VBFAIL \\\\"
  echo "hlavbseq & 2 & I+II & $VB2IISA & $VB2IISAP &  $VBFAIL \\\\"
  echo "hlavbseq & 4 & I & $VB4ISA & $VB4ISAP &  $VBFAIL \\\\"
  echo "hlavbseq & 4 & I+II & $VB4IISA & $VB4IISAP &  $VBFAIL \\\\"

  echo "hlaminer assembly & 2 & I & $HS2ISA & $HS2ISAP &  $HSFAIL \\\\"
  echo "hlaminer assembly & 2 & I+II & $HS2IISA & $HS2IISAP &  $HSFAIL \\\\"
  echo "hlaminer assembly & 4 & I & $HS4ISA & $HS4ISAP &  $HSFAIL \\\\"
  echo "hlaminer assembly & 4 & I+II & $HS4IISA & $HS4IISAP &  $HSFAIL \\\\"

  echo "hlaminer alignment & 2 & I & $HL2ISA & $HL2ISAP &  $HLFAIL \\\\"
  echo "hlaminer alignment & 2 & I+II & $HL2IISA & $HL2IISAP &  $HLFAIL \\\\"
  echo "hlaminer alignment & 4 & I & $HL4ISA & $HL4ISAP &  $HLFAIL \\\\"
  echo "hlaminer alignment & 4 & I+II & $HL4IISA & $HL4IISAP &  $HLFAIL \\\\"

  echo "phlat & 2 & I & $PH2ISA & &  $PHFAIL \\\\"
  echo "phlat & 2 & I+II & $PH2IISA & &  $PHFAIL \\\\"
  echo "phlat & 4 & I & $PH4ISA & &  $PHFAIL \\\\"
  echo "phlat & 4 & I+II & $PH4IISA & &  $PHFAIL \\\\"

  echo "seq2hla & 2 & I & $SE2ISA & $SE2ISAP &  $SEFAIL \\\\"
  echo "seq2hla & 2 & I+II & $SE2IISA & $SE2IISAP &  $SEFAIL \\\\"
  echo "seq2hla & 4 & I & $SE4ISA & $SE4ISAP &  $SEFAIL \\\\"
  echo "seq2hla & 4 & I+II & $SE4IISA & $SE4IISAP &  $SEFAIL \\\\"

  echo "-------------------------------- short---------"

  echo "optitype & 2 & $OP2IISA & &  $OPFAIL \\\\"
  echo " & 4 & $OP4IISA & &   \\\\"

  echo "hlavbseq & 2  & $VB2IISA & $VB2IISAP &  $VBFAIL \\\\"
  echo " & 4  & $VB4IISA & $VB4IISAP &   \\\\"

  echo "hlaminer assembly & 2  & $HS2IISA & $HS2IISAP &  $HSFAIL \\\\"
  echo " & 4  & $HS4IISA & $HS4IISAP &   \\\\"

  echo "hlaminer alignment & 2  & $HL2IISA & $HL2IISAP &  $HLFAIL \\\\"
  echo "& 4  & $HL4IISA & $HL4IISAP &   \\\\"

  echo "phlat & 2  & $PH2IISA & &  $PHFAIL \\\\"
  echo " & 4  & $PH4IISA & &   \\\\"

  echo "seq2hla & 2  & $SE2IISA & $SE2IISAP &  $SEFAIL \\\\"
  echo " & 4  & $SE4IISA & $SE4IISAP &   \\\\"

  fi

  echo "-------------------micro "
   echo "$TYPE & optitype & $OP4IISA & &  $OPFAIL \\\\"

  echo " & hlavbseq & $VB4IISA & $VB4IISAP &  $VBFAIL \\\\"

  echo " & hlaminer assembly & $HS4IISA & $HS4IISAP &  $HSFAIL \\\\"

  echo "& hlaminer alignment & $HL4IISA & $HL4IISAP &  $HLFAIL \\\\"

  echo " & phlat  & $PH4IISA & &  $PHFAIL \\\\"

  echo " & seq2hla &  $SE4IISA &  $SE4IISAP &  $SEFAIL \\\\"


done

rm tmpWGS.txt tmpWES.txt tmpRNA.txt
