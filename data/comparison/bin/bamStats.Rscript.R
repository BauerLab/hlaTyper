ste <- function(x) sd(x)/sqrt(length(x))

##########################
# HLA typing bam read number statistics
##########################

library("dplyr")
library("ggplot2")

BamCoverage <- read.table("/Volumes/RubyHome/Documents/datahome/HLAtyper/data/comparison/result/BamCoverage.stats", header=TRUE, quote="\"")

ggplot(BamCoverage, aes(type, paired)) + geom_boxplot() + geom_jitter() + coord_trans(y = "log10")

pdf("/Users/bau04c/Documents/datahome/hlatyper/doc/BiB/images/bamCoverage.pdf", width=5, height=4)
ggplot(BamCoverage, aes(type, paired)) + geom_violin() + coord_trans(y = "log10")
dev.off()

grouped <- group_by(BamCoverage, type)
Resource=summarise(grouped, mean=mean(reads), ste=ste(reads))

grouped <- BamCoverage %>%
  filter(!is.na(reads)) %>%
  group_by(type) 

summarise(grouped, mean=mean(reads), ste=ste(reads))

##########################
# HLA bam coverage statistics
##########################


BamAvCoverage <- read.table("/Volumes/RubyHome/Documents/datahome/HLAtyper/data/comparison/result/BamAvCoverage.stats", header=TRUE, quote="\"")
BamAvCoverage$type=gsub("1000RExtrChr6", "RNA", BamAvCoverage$type)
BamAvCoverage$type=gsub("1000EExtrChr6", "WES", BamAvCoverage$type)
BamAvCoverage$type=gsub("1000GExtrChr6", "WGS", BamAvCoverage$type)
pdf("/Users/bau04c/Documents/datahome/hlatyper/doc/BiB/images/CoverageAv.pdf", width=6, height=6)
ggplot(BamAvCoverage, aes(type, avCov)) + geom_boxplot() + geom_jitter() 
dev.off()

grouped <- group_by(BamAvCoverage, type)
Resource=summarise(grouped, mean=mean(avCov), ste=ste(avCov), max=max(avCov))
Resource

##########################
# HLA bam coverage and accuracy correlation
##########################
library("Hmisc")
library("corrgram")
library(reshape2)
#BamAvCoverageNAcc <- read.table("/Volumes/RubyHome/Documents/datahome/HLAtyper/data/comparison/result/BamAvCoverageNacc.txt", header=TRUE, quote="\"")
BamAvCoverageNAcc <- read.table("/Volumes/RubyHome/Documents/datahome/HLAtyper/data/comparison/result/BamAvCoverageacc.txt", header=TRUE, quote="\"")
WGS=BamAvCoverageNAcc[which(BamAvCoverageNAcc$type=="1000GExtrChr6"),]
WES=BamAvCoverageNAcc[which(BamAvCoverageNAcc$type=="1000EExtrChr6"),]
RNA=BamAvCoverageNAcc[which(BamAvCoverageNAcc$type=="1000RExtrChr6"),]

#rcorr(as.matrix(RNA[,-c(1,2,4)]),type="pearson")
# add noise for plotting otherwise standard dev is 0 and the plot has NA in it
#RNA$optitype.2[1]=0.500001
WGS.x<-melt(cor(WGS[,-c(1,2,4)]))
WES.x<-melt(cor(WES[,-c(1,2,4)]))
RNA.x<-melt(cor(RNA[,-c(1,2,4)]))
WGS.x$type="WGS"
WES.x$type="WES"
RNA.x$type="RNA"
allcor=rbind(WGS.x,WES.x,RNA.x)
summary(allcor)

grouped <- group_by(allcor, type)
Resource=summarise(grouped, mean=mean(value), ste=ste(value), max=max(value))

pdf("/Users/bau04c/Documents/datahome/hlatyper/doc/BiB/images/CoverageAccuracyCorr.pdf", width=6, height=7)
ggplot(allcor, aes(Var1, Var2, fill = value)) + geom_tile() + 
  scale_fill_gradient(low = "blue",  high = "yellow") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  facet_grid(type+digits ~ variable) +
  ylab("Tools") + xlab("Tools") +
  facet_grid(type ~ .)
