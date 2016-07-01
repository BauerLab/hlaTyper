import argparse,sys,re

#
# Tool to compare the results
# python bin/evaluatePredictions.py -i result/1000GExtr/results1000GExtr.optitype.txt -t optitype -g ../goldstandard/goldstandard.csv -l

globargs = 0
globsubset=[]
#samples that have high coverage data
#HC=["HG00096", "HG00268", "HG00419", "HG01051", "HG01112", "NA12878", "NA18939", "NA19625", "NA19648", "NA20502"]

# split multiple HLAstati and generate Low (two digits) and High (four digits)
# assume they are separated by "/"
def makeResolution(goldstandard):
    gsa=goldstandard.split("/")
    gsaHigh=[]
    gsaLow=[]
    for i in gsa:
        ar=i.split(":")
        gsaLow.append(ar[0])
        gsaHigh.append(":".join(ar[0:2]))
    return gsaHigh,gsaLow

# Evaluate Call
def evalCall(tool,goldstandard,tag):
    rightLow=wrongLow=rightHigh=wrongHigh=naTool=total=0
    for a in range(0,len(goldstandard)): # 1 2
        if goldstandard[a]=="":
            continue
        total+=1
        gsaHigh,gsaLow=makeResolution(goldstandard[a])
        high=False
        low=False
        if tool[a]=="":
            naTool+=1
            if globargs.verbose:
                print "NA %s gold: %s %s: %s" % (tag+"."+str(a+1), goldstandard[a], globargs.tool, tool[a])
            continue

        LR=HR=False
        # Low resolution
        for t in tool[a].split("/"):
            ar=t.split(":")
            if ar[0] in gsaLow and not LR:
                if globargs.verbose:
                    print "R2 %s gold: %s %s: %s" % (tag+"."+str(a+1), goldstandard[a], globargs.tool, tool[a])
                rightLow+=1
                LR=True
            if ":".join(ar[0:2]) in gsaHigh and not HR:
                if globargs.verbose:
                    print "R4 %s gold: %s %s: %s" % (tag+"."+str(a+1), goldstandard[a], globargs.tool, tool[a])
                rightHigh+=1
                HR=True

        if not LR:
            if globargs.verbose:
                print "W2 %s gold: %s %s: %s" % (tag+"."+str(a+1), goldstandard[a], globargs.tool, tool[a])
            wrongLow+=1
        if not HR:
            if globargs.verbose:
                print "W4 %s gold: %s %s: %s" % (tag+"."+str(a+1), goldstandard[a], globargs.tool, tool[a])
            wrongHigh+=1

    return rightLow,wrongLow,rightHigh,wrongHigh,naTool,total

def addValues(rightLow,wrongLow,rightHigh,wrongHigh,naTool,total, rightLowO,wrongLowO,rightHighO,wrongHighO,naToolO,totalO):
    rightLow+=rightLowO
    wrongLow+=wrongLowO
    rightHigh+=rightHighO
    wrongHigh+=wrongHighO
    naTool+=naToolO
    total+=totalO
    return rightLow,wrongLow,rightHigh,wrongHigh,naTool,total



