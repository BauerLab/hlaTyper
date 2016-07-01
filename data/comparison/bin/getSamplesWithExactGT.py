
# Get only the samples from the gold standard table that have a certain genotype
# (no alternatives separated by "/") for all HLA genes
# python bin/getSamplesWithExactGT.py > supportingData/1000GenomesCertainGT.txt
#

file="../goldstandard/goldstandard.csv"

WGS=set(open("iter/collectSamples1000GExtrChr6.txt").read().split("\n"))
WES=set(open("iter/collectSamples1000EExtrChr6.txt").read().split("\n"))
RNA=set(open("iter/collectSamples1000RExtrChr6.txt").read().split("\n"))

outWGS=open("supportingData/1000GenomesCertainGTG.txt", "w")
outWES=open("supportingData/1000GenomesCertainGTE.txt", "w")
outRNA=open("supportingData/1000GenomesCertainGTR.txt", "w")

for i in open(file):
    if i[0:2]=="id":
        continue
    arr=i.split(",")
    #print i
    prnt=True
    for j in range(2,14):
        if arr[j]=="":
            prnt=False
            continue
        if len(arr[j].split("/"))>1:
            prnt=False
            continue
    if prnt:
        #print i.strip("\n")
        s=arr[0].strip(" ")
        if s in WGS:
            outWGS.write(s+"\n")
        if s in WES:
            outWES.write(s+"\n")
        if s in RNA:
            outRNA.write(s+"\n")
