#!/bin/bash
#SBATCH -J  DFOLD
#SBATCH -o DFOLD-%j.out
#SBATCH --partition Lewis,hpc5,hpc4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=2G
#SBATCH --time 1-00:00


mkdir -p /home/tianqi/test/DFOLD2/test_out/1AYO-B/
cd /home/tianqi/test/DFOLD2/test_out/1AYO-B/




if [[ ! -f "/home/tianqi/test/DFOLD2/test_out/1AYO-B/stage2/1AYO-B_model1.pdb" ]];then 
	printf "perl /home/tianqi/test/DFOLD2/src/DFOLD.pl -rrtype cb -stage2 1 -mcount 5 -seq /home/tianqi/test/DFOLD2/examples/1AYO-B.fasta -ss /home/tianqi/test/DFOLD2/examples/1AYO-B.ss  -rr /home/tianqi/test/DFOLD2/examples/1AYO-B.dist.rr  -o /home/tianqi/test/DFOLD2/test_out/1AYO-B/\n\n"
	perl /home/tianqi/test/DFOLD2/src/DFOLD.pl -rrtype cb -stage2 1 -mcount 5 -seq /home/tianqi/test/DFOLD2/examples/1AYO-B.fasta -ss /home/tianqi/test/DFOLD2/examples/1AYO-B.ss  -rr /home/tianqi/test/DFOLD2/examples/1AYO-B.dist.rr  -o /home/tianqi/test/DFOLD2/test_out/1AYO-B/
fi




printf "\nFinished.."
printf "\nCheck log file </home/tianqi/test/DFOLD2/test_out/1AYO-B.log>\n\n"


if [[ ! -f "/home/tianqi/test/DFOLD2/test_out/1AYO-B/stage2/1AYO-B_model1.pdb" ]];then 
	printf "!!!!! Failed to run DFOLD, check the installation </home/tianqi/test/DFOLD2/src/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/tianqi/test/DFOLD2/test_out/1AYO-B/stage2/1AYO-B_model1.pdb\n\n"
fi

printf "Validating the results\n\n";
printf "/home/tianqi/test/DFOLD2/tools/TMscore  /home/tianqi/test/DFOLD2/test_out/1AYO-B/stage2/1AYO-B_model1.pdb  /home/tianqi/test/DFOLD2/installation/benchmark/native_structure/1AYO-B.pdb\n\n"
/home/tianqi/test/DFOLD2/tools/TMscore  /home/tianqi/test/DFOLD2/test_out/1AYO-B/stage2/1AYO-B_model1.pdb  /home/tianqi/test/DFOLD2/installation/benchmark/native_structure/1AYO-B.pdb

