# hlaTyper
Technical comparison of computational HLA prediction tools from NGS data.

# Folder content
* data
  * comparison - contains the scripts to run and evaluate tools
  * goldstandard - contains the curated information of use genotypes per sample

# Comparison
Runs are triggered with
[submitAll WGS](https://github.com/BauerLab/hlaTyper/blob/master/data/comparison/submitAll_Extract.sh),
[submitAll WES](https://github.com/BauerLab/hlaTyper/blob/master/data/comparison/submitAll_Extract.sh)
[submitAll RNAseq](https://github.com/BauerLab/hlaTyper/blob/master/data/comparison/submitAll_Extract.sh),
respectively, extracting bam-files for the HLA region in each sample and submitting the wrapper script for the 5 tools. These scripts are named Run_<toolname>.sbatch and can be found in the [bin-folder](https://github.com/BauerLab/hlaTyper/blob/master/data/comparison/bin/).

Results are then [collected](https://github.com/BauerLab/hlaTyper/blob/master/data/comparison/bin/collectResults.sh) over all samples for each tool and [evaluated](https://github.com/BauerLab/hlaTyper/blob/master/data/comparison/bin/eval.sh) to obtain the final success and accuracy values.

The log file output for ClassI+II prediction of the evaluation script [evaluatePredictions.py](https://github.com/BauerLab/hlaTyper/blob/master/data/comparison/bin/evaluatePredictions.py) (as triggered by eval.sh) can be found in the [RepositoryLogFiles-folder](https://github.com/BauerLab/hlaTyper/blob/master/data/comparison/RepositoryLogFiles/).

File structure is results1000`<Dataset>`ExtrChr6`<Tool>(<Variables>)`.evalCII.txt, e.g. results1000EExtrChr6.hlamineralnTop.evalCII.txt

Dataset
- E - Whole Exome Seq
- G - Whole Genome Seq
- R - RNA seq

Tools
- hlamineraln - HLAminer alignment
- hlaminersbly - HLAminer assembly
- hlavbseq
- optiytype
- phlat
- seq2hla

Variables
- Top - single results for hlaminer
- Top2 - single results for hlavbseq (per Chromosome)
- Top3 - top 3 results for hlaminer
- Top5 - top 5 results for hlavbseq

File content looks like so:
```
W2 NA19676.A.1 gold: 01:01:01:01/01:01:01:02/01:04/01:22/01:32/01:34/01:37 hlaminer: 31:01
W4 NA19676.A.1 gold: 01:01:01:01/01:01:01:02/01:04/01:22/01:32/01:34/01:37 hlaminer: 31:01
...
R4 NA19676.DRB1.2 gold: 12:01:01/12:06/12:10/12:17 hlaminer: 12:01
SUM NA19676 rightLow 6 wrongLow 6 success = 0.50 accuracy = 0.50 | rightHigh 3 wrongHigh 9 success = 0.25 accracy = 0.25 | na 0 total 12
...
Class I+II rightLow 6690 wrongLow 4953 success = 0.57 accuracy = 0.56 | rightHigh 3128 wrongHigh 8515 success = 0.27 accuracy = 0.26 | na 226 total 11869 NA 0.02 | samples 992 predictions 992 failed 0

```
For each individual the file contains for each HLA loci one row with
- evaluation R(ight)2(-digit)R4,W(rong)2,W4
- sample name and HLA loci
- gold standard entry for this loci (can be blank)
- tool name
- prediction from tool (can be blank)

Followed by a `SUM` line summarizing performance of this tool for this individual with
- number of right 2-digits
- number of wrong 2-digits
- success 2-digits
- accuracy 2-digits
- number of right 4-digits
- number of wrong 4-digits
- success 4-digits
- accuracy 4-digits
- number of NA from tool
- total number of known alleles
- percentage


The file is concluded with a final summary `Class I+II`
- number of right 2-digits
- number of wrong 2-digits
- success 2-digits
- accuracy 2-digits
- number of right 4-digits
- number of wrong 4-digits
- success 4-digits
- accuracy 4-digits
- number of NA from tool
- total number of known alleles
- percentage
- number of samples
- number of predictions
- number of failed runs






# Other Analysis
Scripts for the other analyses performed for the paper (e.g. coverage stats, or correlations) can be found in [bin](https://github.com/BauerLab/hlaTyper/blob/master/data/comparison/bin/)

# Citing
Bauer DC, Zadoorian A, Wilson LOW, Melbourne Genomics Health Alliance, and Thorne NP, “Evaluation of computational programs to predict HLA genotypes from genomic sequencing data” *in peparation*