def eval(hlaTool,hlaGold):
    rightLow=wrongLow=rightHigh=wrongHigh=naTool=total=0
    for i in hlaGold.keys():
        SampleID=i
        rightLowS=wrongLowS=rightHighS=wrongHighS=naToolS=totalS=0
        for j in hlaGold[SampleID]: # A B C ...
            tag=SampleID+"."+j
            if (hlaTool.has_key(SampleID) and hlaTool[SampleID].has_key(j)):
                rightLowO,wrongLowO,rightHighO,wrongHighO,naToolO,totalO=evalCall(hlaTool[SampleID][j],hlaGold[SampleID][j],tag)
                rightLowS,wrongLowS,rightHighS,wrongHighS,naToolS,totalS=addValues(rightLowS,wrongLowS,rightHighS,wrongHighS,naToolS,totalS, rightLowO,wrongLowO,rightHighO,wrongHighO,naToolO,totalO)
                rightLow,wrongLow,rightHigh,wrongHigh,naTool,total=addValues(rightLow,wrongLow,rightHigh,wrongHigh,naTool,total, rightLowO,wrongLowO,rightHighO,wrongHighO,naToolO,totalO)
            else:
                for a in range(0,len(hlaGold[SampleID][j])): # 1 2
                    if hlaGold[SampleID][j][a]!="":
                         total+=1
                         naTool+=1
                         naToolS+=1
                         totalS+=1
        if globargs.verbose:
            print "SUM %s rightLow %i wrongLow %i success = %2.2f accuracy = %2.2f | rightHigh %i wrongHigh %i success = %2.2f accracy = %2.2f | na %i total %i" % (SampleID,rightLowS,wrongLowS,float(rightLowS)/(rightLowS+wrongLowS+1.e-17),float(rightLowS)/(totalS+1.e-17),rightHighS,wrongHighS,float(rightHighS)/(rightHighS+wrongHighS+1.e-17),float(rightHighS)/(totalS+1.e-17), naToolS, totalS)
    if len(hlaTool.keys())==0:
        sys.exit("no predictions made")
    hlaclass="I+II"
    if (globargs.limit):
        hlaclass="I"
    print "Class %4s rightLow %i wrongLow %i success = %2.2f accuracy = %2.2f | rightHigh %i wrongHigh %i success = %2.2f accuracy = %2.2f | na %i total %i NA %2.2f | samples %i predictions %i failed %i" % (hlaclass,rightLow,wrongLow,float(rightLow)/(rightLow+wrongLow+1.e-17),float(rightLow)/(total+1.e-17),rightHigh,wrongHigh,float(rightHigh)/(rightHigh+wrongHigh+1.e-17),float(rightHigh)/(total+1.e-17),naTool,total,naTool/float(total+1.e-17), len(hlaGold.keys()), len(hlaTool.keys()), len(hlaGold.keys())-len(hlaTool.keys()))
    #print "rightLow %i wrongLow %i = %2.2fPc | rightHigh %i wrongHigh %i = %2.2fPc | na %i total %i = %2.2fPc | samples %i predictions %i failed %i" % (rightLow,wrongLow,float(rightLow)/(rightLow+wrongLow),rightHigh,wrongHigh,float(rightHigh)/(rightHigh+wrongHigh),naTool,total,naTool/float(total), len(hlaGold.keys()), len(hlaTool.keys()), len(hlaGold.keys())-len(hlaTool.keys()))
    assert (rightLow+wrongLow+naTool == total),"Sanity check failed: low(right+wrong+na) %i != total %i" % (rightLow+wrongLow+naTool,total)
    assert (rightHigh+wrongHigh+naTool == total),"Sanity check failed: high(right+wrong+na) %i != total %i" % (rightHigh+wrongHigh+naTool,total)


def makeUnique(seq):
   # Not order preserving
   s = set(seq)
   return list(s)

# if the goldstandard has two entries for the sample either concatinate
# them as we do not know which ones are correct so assume uncertainty
# or remove them because we don't allow uncertainty
def concatAlleles(hash1, hash2):
    newhlaHash={}
    if (not(globargs.uncertainGS)):
        #print "don't allow uncertainty"
        return newhlaHash # don't allow uncertainty
    for i in hash1.keys():
        newAllele1="/".join(makeUnique([hash1[i][0],hash2[i][0]]))
        newAllele2="/".join(makeUnique([hash1[i][1],hash2[i][1]]))
        newhlaHash[i]=sorted([newAllele1,newAllele2])
    #print "1: %s\n2: %s\nc: %s\n\n" % (hash1, hash2, newhlaHash)
    return newhlaHash

# Extract information from gold standard file
def extractInfoGS(file):

    hlaAllSamples={}
    for i in file:
        i=i.strip("\n")
        i=i.strip(" ")
        hlaHash={}
        if (i=="") or (i[1:3]=="id") or (i=="\n"):
            continue
        sample=i.split(",")[0]
        if (globargs.subset and not(sample in globsubset)):
            continue
        if globargs.noExpression:
            i=re.sub("[A-Z]","",i)
        line=i.split(",")
        hlaHash["A"]=sorted([line[2],line[3]])
        hlaHash["B"]=sorted([line[4],line[5]])
        hlaHash["C"]=sorted([line[6],line[7]])
        if (not globargs.limit):
            hlaHash["DRB1"]=sorted([line[8],line[9]])
            hlaHash["DQB1"]=sorted([line[10],line[11]])
            hlaHash["DQA1"]=sorted([line[10],line[11]])
        if hlaAllSamples.has_key(sample):
            hlaAllSamples[sample]=concatAlleles(hlaAllSamples[sample],hlaHash)
        else:
            hlaAllSamples[sample]=hlaHash
    return hlaAllSamples

