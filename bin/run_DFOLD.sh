#!/bin/sh
# DeepRank prediction file for protein quality assessment #
if [ $# -lt 5 ]
then
	echo "need four parameters : target id, path of fasta sequence, path of predicted secondary structure, path of restraints, directory of output"
	exit 1
fi

targetid=$1 
fasta=$2 
secondary_structure=$3 
distances=$4   #T0992.dist.rr
outputfolder=$5 



if [[ "$fasta" != /* ]]
then
   echo "Please provide absolute path for $fasta"
   exit
fi

if [[ "$outputfolder" != /* ]]
then
   echo "Please provide absolute path for $outputdir"
   exit
fi


mkdir -p $outputfolder
cd $outputfolder


printf "perl /home/tianqi/test/DFOLD2/src/DFOLD.pl -rrtype cb -stage2 1 -mcount 5 -seq $fasta -ss $secondary_structure  -rr $distances  -o $outputfolder\n\n"

perl /home/tianqi/test/DFOLD2/src/DFOLD.pl -rrtype cb -stage2 1 -mcount 5 -seq $fasta -ss $secondary_structure  -rr $distances  -o $outputfolder






