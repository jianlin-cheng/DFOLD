#! /usr/bin/perl -w
# perl /home/jh7x3/CASP11/CAMEO/superimpose_tool_package/superimpose_two_pdb.pl  casp2.pdb casp1.pdb /home/jh7x3/CASP11/CAMEO/superimpose_tool_package/TMalign casp2_superimpose.pdb

#Author: Renzhi Cao #
 require 5.003; # need this version of Perl or newer
 use English; # use English names, not cryptic ones
 use FileHandle; # use FileHandles instead of open(),close()
 use Carp; # get standard error / warning messages
 use strict; # force disciplined use of variables
 use Cwd;
 use Cwd 'abs_path';
 use Scalar::Util qw(looks_like_number);
 sub get_len($);
 if(@ARGV<4)
 {
     print "This script will generate alignment matrix from one pdb to another pdb!\n";
     print "perl $0 addr_pdb1 addr_pdb2 addr_TM_score addr_matrix\n";
     print "For example:\n";
     print "perl $0 ../test/chainA ../test/chainB /home/rcrg4/tool/TMalign/TMalign ../test/matrix_AB\n";
     exit(0); 
 }

 my($pdb1)=$ARGV[0]; 
 my($pdb2)=$ARGV[1]; # native
 my($tm_score) = $ARGV[2];
 my($addr_output) = $ARGV[3];

 my($file,$path_one_target,$path_out);
 my(@files,@tem);
 my($IN,$OUT,$line,$i);
 my($tm_chain);
 my  $addr_matrix = "$addr_output.matrix";
 
 
 system("$tm_score -B $pdb1 -A $pdb2 > $addr_matrix");
 my($line1)="NULL";
 my($line2)="NULL";
 my($line3)="NULL";
 ##### now get the matrix #######
 $IN = new FileHandle "$addr_matrix";
 while(defined($line=<$IN>))
 {
   chomp($line);
   if($line eq "----- The rotation matrix to rotate Structure B to Structure A -----")
   {
     print "Find the matrix ! \n";
     if(defined($line = <$IN>))
     {
        # skip the head 
     }
     last;
   }
 } 
 
 if(defined($line=<$IN>))
 {
    chomp($line);
    $line1= $line;
 }
 if(defined($line=<$IN>))
 {
    chomp($line);
    $line2= $line;
 }
 if(defined($line=<$IN>))
 {
    chomp($line);
    $line3= $line;
 }
 $IN->close();
 if($line1 eq "NULL" || $line2 eq "NULL" || $line3 eq "NULL")
 {
   die "The command $tm_score -B $pdb1 -A $pdb2 > $addr_matrix fails, check it!\n";
 }

 $OUT = new FileHandle ">$addr_matrix";
 @tem = split(/\s+/,$line1);
# print $line1."\n";
 print $OUT $tem[1]."\t".$tem[2]."\t".$tem[3]."\t".$tem[4]."\n";
 @tem = split(/\s+/,$line2);
 print $OUT $tem[1]."\t".$tem[2]."\t".$tem[3]."\t".$tem[4]."\n";
 @tem = split(/\s+/,$line3);
 print $OUT $tem[1]."\t".$tem[2]."\t".$tem[3]."\t".$tem[4]."\n"; 
 $OUT->close();

 
 
 ############# start rotate 

 my($tag_true)=0;
 #### first check the matrix #######
 my($t1,$t2,$t3,$m11,$m12,$m13,$m21,$m22,$m23,$m31,$m32,$m33);
 $IN = new FileHandle "$addr_matrix";
 if(defined($line=<$IN>))
 {
    chomp($line);
    @tem = split(/\s+/,$line);
    if(@tem!=4)
    {
       print "Error, check the line : $line, in $addr_matrix, format problem!\n";
       #next;
       exit(0);
    }
    $tag_true++;
    $t1 = $tem[0];
    $m11 = $tem[1];
    $m12 = $tem[2];
    $m13 = $tem[3];
 }
 if(defined($line=<$IN>))
 {
    chomp($line);
    @tem = split(/\s+/,$line);
    if(@tem!=4)
    {
       print "Error, check the line : $line, in $addr_matrix, format problem!\n";
       exit(0);
    }
    $tag_true++;
    $t2 = $tem[0];
    $m21 = $tem[1];
    $m22 = $tem[2];
    $m23 = $tem[3];
 }
 if(defined($line=<$IN>))
 {
    chomp($line);
    @tem = split(/\s+/,$line);
    if(@tem!=4)
    {
       print "Error, check the line : $line, in $addr_matrix, format problem!\n";
       exit(0);
    }
    $tag_true++;
    $t3 = $tem[0];
    $m31 = $tem[1];
    $m32 = $tem[2];
    $m33 = $tem[3];
 }
 $IN->close();
 if($tag_true !=3)
 {
    print "Error format for $addr_matrix, check it!\n";
    exit(0);
 }
 
 my $addr_input = $pdb1;
 #################################################
 print "Rotating pdb $addr_input to $addr_output ...\n"; 
 my($X,$Y,$Z,$X2,$Y2,$Z2);
 $IN = new FileHandle "$addr_input";
 $OUT = new FileHandle ">$addr_output";
 while(defined($line=<$IN>))
 {
    @tem = split(/\s+/,$line);
    if($tem[0] ne "ATOM")
    {
        next;
    }
#    print "Get x,y,z";
    $X=substr($line,30,8);
    $Y=substr($line,38,8);
    $Z=substr($line,46,8);
    
    $X2 = $t1+$X*$m11+$Y*$m12+$Z*$m13;
    $Y2 = $t2+$X*$m21+$Y*$m22+$Z*$m23;
    $Z2 = $t3+$X*$m31+$Y*$m32+$Z*$m33;
#    print "Writing it back, and pint out!\n";
    
#print $line."\n";
my $chain_ID='A';
#print "Convert to coordinate ($X2,$Y2,$Z2)\n";

    substr($line,30,8) = sprintf("%8.3f",$X2);
    substr($line,38,8) = sprintf("%8.3f",$Y2);
    substr($line,46,8) = sprintf("%8.3f",$Z2);
    ##### change the chainID if needed ######
    if($chain_ID ne "*")
    {
       substr($line,21,1) = $chain_ID;
    }     

    print $OUT $line;
 }
 $IN->close();
 $OUT->close();

 `rm $addr_matrix`;