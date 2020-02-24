######################run_DFOLD.py######################
######Combination of full length and domain folding#####
#####Adding exception process#####
from multiprocessing import Process
import time,os,sys
import argparse
import subprocess
from string import Template
import glob,re

# thresholds for splitting distances
#fl_thre = "a"
#dm_thre = "a"

# num of final models
num = 5

# Modeller path
modeller = "/storage/htc/bdm/tools/multicom_db_tools/tools/modeller-9.16/bin/mod9.16"

# DM_ASSEMBLY scripts
DM_src = "/storage/htc/bdm/tools/multicom_db_tools/tools/Domain_assembly/scripts/domain_assembly.pl"

DFOLD_src=os.path.dirname(os.path.abspath(__file__))
DFOLD_tools = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))+"/DFOLD_db_tools/tools"
src_dict=dict(
    #### DFOLD scripts ####
    DFOLD       =os.path.join(DFOLD_src,"DFOLD_v3.py"),
)

tool_dict=dict(
    #### DFOLD tools path ####
    SBROD       =os.path.join(DFOLD_tools,"SBROD/sbrod"),
    DM_ASSEMBLY = DM_src,
)

#### Default DFOLD with multiple threshold and predicted hhbonds templates####
# $fasta   - input fasta file
# $dist   - predicted distance
# $hhbond       - hbond.tbl
# $ssnoe      - ssnoe.tbl
# $ss   - psipred
# $thre - thresholds for splitting distances, a:[11,12,13,14,15], b:[11,13,15,17,19], c:[15,16,17,18,19]
# $outdir   - output folder
DFOLD_template=Template("python "+src_dict["DFOLD"]+" -f $fasta -d $dist -b $hhbond -n $ssnoe -ss $ss -th $thre -out $outdir")

#### SBROD templates ####
SBROD_template=Template(tool_dict["SBROD"]+" $outdir/*.pdb > $outdir/SBROD_prediction.$target")

#### Domain assembly templates ####
# $lst   - domain list
# $modeldir    - domain model folder
# $fasta      - query fasta file
# $target     - query sequence id
# $outdir     - output dir 
# $modeller   - modeller path
# $num    - model number
DM_ASSEMBLY_template=Template(tool_dict["DM_ASSEMBLY"]+" $lst $modeldir $fasta $target $outdir $modeller $n")

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

def mkdir_if_not_exist(tmpdir):
    ''' create folder if not exists '''
    if not os.path.isdir(tmpdir):
        os.makedirs(tmpdir)

def get_length(fasta):
    seq = ""
    for line in open(fasta,"r"):
        line = line.rstrip()
        if (line.startswith(">")) or (line in ['\n', '\r\n']):
            continue
        else:
            seq += line 
    return seq,len(seq)

def get_dm(seq,l,domain):
    dm_dict = dict()
    for line in open(domain,"r"):
        line = line.rstrip()
        str1 = line.split()
        str2 = str1[1].split(":")
        dm = int(str2[0])+1
        dm_range = str2[1]
        str3  = dm_range.split('-')
        start = int(str3[0])
        end = int(str3[1])
        dm_l = end-start +1
        if (dm_l < l) and (dm_l > 0):
            dm_seq = seq[start-1:end]
            dm_dict[target+"-D"+str(dm)] = dm_seq
        elif dm_l == l:
            print("No predicted domain....")
        else:
            print("Domain prediction failed, please check "+domain)
            sys.exit()
    return dm_dict

def dfold(fasta,dist,hhbond,ssnoe,ss,thre,outdir):
    dfold_cmd = DFOLD_template.substitute(
        fasta   =fasta,
        ss   =ss,
        hhbond = hhbond,
        ssnoe = ssnoe,
        dist   =dist,
        thre   =thre,
        outdir   =outdir,
    )
    #print(dfold_cmd)
    stdout,stderr=subprocess.Popen(dfold_cmd,
            shell=True,stdout=subprocess.PIPE).communicate()

def parameter_setting(outdir,target):
    fasta = os.path.join(outdir,target+".fasta")
    dist = os.path.join(outdir,target+".dist.rr")
    hhbonds = os.path.join(outdir,target+".hbond.tbl")
    ssnoe = os.path.join(outdir,target+".ssnoe.tbl")
    ss = os.path.join(outdir,target+".ss")
    return fasta,dist,hhbonds,ssnoe,ss

