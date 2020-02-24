####DFOLD_v3######################
#####Full length folding##########
#####Adding exception process#####
from multiprocessing import Process
import time,os,sys
import argparse
import subprocess
from string import Template
import glob,re

# thresholds for splitting distances
#thre=[11,12,13,14,15]

# Filtering residue pairs < sep
sep = 3

DFOLD_src=os.path.dirname(os.path.abspath(__file__))
DFOLD_tools = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))+"/DFOLD_db_tools/tools"
src_dict=dict(
    #### DFOLD scripts ####
    DFOLD       =os.path.join(DFOLD_src,"DFOLD_iter_dev_v3.pl"),
)

tool_dict=dict(
    #### DFOLD tools path ####
    SBROD       =os.path.join(DFOLD_tools,"SBROD/sbrod"),
)

#### Default DFOLD templates####
# $selectrr  - Number of distances to use from the input distance file;
# $hhbond       - hbond.tbl
# $ssnoe      - ssnoe.tbl
# $fasta   - input fasta file
# $ss   - psipred
# $dist   - predicted distance
# $outdir   - output folder
DFOLD_mul_hb_template=Template("perl "+src_dict["DFOLD"]+" -hhbond $hhbond -ssnoe $ssnoe -rrtype cb -stage2 1 -mcount 50 -seq $fasta -ss $ss -rr $dist -o $outdir")

#### DFOLD templates with hhbonds for mul-class prediction and select top 5L distances as input####
DFOLD_mulhb_sort_template=Template("perl "+src_dict["DFOLD"]+" -selectrr $selectrr -hhbond $hhbond -ssnoe $ssnoe -rrtype cb -stage2 1 -mcount 50 -seq $fasta -ss $ss -rr $dist -o $outdir")

#### SBROD templates ####
SBROD_template=Template(tool_dict["SBROD"]+" $outdir/*.pdb > $outdir/SBROD_prediction.$target")

def SBROD(thre,srcdir,outdir,target):
    for num in thre:
        source = srcdir+"/2.5_"+str(num)+"/stage3/"+target+"_model1.pdb"
        dest = outdir+"/"+target+"_"+str(num)+"A.pdb"
        if not os.path.exists(source):
            print("Warning: Model folding for threshold "+str(num)+"A.... failed")
        else:
            os.system("cp "+source+" "+dest)

    if not os.path.exists(tool_dict["SBROD"]):
        print("Cannot find "+tool_dict["SBROD"]+".....Please check the path")
        sys.exit()
    else:
        sbrod_cmd = SBROD_template.substitute(
        outdir   =outdir,
        target   =target,
    )
    #print(sbrod_cmd)
    os.system(sbrod_cmd)
    result = outdir+"/SBROD_prediction."+target
    if os.path.getsize(result) > 0:
        return result
    else:
        return False

def sel_model(target,outdir,SBROD_file,model_dir):
    os.chdir(outdir)
    os.system("sort -r -k 2 "+SBROD_file+" > "+SBROD_file+".sorted")
    i = 1
    for line in open(SBROD_file+".sorted","r"):
        line = line.rstrip()
        arr = line.split()
        arr_sub1 = arr[0].split('/')
        pdb = arr_sub1[-1]
        os.system("cp "+outdir+"/"+pdb+" "+model_dir+"/"+target+"_model"+str(i)+".pdb")
        i = i+1

def dfold_test(hhbonds,ssnoe,fasta,ss,dist,outdir):
    print(hhbonds,ssnoe,fasta,ss,dist,outdir)
    print("child pid %s,parent pid %s"%(os.getpid(),os.getppid()))

def dfold(target,hhbonds,ssnoe,fasta,ss,dist,outdir):
    dfold_cmd = DFOLD_mul_hb_template.substitute(
    fasta   =fasta,
    ss   =ss,
    hhbond = hhbond,
    ssnoe = ssnoe,
    dist   =dist,
    outdir   =outdir,
    )
    #print(dfold_cmd)
    if not os.path.exists(outdir+"/stage3/"+target+"_model1.pdb"):
        stdout,stderr=subprocess.Popen(dfold_cmd,
        shell=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE).communicate()
        if stderr :
            # There was an error - command exited with non-zero code
            print("DFOLD models for "+outdir+" failed on all constraints.....Select top 5L to fold....")
            dfold_cmd = DFOLD_mulhb_sort_template.substitute(
            fasta   =fasta,
            selectrr ="5L",
            ss   =ss,
            hhbond = hhbond,
            ssnoe = ssnoe,
            dist   =dist,
            outdir   =outdir,
        )
            stdout,stderr=subprocess.Popen(dfold_cmd,
            shell=True,stdout=subprocess.PIPE).communicate()
        logfile = open(outdir+".log","w")
        for line in stdout:
            logfile.write(line)
        logfile.close()
    else:
        print("DFOLD models for "+outdir+" exist.....Skip....")

def is_dir(dirname):
    """Checks if a path is an actual directory"""
    if not os.path.isdir(dirname):
        msg = "{0} is not a directory".format(dirname)
        raise argparse.ArgumentTypeError(msg)
    else:
        return dirname

