# The DFOLD protein structure system using simulated annealing and residue-residue distance. 
<h3> slides related to DFOLD method can be found in https://drive.google.com/drive/u/0/folders/1yoxuNOQsscytWkgJ36wtVUuWzKe94j5n</h3>


**(1) Download DFOLD package (short path is recommended)**

```
git clone https://github.com/jianlin-cheng/DFOLD.git

(If fail, try username) git clone https://huge200890@github.com/jianlin-cheng/DFOLD.git

cd DFOLD
```

**(2) Setup the tools and download the database (required)**

```
a. edit setup_database.pl
    (i) Manually create folder for database (i.e., /data/commons/DFOLD_db_tools/)
    (ii) Set the path of variable '$DFOLD_db_tools_dir' for DFOLD databases and tools (i.e., /data/commons/DFOLD_db_tools/).

b. perl setup_database.pl
```

**(3) Configure DFOLD system (required)**

```
a. edit configure.pl

b. set the path of variable '$DFOLD_db_tools_dir' for DFOLD databases and tools (i.e., /data/commons/DFOLD_db_tools/).

c. save configure.pl

perl configure.pl
```

**(4) Testing the GFOLD method (recommended)**


```

cd examples

sh T0_run_DFOLD-1ALY-A.sh

sh T0_run_DFOLD-1AYO-B.sh

sh T0_run_DFOLD-1BYR-A.sh

sh T0_run_DFOLD-1CCW-C.sh

sh T0_run_DFOLD-1G5T-A.sh



Output examples:
Job successfully completed!
Results: /data/jh7x3/DFOLD/test_out/1ALY-A/stage2/1ALY-A_1.pdb

Validating the results

/data/jh7x3/GFOLD/tools/TMscore  /data/jh7x3/DFOLD/test_out/1ALY-A/stage2/1ALY-A_1.pdb  /data/jh7x3/GFOLD/installation/benchmark/native_structure/1ALY-A.pdb


 *****************************************************************************
 *                                 TM-SCORE                                  *
 * A scoring function to assess the quality of protein structure predictions *
 * Based on statistics:                                                      *
 *       0.0 < TM-score < 0.17, Random predictions                           *
 *       0.4 < TM-score < 1.00, Meaningful predictions                       *
 * Reference: Yang Zhang and Jeffrey Skolnick, Proteins 2004 57: 702-710     *
 * For comments, please email to: yzhang@ku.edu                              *
 *****************************************************************************

Structure1: /data/jh7x  Length=  146
Structure2: /data/jh7x  Length=  146 (by which all scores are normalized)
Number of residues in common=  146
RMSD of  the common residues=    0.376

TM-score    = 0.9932  (d0= 4.50, TM10= 0.9932)
MaxSub-score= 0.9889  (d0= 3.50)
GDT-TS-score= 0.9983 %(d<1)=0.9932 %(d<2)=1.0000 %(d<4)=1.0000 %(d<8)=1.0000
GDT-HA-score= 0.9709 %(d<0.5)=0.8904 %(d<1)=0.9932 %(d<2)=1.0000 %(d<4)=1.0000

 -------- rotation matrix to rotate Chain-1 to Chain-2 ------
 i          t(i)         u(i,1)         u(i,2)         u(i,3)
 1   -174.7174922470   0.8855807046   0.1952525250  -0.4214537545
 2    -56.1568386650   0.1980585103  -0.9794687412  -0.0376006846
 3    156.7184010012  -0.4201424071  -0.0501740620  -0.9060700422

Superposition in the TM-score: Length(d<5.0)=146  RMSD=  0.38
(":" denotes the residue pairs of distance < 5.0 Angstrom)
GDQNPQIAAHVISEASSKTTSVLQWAEKGYYTMSNNLVTLENGKQLTVKRQGLYYIYAQVTFCSNREASSQAPFIASLCLKSPGRFERILLRAANTHSSAKPCGQQSIHLGGVFELQPGASVFVNVTDPSQVSHGTGFTSFGLLKL
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
GDQNPQIAAHVISEASSKTTSVLQWAEKGYYTMSNNLVTLENGKQLTVKRQGLYYIYAQVTFCSNREASSQAPFIASLCLKSPGRFERILLRAANTHSSAKPCGQQSIHLGGVFELQPGASVFVNVTDPSQVSHGTGFTSFGLLKL
12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
```



**(5) Run GFOLD for structure folding**

```
   Usage:
   $ sh bin/run_DFOLD.sh <target id> <file name>.fasta <path of predicted secondary structure> <path of distance> <output folder>

   Example:
   $ sh bin/run_DFOLD.sh 1ALY-A  /data/jh7x3/DFOLD/examples/1ALY-A.fasta  /data/jh7x3/DFOLD/examples/1ALY-A.ss  /data/jh7x3/DFOLD/examples/1ALY-A.dist.rr  /data/jh7x3/DFOLD/test_out/1ALY-A_out
   
  