def domain_assembly(num,target,fasta,modeller,dm_dict,outdir):
    if len(dm_dict) == 0:
        print("Skip domain assembly....")
    else:
        print("Start domain assembly.....")
        for i in range(1,1+num):
            model_dir = outdir+"/modeller/model"+str(i)
            mkdir_if_not_exist(model_dir+"/input")
            if os.path.exists(model_dir+"/"+target+".pdb"):
                    print("DM assembly model for "+model_dir+" exists....Skip...")
                    continue
            for key in dm_dict:
                dm_model = os.path.join(outdir,key,key+"_model"+str(i)+".pdb")
                if os.path.exists(dm_model):
                    os.system("cp "+dm_model+" "+model_dir+"/input")
                else:
                    print(dm_model+" failed folding...")
            os.chdir(model_dir+"/input")
            os.system("ls "+target+"*.pdb > "+target+".lst")
            if os.path.getsize(target+".lst") == 0:
                print("DM assembly for "+model_dir+" failed....")
            else:
                domain_assembly_cmd(model_dir,fasta,target,modeller)
                if os.path.exists(model_dir+"/"+target+".pdb"):
                    print("DM assembly for "+model_dir+" completed....")
                    os.system("cp "+model_dir+"/"+target+".pdb"+" "+outdir+"/modeller/"+target+"_model"+str(i)+".pdb")
                else:
                    print("DM assembly for "+model_dir+" failed....")

def domain_assembly_cmd(model_dir,fasta,target,modeller):
    DM_ASSEMBLY_cmd = DM_ASSEMBLY_template.substitute(
        lst   =model_dir+"/input/"+target+".lst",
        modeldir   =model_dir+"/input",
        fasta = fasta,
        target = target,
        outdir   =model_dir,
        modeller   =modeller,
        n   =5,
    )
    #print(DM_ASSEMBLY_cmd)
    stdout,stderr=subprocess.Popen(DM_ASSEMBLY_cmd,
            shell=True,stdout=subprocess.PIPE).communicate()

def SBROD(num,outdir):
    for i in range(1,1+num):
        mkdir_if_not_exist(outdir+"/sbrod/model"+str(i))
        fl_model = fl_dir+"/"+target+"_model"+str(i)+".pdb"
        dm_model = dm_dir+"/modeller/"+target+"_model"+str(i)+".pdb"
        dest_fl_model = os.path.join(outdir+"/sbrod","model"+str(i),target+"_model"+str(i)+"_fl.pdb")
        dest_dm_model = os.path.join(outdir+"/sbrod","model"+str(i),target+"_model"+str(i)+"_dm.pdb")
        if not os.path.exists(fl_model):
            print("FL Model folding for model "+str(i)+".... failed")
            os.system("cp "+fl_model+" "+outdir+"/sbrod")
        elif not os.path.exists(dm_model):
            print("DM Model folding for model "+str(i)+".... failed")
            os.system("cp "+dm_model+" "+outdir+"/sbrod")
        else:
            os.system("cp "+fl_model+" "+dest_fl_model)
            os.system("cp "+dm_model+" "+dest_dm_model)
            if not os.path.exists(tool_dict["SBROD"]):
                print("Cannot find "+tool_dict["SBROD"]+".....Please check the path")
                sys.exit()
            else:
                sbrod_cmd = SBROD_template.substitute(
                outdir   =outdir+"/sbrod/model"+str(i),
                target   =target,
            )
            #print(sbrod_cmd)
            os.system(sbrod_cmd)
            result = outdir+"/sbrod/model"+str(i)+"/SBROD_prediction."+target
            if os.path.getsize(result) > 0:
                pdb = sel_model(target,outdir+"/sbrod/model"+str(i),result)
                os.system("cp "+pdb+" "+outdir+"/"+target+"_model"+str(i)+".pdb")
            else:
                print("SBROD failed for rank "+outdir+"/sbrod"+"/model"+str(i))

