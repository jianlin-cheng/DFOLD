#!/bin/bash
#SBATCH -J  GFOLD
#SBATCH -o GFOLD-%j.out
#SBATCH --partition Lewis,hpc5,hpc4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10G
#SBATCH --time 1-00:00


mkdir -p /data/jh7x3/DFOLD/test_out/1G5T-A/
cd /data/jh7x3/DFOLD/test_out/1G5T-A/




export LD_LIBRARY_PATH=/data/jh7x3/DFOLD/tools/modeller-9.16/lib/x86_64-intel8/:/data/jh7x3/DFOLD/tools/IMP2.6/lib:/data/jh7x3/DFOLD/tools/boost_1_55_0/lib:$LD_LIBRARY_PATH
PYTHONPATH="/data/jh7x3/DFOLD/tools/IMP2.6/lib:/data/jh7x3/DFOLD/tools/modeller-9.16/lib/x86_64-intel8/python2.5/:/data/jh7x3/DFOLD/tools/modeller-9.16/modlib/:$PYTHONPATH"
export PYTHONPATH



if [[ ! -f "/data/jh7x3/DFOLD/test_out/1G5T-A/1G5T-A/1G5T-A_model1.pdb" ]];then 
	printf "python /data/jh7x3/DFOLD/src/GFOLD.py  --target 1G5T-A  --fasta /data/jh7x3/DFOLD/examples/1G5T-A.fasta --ss /data/jh7x3/DFOLD/examples/1G5T-A.ss  --hbond 1 --restraints /data/jh7x3/DFOLD/examples/1G5T-A.restraints --type CB --distdev 0.1  --epoch 10  --cgstep 100  --dir  /data/jh7x3/DFOLD/test_out/1G5T-A/ --sep 1\n\n"
	python /data/jh7x3/DFOLD/src/GFOLD.py  --target 1G5T-A  --fasta /data/jh7x3/DFOLD/examples/1G5T-A.fasta --ss /data/jh7x3/DFOLD/examples/1G5T-A.ss  --hbond 1 --restraints /data/jh7x3/DFOLD/examples/1G5T-A.restraints --type CB --distdev 0.1  --epoch 10  --cgstep 100  --dir  /data/jh7x3/DFOLD/test_out/1G5T-A/ --sep 1 
fi

printf "\nFinished.."
printf "\nCheck log file </data/jh7x3/DFOLD/test_out/1G5T-A.log>\n\n"


if [[ ! -f "/data/jh7x3/DFOLD/test_out/1G5T-A/1G5T-A/1G5T-A_model1.pdb" ]];then 
	printf "!!!!! Failed to run GFOLD, check the installation </data/jh7x3/DFOLD/src/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /data/jh7x3/DFOLD/test_out/1G5T-A/1G5T-A/1G5T-A_model1.pdb\n\n"
fi

printf "Validating the results\n\n";
printf "/data/jh7x3/DFOLD/tools/TMscore  /data/jh7x3/DFOLD/test_out/1G5T-A/1G5T-A/1G5T-A_model1.pdb  /data/jh7x3/DFOLD/installation/benchmark/native_structure/1G5T-A.pdb\n\n"
/data/jh7x3/DFOLD/tools/TMscore  /data/jh7x3/DFOLD/test_out/1G5T-A/1G5T-A/1G5T-A_model1.pdb  /data/jh7x3/DFOLD/installation/benchmark/native_structure/1G5T-A.pdb

