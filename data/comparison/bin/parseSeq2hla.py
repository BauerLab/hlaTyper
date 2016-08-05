import argparse,re,sys

# Extract information from the *.ambiguity and .HLAgenotype4digits file
# to put together a sinlge string of likely genotypes for this sample
#
# Usage python bin/parseSeq2hla.py -i result/1000RExtrChr6/seq2hla/HG00231 -s HG00231 -t 3

# parse ambiguity file
def parseAmbig(ambig):
    hashHLA={}
    fileA=ambig.read().split("\n")
    collect=[]
    c=-1
    while c < len(fileA)-1:
        c+=1
        i=fileA[c]
        if i=="" or i[0]=="#":
            continue
        arr=i.split("\t")
        if len(arr)<2:
            hla=arr[0].split("*")[0]
            collect=sorted(collect, key=lambda tup: tup[1], reverse=True)
            #top=min(int(globargs.top),len(collect))
            if hashHLA.has_key(hla):
                #hashHLA[hla].append(collect[0:top])
                hashHLA[hla].append(collect)
            else:
                #hashHLA[hla]=[collect[0:top]]
                hashHLA[hla]=[collect]
            collect=[]
            continue
        if arr[1]=="NA":
            confidence=0
        else:
            confidence=float(arr[1])
        collect.append((arr[0].split("*")[1].strip("'"),confidence))
    for i in hashHLA:
        #a1="/".join([a[0] for a in hashHLA[i][0]])
        a1=[a[0] for a in hashHLA[i][0]]
        a2=0
        if len(hashHLA[i])>1:
            #a2="/".join([a[0] for a in hashHLA[i][1]])
            a2=[a[0] for a in hashHLA[i][1]]
        hashHLA[i]=[a1,a2]
    return hashHLA

# parse HLAgenotype4digits file
def parseNormal(normal, hashambig):
    hashHLA={}
#    print hashambig
    for i in normal:
        if i[0]=="#":
            continue
        arr=i.split("\t")
        locus=arr[1].split("*")[0]
        abig=0

        if arr[1]=="no":
            hashHLA[locus]=[[],0]
        else:
            hashHLA[locus]=[[arr[1].split("*")[1].strip("'")],0]
            if arr[1].find("'")>-1:
                #hashHLA[locus]=[hashambig[locus][abig],0]
                c=0
                while len(hashHLA[locus][0])<int(globargs.top) and len(hashambig[locus][abig])>c :
    #                print "%s %i %s %s" % (locus,c,str(hashHLA[locus][0]), str(hashambig[locus][abig]))
                    if not(hashambig[locus][abig][c] in hashHLA[locus][0]):
                        hashHLA[locus][0].append(hashambig[locus][abig][c])
                    c+=1
                abig+=1
        if arr[3]=="no":
            hashHLA[locus][1]=[]
        else:
            hashHLA[locus][1]=[arr[3].split("*")[1].strip("'")]
            if arr[3].find("'")>-1:
    #            for i in range(0,min(int(globargs.top)-1,len(hashambig[locus][abig]))):
    #                hashHLA[locus][1].append(hashambig[locus][abig][i])
                c=0
                while (len(hashHLA[locus][1])<int(globargs.top) and len(hashambig[locus][abig])>c) :
                    if not(hashambig[locus][abig][c] in hashHLA[locus][1]):
                        hashHLA[locus][1].append(hashambig[locus][abig][c])
                    c+=1

    return hashHLA

# print out line
def output(hashHLA):
    outputString=[]
    for i in ["A","B","C","DRB1","DQB1","DQA1"]:
        if hashHLA.has_key(i):
            outputString+=["/".join(hashHLA[i][0]),"/".join(hashHLA[i][1])]
#            outputString+=[hashHLA[i][0],hashHLA[i][1]]
        else:
            outputString+=["",""]
    print globargs.sample.strip()+" "+"|".join(outputString)

def main(args):
    # Parse the user supplied arguments
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', dest='file', help='The input result file')
    parser.add_argument('-s', dest='sample', help='sample name')
    parser.add_argument('-t', dest='top', help='how many choices')

    args = parser.parse_args()
    global globargs
    globargs=args

    # Open the specified files
    try:
        ambig = open(args.file+".ambiguity", 'r')
        normal = open(args.file+".HLAgenotype4digits", 'r')
    except Exception, e:
        print >> sys.stderr, "does not exist"
        print >> sys.stderr, "Exception: %s" % str(e)
        sys.exit(1)

    ambigHash=parseAmbig(ambig)
    hashHLA=parseNormal(normal,ambigHash)
    output(hashHLA)

    # Close files
    ambig.close()
    normal.close()

if __name__ == '__main__':
    main(sys.argv)
