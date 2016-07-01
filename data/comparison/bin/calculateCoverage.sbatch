#!/bin/sh -e

#SBATCH --time=0:10:00
#SBATCH --mem=16gb
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=20
#SBATCH --job-name=coverage
#SBATCH --out out/1000RExtrCoverage/coverage_%A_%a.out
echo $SLURM_JOBID

. ./config.txt

# WGS
#RUN=1000GExtrChr6
#TYPE="_lc"

# WES
#RUN=1000EExtrChr6
#TYPE="_WES"
#sbatch -a 1-993 bin/calculateCoverage.sbatch

# RNA
RUN=1000RExtrChr6
#sbatch -a 1-373 bin/calculateCoverage.sbatch

OUT=fastq/$RUN/
ITER=iter/collectSamples$RUN.txt

#SLURM_ARRAY_TASK_ID=1

#RERUN because razers3 died
#grep FINISHED out/1000GExtrCoverage/* -L | cut -f 3 -d "_" | sed 's/.out//g' | gawk 'ORS="," {print $0}'
## sbatch -a 126,140,141,146,155,157,164,167,168,173,175,176,178,179,182,184,193,195,199,205,214,219,222,230,234,242,243,24,250,251,256,257,258,269,272,283,289,292,297,29,303,315,324,326,32,341,353,356,359,363,366,367,372,373,374,377,380,382,390,396,398,399,3,404,406,417,423,436,439,43,440,442,445,450,461,465,46,472,474,479,47,480,481,486,489,48,493,495,501,510,512,525,528,538,540,544,552,556,559,561,563,564,569,56,573,576,580,583,585,598,600,602,605,609,615,620,639,642,645,648,649,672,674,679,682,684,692,699,707,712,717,726,727,731,73,744,747,74,755,765,770,775,776,792,795,800,803,807,808,809,811,812,813,822,827,830,838,839,83,842,843,846,847,855,85,863,865,870,871,874,876,877,878,882,891,892,893,896,900,901,904,905,910,91,924,928,93,942,944,94,957,960,979,981,986,991,992,99 ./bin/calculateCoverage.sbatch
#grep FINISHED out/1000GExtrCoverage/coverage_60056* -L | cut -f 3 -d "_" | sed 's/.out//g' | gawk 'ORS="," {print $0}' #56
#sbatch -a 141,155,157,168,173,178,184,214,222,24,251,256,326,359,366,367,374,377,382,396,3,406,417,423,43,442,450,465,489,544,56,615,642,679,684,727,765,800,811,843,85,865,871,878,891,896,905,91,94,992,99 ./bin/calculateCoverage.sbatch
#check 60056_674, 60056_645, 60056_356
#grep FINISHED coverage_60283* -L | cut -f 3 -d "_" | sed 's/.out//g' | gawk 'ORS="," {print $0}
#173,359,374,396,417,442,465,679,871
# sbatch -a 109,114,121,144,228,291,343,546,549,645,669,708,858,874,875,979 ./bin/calculateCoverage.sbatch

id=$(head -n ${SLURM_ARRAY_TASK_ID} $ITER | tail -1)
SAMPLE=${id/*_/}
SAMPLE=${SAMPLE/.*/}
echo $SAMPLE
READ1=$OUT/${SAMPLE}$TYPE$ENDING
READ2=${READ1/$READ1NAME/$READ2NAME}


TMP=/flush1/bau04c/HLA/coverage/$RANDOM/
echo $TMP
mkdir -p $TMP

echo $SAMPLE $READ1 $READ2 $OUT/$SAMPLE.bam.stats
module unload perl
dmget $READ1 $READ2

module load use.own
module load razers3/3.5.0
module load samtools/1.2.1
module load bedtools/2.25.0

if [ ! -e supportingData/hlaLocs.fasta ]; then
  echo "generate HLA locus fasta"
  FASTA=/home/bau04c/SeqAna/reference/prod/b37/human_g1k_v37.fa
  bedtools getfasta -fi $FASTA -bed supportingData/hlaLocsChr6.bed -fo supportingData/hlaLocs.fasta
fi

echo "mapping"
razers3 -tc 20 -o $TMP/${SAMPLE}.bam supportingData/hlaLocs.fasta $READ1 $READ2

echo "coverage"
samtools sort -O bam -T $TMP $TMP/${SAMPLE}.bam | samtools depth - |  awk '{sum+=$3; sumsq+=$3*$3} END { print "Average = ",sum/NR; print "Stdev = ",sqrt(sumsq/NR - (sum/NR)**2)}' >$OUT/$SAMPLE.bam.stats

rm -r $TMP

echo FINISHED
