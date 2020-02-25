#!/bin/bash
#SBATCH -J  GFOLD
#SBATCH -o GFOLD-%j.out
#SBATCH --partition Lewis,hpc5,hpc4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10G
#SBATCH --time 1-00:00


mkdir -p /home/tianqi/test/DFOLD2/test_out/1G5T-A/
cd /home/tianqi/test/DFOLD2/test_out/1G5T-A/




export LD_LIBRARY_PATH=/home/tianqi/test/DFOLD2/tools/modeller-9.16/lib/x86_64-intel8/:/home/tianqi/test/DFOLD2/tools/IMP2.6/lib:/home/tianqi/test/DFOLD2/tools/boost_1_55_0/lib:$LD_LIBRARY_PATH
PYTHONPATH="/home/tianqi/test/DFOLD2/tools/IMP2.6/lib:/home/tianqi/test/DFOLD2/tools/modeller-9.16/lib/x86_64-intel8/python2.5/:/home/tianqi/test/DFOLD2/tools/modeller-9.16/modlib/:$PYTHONPATH"
export PYTHONPATH



if [[ ! -f "/home/tianqi/test/DFOLD2/test_out/1G5T-A/1G5T-A/1G5T-A_model1.pdb" ]];then 
	printf "python /home/tianqi/test/DFOLD2/src/GFOLD.py  --target 1G5T-A  --fasta /home/tianqi/test/DFOLD2/examples/1G5T-A.fasta --ss /home/tianqi/test/DFOLD2/examples/1G5T-A.ss  --hbond 1 --restraints /home/tianqi/test/DFOLD2/examples/1G5T-A.restraints --type CB --distdev 0.1  --epoch 10  --cgstep 100  --dir  /home/tianqi/test/DFOLD2/test_out/1G5T-A/ --sep 1\n\n"
	python /home/tianqi/test/DFOLD2/src/GFOLD.py  --target 1G5T-A  --fasta /home/tianqi/test/DFOLD2/examples/1G5T-A.fasta --ss /home/tianqi/test/DFOLD2/examples/1G5T-A.ss  --hbond 1 --restraints /home/tianqi/test/DFOLD2/examples/1G5T-A.restraints --type CB --distdev 0.1  --epoch 10  --cgstep 100  --dir  /home/tianqi/test/DFOLD2/test_out/1G5T-A/ --sep 1 
fi

printf "\nFinished.."
printf "\nCheck log file </home/tianqi/test/DFOLD2/test_out/1G5T-A.log>\n\n"


if [[ ! -f "/home/tianqi/test/DFOLD2/test_out/1G5T-A/1G5T-A/1G5T-A_model1.pdb" ]];then 
	printf "!!!!! Failed to run GFOLD, check the installation </home/tianqi/test/DFOLD2/src/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/tianqi/test/DFOLD2/test_out/1G5T-A/1G5T-A/1G5T-A_model1.pdb\n\n"
fi

printf "Validating the results\n\n";
printf "/home/tianqi/test/DFOLD2/tools/TMscore  /home/tianqi/test/DFOLD2/test_out/1G5T-A/1G5T-A/1G5T-A_model1.pdb  /home/tianqi/test/DFOLD2/installation/benchmark/native_structure/1G5T-A.pdb\n\n"
/home/tianqi/test/DFOLD2/tools/TMscore  /home/tianqi/test/DFOLD2/test_out/1G5T-A/1G5T-A/1G5T-A_model1.pdb  /home/tianqi/test/DFOLD2/installation/benchmark/native_structure/1G5T-A.pdb

