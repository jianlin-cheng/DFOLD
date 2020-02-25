#!/bin/bash
#SBATCH -J  DFOLD
#SBATCH -o DFOLD-%j.out
#SBATCH --partition Lewis,hpc5,hpc4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=2G
#SBATCH --time 1-00:00


mkdir -p /home/tianqi/test/DFOLD2/test_out/1BYR-A/
cd /home/tianqi/test/DFOLD2/test_out/1BYR-A/




if [[ ! -f "/home/tianqi/test/DFOLD2/test_out/1BYR-A/stage2/1BYR-A_model1.pdb" ]];then 
	printf "perl /home/tianqi/test/DFOLD2/src/DFOLD.pl -rrtype cb -stage2 1 -mcount 5 -seq /home/tianqi/test/DFOLD2/examples/1BYR-A.fasta -ss /home/tianqi/test/DFOLD2/examples/1BYR-A.ss  -rr /home/tianqi/test/DFOLD2/examples/1BYR-A.dist.rr  -o /home/tianqi/test/DFOLD2/test_out/1BYR-A/\n\n"
	perl /home/tianqi/test/DFOLD2/src/DFOLD.pl -rrtype cb -stage2 1 -mcount 5 -seq /home/tianqi/test/DFOLD2/examples/1BYR-A.fasta -ss /home/tianqi/test/DFOLD2/examples/1BYR-A.ss  -rr /home/tianqi/test/DFOLD2/examples/1BYR-A.dist.rr  -o /home/tianqi/test/DFOLD2/test_out/1BYR-A/
fi




printf "\nFinished.."
printf "\nCheck log file </home/tianqi/test/DFOLD2/test_out/1BYR-A.log>\n\n"


if [[ ! -f "/home/tianqi/test/DFOLD2/test_out/1BYR-A/stage2/1BYR-A_model1.pdb" ]];then 
	printf "!!!!! Failed to run DFOLD, check the installation </home/tianqi/test/DFOLD2/src/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/tianqi/test/DFOLD2/test_out/1BYR-A/stage2/1BYR-A_model1.pdb\n\n"
fi

printf "Validating the results\n\n";
printf "/home/tianqi/test/DFOLD2/tools/TMscore  /home/tianqi/test/DFOLD2/test_out/1BYR-A/stage2/1BYR-A_model1.pdb  /home/tianqi/test/DFOLD2/installation/benchmark/native_structure/1BYR-A.pdb\n\n"
/home/tianqi/test/DFOLD2/tools/TMscore  /home/tianqi/test/DFOLD2/test_out/1BYR-A/stage2/1BYR-A_model1.pdb  /home/tianqi/test/DFOLD2/installation/benchmark/native_structure/1BYR-A.pdb