# extract information from
def extractInfoOptitype(file):
    hlaAllSamples={}
    for i in file:
        i=i.strip("\n")
        hlaHash={}
        if (i==""):
            continue
        sample=i.split(" ")[0]
        if (globargs.subset and not(sample in globsubset)):
            continue
        if globargs.noExpression:
            i=re.sub("[A-Z]","",i)
        line=i.split(" ")
        hlaHash["A"]=sorted([line[1],line[2]])
        hlaHash["B"]=sorted([line[3],line[4]])
        hlaHash["C"]=sorted([line[5],line[6]])
        hlaAllSamples[sample]=hlaHash
    return hlaAllSamples

def extractInfoAll(file, twoAlleles, classI):
    hlaAllSamples={}
    for i in file:
        i=i.strip("\n")
        sample=i.split(" ")[0]
        if globargs.noExpression:
            i=re.sub("[A-Z]","",i)
        hlaHash={}
        line=re.split("[ |]",i)
        if (globargs.subset and not(sample in globsubset)):
            continue
        if (i=="" or len(line)==1):
            continue
        counter=1
        liste=["A", "B", "C", "DRB1", "DQB1", "DQA1"]
        if (globargs.limit or classI):
            liste=["A", "B", "C"]
        for l in liste:
            if (twoAlleles):
                if ( globargs.verify ):
                    print "%s %s %s %s    %s" % (sample, l, line[counter],line[counter+1],line)
                hlaHash[l]=sorted([line[counter],line[counter+1]])
                counter+=2
            else:
                if ( globargs.verify ):
                    print "%s %s %s %s    %s" % (sample, l, line[counter],line[counter],line)
                hlaHash[l]=sorted([line[counter],line[counter]])
                counter+=1
        hlaAllSamples[sample]=hlaHash
    return hlaAllSamples

def extractInfo(file, typeV):
    hla=""
    if typeV == "gold": hla = extractInfoGS(file)
    #if typeV == "optitype": hla = extractInfoOptitype(file)
    if typeV == "optitype": hla = extractInfoAll(file, True, True)
    if typeV == "hlavbseq": hla = extractInfoAll(file, False, False)
    if typeV == "hlaminer": hla = extractInfoAll(file, True, False)
    if typeV == "phlat": hla = extractInfoAll(file, True, False)
    if typeV == "seq2hla": hla = extractInfoAll(file, True, False)
    return hla

def main(args):
    # Parse the user supplied arguments
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', dest='resultfile', help='The input result file')
    parser.add_argument('-t', dest='tool', help='the tool name')
    parser.add_argument('-g', dest='goldstandard', help='Goldstandard table')
    parser.add_argument('-l', dest='limit', action='store_true', help='limit to only class I')
    parser.add_argument('-v', dest='verbose', action='store_true', help='print out detailed comparison')
    parser.add_argument('-r', dest='verify', action='store_true',help='print out subset to eyeball')
    parser.add_argument('-n', dest='noExpression', action='store_true', help='remove letter (expression)')
    parser.add_argument('-u', dest='uncertainGS', action='store_false', help='do not allow uncertainty in the GS, i.e. remove samples with more than one allele')
    parser.add_argument('-s', dest='subset', help='limit to samples provided in the file')


    args = parser.parse_args()
    global globargs
    globargs=args

    # Open the specified files
    ts = open(args.resultfile, 'r')
    gs = open(args.goldstandard, 'r')

    # load subset sample IDs in case this is necessary
    global globsubset
    if (globargs.subset):
        globsubset = open(globargs.subset, 'r').read().strip().split("\n")


    hlaTool=extractInfo(ts,args.tool)
    hlaGold=extractInfo(gs,"gold")

    eval(hlaTool,hlaGold)

    # Close files
    ts.close()
    gs.close()

if __name__ == '__main__':
    main(sys.argv)