def sel_model(target,outdir,SBROD_file):
    os.chdir(outdir)
    os.system("sort -r -k 2 "+SBROD_file+" > "+SBROD_file+".sorted")
    i = 1
    for line in open(SBROD_file+".sorted","r"):
        line = line.rstrip()
        arr = line.split()
        arr_sub1 = arr[0].split('/')
        pdb = arr_sub1[-1]
        pdb = outdir+"/"+pdb
        break
    return pdb

if __name__=="__main__":
    #### command line argument parsing ####
    parser = argparse.ArgumentParser()
    parser.description="DFOLD - Ab inito folding with domain info"
    parser.add_argument("-f", "--fasta", help="input fasta file",type=is_file,required=True)
    parser.add_argument("-dm", "--domain", help="e.g. domain 0:1-124 easy",type=is_file,required=True)
    parser.add_argument("-in", "--input",help="input folder contains distance and hhbonds constraints and model construction will be stored under this_folder",type=is_dir,required=True)
    parser.add_argument("-ft", "--flthre", default="a",help="list of thresholds(A), a:[11,12,13,14,15], b:[11,13,15,17,19], c:[15,16,17,18,19]",type=str)
    parser.add_argument("-dt", "--dmthre", default="a",help="list of thresholds(A), a:[11,12,13,14,15], b:[11,13,15,17,19], c:[15,16,17,18,19]",type=str)

    args = parser.parse_args()
    fasta = args.fasta
    domain = args.domain
    outdir = args.input
    fl_thre = args.flthre
    dm_thre = args.dmthre

    #### Input fasta file's id
    fasta = os.path.abspath(fasta)
    outdir = os.path.abspath(outdir)
    target = os.path.basename(fasta)
    target=os.path.splitext(target)[0]
    seq,l = get_length(fasta) 

    ###############################################################################
    #################### Step 1: Start full-length folding ########################
    procs = []
    print("Start FL folding ....")
    fl_dir = os.path.join(outdir,"fl")
    fasta, dist,hhbonds,ssnoe,ss = parameter_setting(fl_dir,target)
    proc = Process(target=dfold, args=(fasta,dist,hhbonds,ssnoe,ss,fl_thre,fl_dir,))
    procs.append(proc)
    proc.start()

    ###############################################################################
    ############## Step 2: Check if domain exists and start domain folding ########
    dm_dir = os.path.join(outdir,"dm")
    dm_dict = get_dm(seq,l,domain)
    if len(dm_dict) == 0:
        print("Skip domain folding....")
    else:
        for key in dm_dict:
            dm_fasta = dm_dir+"/"+key+".fasta"
            if not os.path.exists(dm_dir+"/"+key+".fasta"):
                print("Domain fasta "+dm_fasta+" dosesn't match with "+domain)
                continue
            else:   
                dm_fasta = os.path.abspath(dm_dir+"/"+key+".fasta")
                dm_seq,dm_l = get_length(dm_fasta)
                if dm_seq != dm_dict[key]:
                    print("Domain fasta "+dm_fasta+" dosesn't match with "+domain)
                else:
                    print("Start folding for "+key+"....")
                    dm_fasta, dm_dist,dm_hhbonds,dm_ssnoe,dm_ss = parameter_setting(dm_dir,key)
                    proc = Process(target=dfold, args=(dm_fasta,dm_dist,dm_hhbonds,dm_ssnoe,dm_ss,dm_thre,dm_dir+"/"+key,))
                    procs.append(proc)
                    proc.start()

    ###############################################################################
    # Step 3: Wait for folding from domain and fl finishing and do domain assembly#
    # complete the processes
    for proc in procs:
        proc.join()

    print("Folding for FL and DM completed....")
    if len(dm_dict) == 0:
        print("Skip domain folding....")
        os.system("cp "+fl_dir+"/*model*.pdb "+outdir)
        sys.exit()
    else:
        domain_assembly(num,target,fasta,modeller,dm_dict,dm_dir)


    ###############################################################################
    #### Step 4: Select top 5 models by comparing FL and DM models#################
    ####         Use SBROD for ranking#############################################
    print("Start ranking models by SBROD.....")
    mkdir_if_not_exist(outdir+"/sbrod")
    SBROD(num,outdir)
    print("Ranking by SBROD completed.....")