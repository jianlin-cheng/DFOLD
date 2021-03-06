#!/usr/bin/perl -w

if (@ARGV != 5)
{
	die "need three parameters: option file, sequence file, output dir.\n"; 
}

$fasta_dir = shift @ARGV;
$ss_dir = shift @ARGV;
$pdb_dir = shift @ARGV;
$restraints_dir = shift @ARGV;
$work_dir = shift @ARGV;

if(!(-d $work_dir))
{
	`mkdir $work_dir`;
}

opendir(DIR,"$fasta_dir") || die "Failed to open directory $fasta_dir\n";
@files = readdir(DIR);
closedir(DIR);

foreach $file (sort @files)
{
	if($file eq '.' or $file eq '..')
	{
		next;
	}
	$pdbname = substr($file,0,index($file,'.fasta'));
	if($pdbname eq 'T0999')
	{
		next;
	}
	$pdbfile = "$pdb_dir/$pdbname.pdb";
	if(!(-e $pdbfile))
	{
		print "Failed to find $pdbfile\n";
		next;
	}
	$ssfile = "$ss_dir/$pdbname.ss";
	if(!(-e $ssfile))
	{
		print "Failed to find $ssfile\n";
		next;
	}
	$restraintsfile = "$restraints_dir/$pdbname.dist.rr";
	if(!(-e $restraintsfile))
	{
		print "Failed to find $restraintsfile\n";
		next;
	}
	
	if(!(-e $pdbfile) and !(-e $ssfile)  and !(-e $restraintsfile) )
	{
		print "Failed to find $pdbfile or $ssfile or $restraintsfile\n";
		next;
	}
	$outdir = "$work_dir/$pdbname";
	if(!(-d $outdir))
	{
		`mkdir $outdir`;
	}

	if(-e "$outdir/stage2/${pdbname}_model1.pdb")
	{
		print "$outdir/stage2/${pdbname}_model1.pdb already generated\n";
		next;
	}
	
	$start_run = time();
	
	print "perl  /data/jh7x3/DFOLD/src/DFOLD.pl -rrtype cb -stage2 1 -mcount 5 -seq $fasta_dir/$file -ss $ssfile  -rr $restraintsfile -o $outdir\n";
	system("perl /data/jh7x3/DFOLD/src/DFOLD.pl -rrtype cb -stage2 1 -mcount 5 -seq $fasta_dir/$file -ss $ssfile  -rr $restraintsfile -o $outdir");
	
	
	$end_run = time();
	$run_time = $end_run - $start_run;
	

	if(-e "$outdir/stage2/${pdbname}_model1.pdb")
	{
		print "$outdir/stage2/${pdbname}_model1.pdb already generated\n";
		`echo $run_time > $outdir/folding.done`;
	}else{
		print "$outdir/stage2/${pdbname}_model1.pdb failed to be generated\n";
	}
	
}
