ste <- function(x) sd(x)/sqrt(length(x))

##########################
# HLA typing resource consumption
##########################

#r1000GExtrChr6 <- read.table(stringsAsFactors=F, "/Volumes/RubyHome/Documents/datahome/HLAtyper/data/comparison/resources1000RExtrChr6.txt", header=TRUE, quote="\"")
r1000GExtrChr6 <- read.table(stringsAsFactors=F, "/Volumes/RubyHome/Documents/datahome/HLAtyper/data/comparison/resources2.txt", header=TRUE, quote="\"")

#r1000GExtrChr6[which(r1000GExtrChr6[3]=="mem"),]$Value=r1000GExtrChr6[which(r1000GExtrChr6[3]=="mem"),]$Value/1e+6

#r1000GExtrChr6$me="runtime (in s)"
#r1000GExtrChr6[which(r1000GExtrChr6[3]=="mem"),]$me="memory (in GB)"
#r1000GExtrChr6[which(r1000GExtrChr6[3]=="mem"),]$Value=r1000GExtrChr6[which(r1000GExtrChr6[3]=="mem"),]$Value/1e+6

library("dplyr")
library("ggplot2")
#memory
r1000GExtrChr6M=r1000GExtrChr6[c(which(r1000GExtrChr6[3]=="mem")),]
r1000GExtrChr6M$Value=r1000GExtrChr6M$Value/1e+6

grouped <- group_by(r1000GExtrChr6M, Tool, Data)
Resource=summarise(grouped, mean=mean(Value), ste=ste(Value), max=max(Value))
Resource
limits <- aes(ymax = mean + ste, ymin=mean - ste)
dodge <- position_dodge(width=0.9)
#pdf("/Volumes/RubyHome/Documents/datahome/HLAtyper/data/comparison/images/resources1000GExtrChr6.txt", width=5, height=4)
pdf("/Users/bau04c/Documents/datahome/hlatyper/doc/BiB/images/resources1000GExtrChr6Mem.pdf", width=6, height=4)
ggplot(Resource, aes(y=mean, x=Tool, fill=factor(Tool))) +
  geom_bar(position="dodge", stat="identity") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) + coord_trans(y="sqrt") +
  geom_bar(position=dodge) + geom_errorbar(limits, position=dodge, width=0.25) +
  ylab("mean memory in GB (sqrt)") + xlab("Tool") +
  facet_grid(. ~ Data)
dev.off()
grouped <- group_by(r1000GExtrChr6M, Tool)
summarise(grouped, mean=mean(Value), ste=ste(Value), max=max(Value))

# Time
r1000GExtrChr6T=r1000GExtrChr6[-c(which(r1000GExtrChr6[3]=="mem")),]
grouped <- group_by(r1000GExtrChr6T, Tool, Type, Data)
ResourceT=summarise(grouped, mean=mean(Value), ste=ste(Value))
pdf("/Users/bau04c/Documents/datahome/hlatyper/doc/BiB/images/resources1000GExtrChr6Time.pdf", width=6, height=4)
ggplot(ResourceT, aes(fill=Type, y=mean, x=Tool)) +
  geom_bar(position="stack", stat="identity") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) + coord_trans(y="sqrt") +
  ylab("mean runtime in s (sqrt)") + xlab("Tool") +
  facet_grid(. ~ Data)
dev.off()
grouped <- group_by(r1000GExtrChr6T, Tool, Sample, Data)
ResourceT=summarise(grouped, Time=sum(Value))
grouped <- group_by(ResourceT, Tool, Data)
Resource=summarise(grouped, mean=mean(Time), ste=ste(Time), max=max(Time))
Resource
grouped <- group_by(ResourceT, Tool)
summarise(grouped, mean=mean(Time), ste=ste(Time), max=max(Time))


##########################
# HLA accuracy
##########################

a1000Acc <- read.table(stringsAsFactors=F, "/Volumes/RubyHome/Documents/datahome/HLAtyper/data/comparison/accuracy.txt", header=TRUE, quote="\"")
a1000Acc3=a1000Acc[-which(a1000Acc$Class=="I"),]

library(reshape2)
a1000Acc2<-melt(a1000Acc, id.vars = c(1,2,3,4), measure.vars = c(5,6))
a1000Acc4<-melt(a1000Acc3, id.vars = c(1,2,3,4), measure.vars = c(5,6))

pdf("/Users/bau04c/Documents/datahome/hlatyper/doc/BiB/images/AccuracyPlot.pdf", width=6, height=4)
ggplot(a1000Acc4, aes(x=Tool, y=value, fill=factor(variable))) +
  geom_bar(position="dodge", stat="identity") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) + 
  facet_grid(Resolution ~ Data)
dev.off()

ggplot(a1000Acc2, aes(x=Tool, y=value, fill=factor(variable))) +
  geom_bar(position="dodge", stat="identity") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) + 
  facet_grid(Class+Resolution ~ Data)

ggplot(a1000Acc, aes(x=Tool, y=Accuracy, fill=factor(Tool))) +
  geom_bar(position="dodge", stat="identity") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) + 
  facet_grid(Resolution ~ Data)

#############################
# Accuracy certain genotypes (37)
#############################

a1000Acc <- read.table(stringsAsFactors=F, "/Volumes/RubyHome/Documents/datahome/HLAtyper/data/comparison/accuracy_certainGT.txt", header=TRUE, quote="\"")
a1000Acc3=a1000Acc[-which(a1000Acc$Class=="I"),]

library(reshape2)
a1000Acc2<-melt(a1000Acc, id.vars = c(1,2,3,4), measure.vars = c(5,6))
a1000Acc4<-melt(a1000Acc3, id.vars = c(1,2,3,4), measure.vars = c(5,6))

pdf("/Users/bau04c/Documents/datahome/hlatyper/doc/BiB/images/AccuracyPlot_CertainGT.pdf", width=6, height=4)
ggplot(a1000Acc4, aes(x=Tool, y=value, fill=factor(variable))) +
  geom_bar(position="dodge", stat="identity") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) + 
  facet_grid(Resolution ~ Data)
dev.off()

