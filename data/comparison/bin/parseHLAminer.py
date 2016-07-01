import argparse,re,sys

# Usage python bin/parseHLAminer.py -i result/1000GExtrChr6/hlaminer/HG00101_lc_sbly_HLAminer_HPTASR.csv -s HG00101 -t 1


def parse(ts):
    nr=-1
    hashHLA={}
    for l in ts:
        if l=="" or l=="\n":
            nr=-1
        if l.find("Prediction")>-1:
            nr=int(l.split("#")[1].split(" ")[0])-1
        else:
            if nr==-1:
                continue
            else:
                l=l.strip("\t")
                arr=re.split("[*,]",l)
                if hashHLA.has_key(arr[0]):
                    hashHLA[arr[0]][nr].append((arr[1],float(arr[2])))
                else:
                    tmparr=[[],[]]
                    tmparr[nr].append((arr[1],float(arr[2])))
                    hashHLA[arr[0]]=tmparr
    return hashHLA


def output(hashHLA):
    outputString=[globargs.sample.strip()]
    for i in ["A","B","C","DRB1","DQB1","DQA1"]:
        if hashHLA.has_key(i):
            for j in [0,1]:
                arr=[]
                sort=sorted(hashHLA[i][j],key=lambda tup: tup[1])
                for z in range(0,int(globargs.top)):
                    if len(sort)>z:
                        arr.append(sort[z][0].strip())
                outputString.append("/".join(arr))
        else:
            outputString+=["",""]
    print " ".join(outputString)

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
        ts = open(args.file, 'r')
    except Exception, e:
        print >> sys.stderr, "does not exist"
        print >> sys.stderr, "Exception: %s" % str(e)
        sys.exit(1)

    hashHLA=parse(ts)
    output(hashHLA)

    # Close files
    ts.close()

if __name__ == '__main__':
    main(sys.argv)
