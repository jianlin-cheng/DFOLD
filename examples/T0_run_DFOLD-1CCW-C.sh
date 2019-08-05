#!/bin/bash
#SBATCH -J  DFOLD
#SBATCH -o DFOLD-%j.out
#SBATCH --partition Lewis,hpc5,hpc4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=2G
#SBATCH --time 1-00:00


mkdir -p /data/jh7x3/DFOLD/test_out/1G5T-A/
cd /data/jh7x3/DFOLD/test_out/1G5T-A/




if [[ ! -f "/data/jh7x3/DFOLD/test_out/1G5T-A/stage2/1G5T-A_1.pdb" ]];then 
	printf "perl /data/jh7x3/DFOLD/src/DFOLD.pl -rrtype cb -stage2 1 -mcount 5 -seq /data/jh7x3/DFOLD/examples/1G5T-A.fasta -ss /data/jh7x3/DFOLD/examples/1G5T-A.ss  -rr /data/jh7x3/DFOLD/examples/1G5T-A.dist.rr  -o /data/jh7x3/DFOLD/test_out/1G5T-A/\n\n"
	perl /data/jh7x3/DFOLD/src/DFOLD.pl -rrtype cb -stage2 1 -mcount 5 -seq /data/jh7x3/DFOLD/examples/1G5T-A.fasta -ss /data/jh7x3/DFOLD/examples/1G5T-A.ss  -rr /data/jh7x3/DFOLD/examples/1G5T-A.dist.rr  -o /data/jh7x3/DFOLD/test_out/1G5T-A/
fi




printf "\nFinished.."
printf "\nCheck log file </data/jh7x3/DFOLD/test_out/1G5T-A.log>\n\n"


if [[ ! -f "/data/jh7x3/DFOLD/test_out/1G5T-A/stage2/1G5T-A_1.pdb" ]];then 
	printf "!!!!! Failed to run DFOLD, check the installation </data/jh7x3/DFOLD/src/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /data/jh7x3/DFOLD/test_out/1G5T-A/stage2/1G5T-A_1.pdb\n\n"
fi

printf "Validating the results\n\n";
printf "/data/jh7x3/DFOLD/tools/TMscore  /data/jh7x3/DFOLD/test_out/1G5T-A/stage2/1G5T-A_1.pdb  /data/jh7x3/DFOLD/installation/benchmark/native_structure/1G5T-A.pdb\n\n"
/data/jh7x3/DFOLD/tools/TMscore  /data/jh7x3/DFOLD/test_out/1G5T-A/stage2/1G5T-A_1.pdb  /data/jh7x3/DFOLD/installation/benchmark/native_structure/1G5T-A.pdb