dev.off()

################
# only for the 37 samples with certain genotype
################

CertainGTG <- read.table("/Volumes/RubyHome/Documents/datahome/HLAtyper/data/comparison/supportingData/1000GenomesCertainGTG.txt", quote="\"")
WGS=WGS[WGS$sample %in% CertainGTG$V1,]
CertainGTE <- read.table("/Volumes/RubyHome/Documents/datahome/HLAtyper/data/comparison/supportingData/1000GenomesCertainGTE.txt", quote="\"")
WES=WES[WES$sample %in% CertainGTE$V1,]
CertainRNA <- read.table("/Volumes/RubyHome/Documents/datahome/HLAtyper/data/comparison/supportingData/1000GenomesCertainGTR.txt", quote="\"")
RNA=RNA[RNA$sample %in% CertainRNA$V1,]

# add noise for plotting otherwise standard dev is 0 and the plot has NA in it
RNA$optitype.2[1]=0.500001
WES$optitype.2[1]=0.500001
WGS.x<-melt(cor(WGS[,-c(1,2,4)]))
WES.x<-melt(cor(WES[,-c(1,2,4)]))
RNA.x<-melt(cor(RNA[,-c(1,2,4)]))
WGS.x$type="WGS"
WES.x$type="WES"
RNA.x$type="RNA"
allcor=rbind(WGS.x,WES.x,RNA.x)

grouped <- group_by(allcor, type)
Resource=summarise(grouped, mean=mean(value), ste=ste(value), max=max(value))

pdf("/Users/bau04c/Documents/datahome/hlatyper/doc/BiB/images/CoverageAccuracyCorr_CertainGT.pdf", width=6, height=7)
ggplot(allcor, aes(Var1, Var2, fill = value)) + geom_tile() + 
  scale_fill_gradient(low = "blue",  high = "yellow") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  facet_grid(type+digits ~ variable) +
  ylab("Tools") + xlab("Tools") +
  facet_grid(type ~ .)
dev.off()


##################
# Regression coverage to accuracy
##################

#corrgram(BamAvCoverageNAcc[,-c(1,2,4)], order=FALSE, lower.panel=panel.shade,
#         upper.panel=NULL, text.panel=panel.txt,
#         main="Correlation coverage and accuracy")

meltBamAvCoverageNAcc<-melt(BamAvCoverageNAcc[,-c(4)], id.vars = c(1,2,3), measure.vars = c(4,6,8,10,12,14))
meltBamAvCoverageNAcc$digits="2-digits"
meltBamAvCoverageNAcc2<-melt(BamAvCoverageNAcc[,-c(4)], id.vars = c(1,2,3), measure.vars = c(5,7,9,11,13,15))
meltBamAvCoverageNAcc2$digits="4-digits"
meltBamAvCoverageNAcc2anno=rbind(meltBamAvCoverageNAcc, meltBamAvCoverageNAcc2)
#meltBamAvCoverageNAcc2anno=rbind(meltBamAvCoverageNAcc2)
meltBamAvCoverageNAcc2anno$variable=gsub(".2", "", meltBamAvCoverageNAcc2anno$variable)
meltBamAvCoverageNAcc2anno$variable=gsub(".4", "", meltBamAvCoverageNAcc2anno$variable)
meltBamAvCoverageNAcc2anno$type=gsub("1000RExtrChr6", "RNA", meltBamAvCoverageNAcc2anno$type)
meltBamAvCoverageNAcc2anno$type=gsub("1000EExtrChr6", "WES", meltBamAvCoverageNAcc2anno$type)
meltBamAvCoverageNAcc2anno$type=gsub("1000GExtrChr6", "WGS", meltBamAvCoverageNAcc2anno$type)

pdf("/Users/bau04c/Documents/datahome/hlatyper/doc/BiB/images/CoverageAccuracy.pdf", width=8, height=8)
ggplot(meltBamAvCoverageNAcc2anno, aes(x=value, y=coverage)) +
  geom_point(shape=1) +    # Use hollow circles
  geom_smooth(method=lm) +
  facet_grid(type+digits ~ variable, scales="free_y") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  ylab("average coverage") + xlab("accuracy")
