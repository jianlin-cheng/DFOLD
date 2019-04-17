# DistFOLD
The distance-based protein folding


--------------------------------------------------------------------------------
Installing DistFOLD
--------------------------------------------------------------------------------
1. Download DSSP
   1.1 Download DSSP
       $ wget ftp://ftp.cmbi.ru.nl/pub/software/dssp/dssp-2.0.4-linux-amd64
   1.2 Make it executable
       $ chmod +x dssp-2.0.4-linux-amd64
   1.3 Test it
       $ ./dssp-2.0.4-linux-amd64

2. Install CNS suite
   2.1. To download CNS suite, provide your academic profile related 
        information at http://cns-online.org/cns_request/. An email
        with (a) link to download, (b) login, and (c) password
        will be sent to you. Follow the link, possibly
        http://cns-online.org/download/, and download 
        CNS suite "cns_solve_1.3_all_intel-mac_linux.tar.gz".
   2.2. Unzip
        $ tar xzvf cns_solve_1.3_all_intel-mac_linux.tar.gz
   2.3. Change directory to cns_solve
        $ cd cns_solve_1.3
   2.4. Unhide the file '.cns_solve_env_sh'
        $ mv .cns_solve_env_sh cns_solve_env.sh
   2.5. Edit 'cns_solve_env.sh' and 'cns_solve_env' to replace
        '_CNSsolve_location_' with CNS installation directory.
        For instance, if your CNS installation path is
        '/home/user/programs/cns_solve_1.3' replace
        '_CNSsolve_location_' with this path
   2.6. Test CNS installation
        $ source cns_solve_env.sh
        $ cd test 
        $ ../bin/run_tests -tidy *.inp
 
3. Download DisFOLD from Github

4. Change variable values in the  distfold.pl file
   4.1 Change the path of the variable $dssp to DSSP executable
   4.2 Change the path of the variable $cns_suite 
       to CNS installation directory
   4.3 Make it executable
       $chmod +x distfold.pl
  
5. Test DistFOLD
   5.1 Execute "perl ./distfold.pl" or "./distfold.pl"
       It should print the usage information.
   5.2 Test using an example
   
       $ perl ./confold_dist.pl -rrtype cb -stage2 1 -mcount 5 -seq ./test/input/T0992.fasta -ss ./test/input/T0992.ss  -rr ./test/input/T0992.dist.rr  -o ./test/output/
       
       $ ./tools/TMscore ./test/output/stage2/T0992_model1.pdb  ./test/input/T0992.pdb
       
           TM-score    = 0.9902
           
           RMSD = 0.396
       
   5.3 (Optional) Visualize the top model 'T0992_model1.pdb' 
       in ./test/output/stage2/ folder using a pdb visualization tool
       like USEF Chimera or PyMol or JMol.   
   5.4 (Optional) For a more comprehensive testing see the section below.




To learn about execution time of CONFOLD please visit
http://protein.rnet.missouri.edu/confold/tool.php
   
