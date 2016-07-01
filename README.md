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

# Other Analysis
Scripts for the other analyses performed for the paper (e.g. coverage stats, or correlations) can be found in [bin](https://github.com/BauerLab/hlaTyper/blob/master/data/comparison/bin/)

# Citing
Bauer DC, Zadoorian A, Wilson L, Kahlke T, Melbourne Genomics Health Alliance, and Thorne NP, “Evaluation of computational programs to predict HLA genotypes from genomic sequencing data” *in peparation*