dev.off()


######################
# Venn - runs only on ruby as Vennerable cannot be installed on MaxOS
#####################
  
library(Vennerable)
pdf("../../doc/BiB/images/VennOverlap.pdf", width=10, height=10)
names=c("Gourraud et al. 2014", "Erlich et al. 2011","de Bakker et al. 2006")
Vdemo2 <- Venn(SetNames=names, Weight=c('100'=1017,'000'=33,'010'=12,'001'=0,'110'=36,'101'=7,'011'=15,'111'=205))
plot(Vdemo2, doWeights = TRUE)
dev.off()
pdf("../../doc/BiB/images/VennAgreement.pdf", width=10, height=10)
names=c("Gourraud et al. 2014", "Erlich et al. 2011","de Bakker et al. 2006")
Vdemo2 <- Venn(SetNames=names, Weight=c('100'=16,'000'=3,'010'=31,'001'=2,'110'=10,'101'=26,'011'=8,'111'=0))
plot(Vdemo2, doWeights = TRUE)
dev.off()


pdf("../../doc/BiB/images/VennType.pdf", width=10, height=10)
Vdemo2 <- Venn(SetNames=c("DNA", "RNA"), Weight=c('10'=1261,'01'=16,'11'=48))
plot(Vdemo2, doWeights = TRUE)               
dev.off()

############
# Samples seen
###############

pdf("/Users/bau04c/Documents/datahome/hlatyper/doc/BiB/images/SamplesSeen.pdf", width=5, height=4)
names=c("Goldstandard","Tested WGS", "Tested WES", "Tested RNA","HLAreporter","HLA-VBSeq", "OptiType", "PHLAT", "Omixon Software", "HLAforest", "ATHLATES", "Seq2HLA", "HLAminer", "HLAssign" )
SamplesSeen=data.frame(names=names, 
                       values=c(1325,993,992,373,61,3,216,90,148,67,13,49,36,0))
SamplesSeen$names<-factor(SamplesSeen$names,levels=names)
ggplot(SamplesSeen, aes(y=values, x=names)) +
  geom_bar(position="dodge", stat="identity", fill="#56B4E9") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +  scale_y_sqrt() +
  ylab("samples (sqrt)") + xlab("category")
dev.off()









names=c("Gourraud et al. 2014", "Bai et al. 2014", "Liu et al. 2013", "Warren et al. 2012","Erlich et al. 2011","de Bakker et al. 2006")
Vdemo2 <- Venn(SetNames=names, Weight=c('100000'=1034, 
                                        '010000'=5,
                                        '001000'=10,
                                        '000100'=16,
                                        '000010'=31,
                                        '000001'=1,
                                        '100010'=32,
                                        '100001'=29,
                                        '000011'=34,
                                        '001010'=1,
                                        '100011'=170,
                                        '101011'=2))
plot(Vdemo2, type = "battle", show = list(SetLabels = FALSE, FaceText = ""))
plot(Vdemo2, type = "squares", show = list(FaceText = "weight",SetLabels = FALSE))

pdf("Venn.pdf", width=10, height=10)
names=c("Gourraud et al. 2014", "Liu et al. 2013", "Erlich et al. 2011","de Bakker et al. 2006")
Vdemo2 <- Venn(SetNames=names, Weight=c('1000'=1034, '0100'=10,'0010'=31,'0001'=1,'1010'=32,'1001'=29,'0011'=34,'0110'=1,'1011'=170,'1111'=2,'0000'=0,'1100'=0,'1110'=0,'0101'=0,'1101'=0,'0111'=0))
plot(Vdemo2, type = "ChowRuskey", show = list(SetLabels = TRUE), doEuler=TRUE, doWeights = FALSE)
plot(Vdemo2, type = "ellipses", show = list(SetLabels = TRUE), doEuler=TRUE, doWeights = FALSE)
dev.off()





dev.off()