def is_file(filename):
    """Checks if a file is an invalid file"""
    if not os.path.exists(filename):
        msg = "{0} doesn't exist".format(filename)
        raise argparse.ArgumentTypeError(msg)
    else:
        return filename

def set_threshold(thre_type):
    """Define threshold type"""
    thre = []
    if thre_type == "b":
        thre=[11,13,15,17,19]
    elif thre_type == "c":
        thre=[15,16,17,18,19]
    elif thre_type == "a":
        thre=[11,12,13,14,15]
    else:
        msg = "{0} is not a valid type".format(thre_type)
        raise argparse.ArgumentTypeError(msg)
    return thre

def psipred2ss(tar, psipred, ss):
    f = open(ss,"w")
    f.write(">"+tar+"\n")
    for line in open(psipred,"r"):
        line = line.strip()
        if line.startswith("#"):
            continue
        if not line.strip():
            continue
        arr = line.split()
        if arr[0].isdigit():
            f.write(arr[2])
    f.write("\n")

def mkdir_if_not_exist(tmpdir):
    ''' create folder if not exists '''
    if not os.path.isdir(tmpdir):
        os.makedirs(tmpdir)

def filter_distance(target,fasta,dist,lower,upper,sep,outdir):
    f = open(outdir+"/"+target+".dist.rr","w")
    for line in open(fasta,"r"):
            line = line.rstrip()
            if line.startswith('>'):
                continue
            else:
                seq = line
                f.write(seq+"\n")
                break
    for line in open(dist,"r"):
        if line and line[0].isalpha():
            continue
        line = line.rstrip()
        arr = line.split()
        i = int(arr[0])
        j = int(arr[1])
        dist = float(arr[3])
        if abs(i-j) < sep or (dist >= upper) or (dist < lower):
            continue
        else:
            f.write(line+"\n")
    f.close()

def split_distance(target,dist,fasta,thre,outdir):
    for num in thre:
        mkdir_if_not_exist(outdir+"/2.5_"+str(num))
        filter_distance(target,fasta,dist,2.5,num,sep,outdir+"/2.5_"+str(num))

if __name__=="__main__":
    #### command line argument parsing ####
    parser = argparse.ArgumentParser()
    parser.description="DFOLD - Full-length ab inito folding"
    parser.add_argument("-f", "--fasta", help="input fasta file",type=is_file,required=True)
    parser.add_argument("-d", "--distance", help="predicted distance",type=is_file,required=True)
    parser.add_argument("-b", "--hhbonds", default="",help="hhbond.tbl",type=str)
    parser.add_argument("-n", "--ssnoe", default="",help="ssnoe.tbl",type=str)
    parser.add_argument("-ss", "--ss",default="", help="predicted secondary structure",type=str)
    parser.add_argument("-p", "--psipred",default="", help="psipred",type=str)
    parser.add_argument("-th", "--thresholds", default="a",help="list of thresholds(A), a:[11,12,13,14,15], b:[11,13,15,17,19], c:[15,16,17,18,19]",type=set_threshold)
    parser.add_argument("-out", "--outdir", help="output folder",type=str,required=True)

    args = parser.parse_args()
    fasta = args.fasta
    dist = args.distance
    hhbond = args.hhbonds
    ssnoe = args.ssnoe
    ss = args.ss
    psipred = args.psipred
    outdir = args.outdir
    thre = args.thresholds

    mkdir_if_not_exist(outdir)

    #### Input fasta file's id
    target = os.path.basename(fasta)
    target=os.path.splitext(target)[0]

    ###############################################################################
    #### Step 1: Check if secondary structure exist################################
    if ss == "":
        if not os.path.exists(psipred):
            print("Secondary structure is required.....")
            sys.exit()
        else:
            ss = outdir+"/"+target+".ss"
            psipred2ss(target,psipred,ss)

    ###############################################################################
    #### Step 2: Preparing distances with 5 thresholds(11A, 12A, 13A, 14A and 15A)
    mkdir_if_not_exist(outdir+"/"+"data")
    split_distance(target,dist,fasta,thre,outdir+"/"+"data")

    ###############################################################################
    #### Step 3: Start folding for 5 thresholds seperately#########################
    procs = []
    for num in thre:
        mkdir_if_not_exist(outdir+"/"+"dfold/2.5_"+str(num))
        print("Start folding for threshold "+str(num)+"A....")
        proc = Process(target=dfold, args=(target,hhbond,ssnoe,fasta,ss,outdir+"/data/2.5_"+str(num)+"/"+target+".dist.rr",outdir+"/dfold/2.5_"+str(num),))
        procs.append(proc)
        proc.start()

    # complete the processes
    for proc in procs:
        proc.join()

    print("Finish folding for 5 thresholds....")

    ###############################################################################
    #### Step 4: Select 5 top 1 models from 5 thresholds###########################
    ####         Use SBROD for ranking#############################################
    print("Start ranking models by SBROD.....")
    mkdir_if_not_exist(outdir+"/sbrod")
    result = SBROD(thre,outdir+"/"+"dfold",outdir+"/sbrod",target)
    if(result):
        sel_model(target,outdir+"/sbrod",result,outdir)
        print("Save top 5 models in "+outdir)
        print("Done")
    else:
        print("Rank models by SBROD failed.....")
        sys.exit()