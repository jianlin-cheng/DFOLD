#!/usr/bin/perl -w
 use FileHandle; # use FileHandles instead of open(),close()
 use Cwd;
 use Cwd 'abs_path';

 # perl /home/jh7x3/DFOLD_v1.1/setup_database.pl
 
######################## !!! customize settings here !!! ############################
#																					#
# Set directory of DFOLD databases and tools								        #

$DFOLD_db_tools_dir = "/data/commons/DFOLD_db_tools/";							        
						        

######################## !!! End of customize settings !!! ##########################

######################## !!! Don't Change the code below##############

$install_dir = getcwd;
$install_dir=abs_path($install_dir);


if(!-s $install_dir)
{
	die "The DFOLD directory ($install_dir) is not existing, please revise the customize settings part inside the configure.pl, set the path as  your unzipped DFOLD directory\n";
}

if ( substr($install_dir, length($install_dir) - 1, 1) ne "/" )
{
        $install_dir .= "/";
}


print "checking whether the configuration file run in the installation folder ...";
$cur_dir = `pwd`;
chomp $cur_dir;
$configure_file = "$cur_dir/configure.pl";
if (! -f $configure_file || $install_dir ne "$cur_dir/")
{
        die "\nPlease check the installation directory setting and run the configure program under the main directory of DFOLD.\n";
}
print " OK!\n";


if(!-d $DFOLD_db_tools_dir)
{
	$status = system("mkdir $DFOLD_db_tools_dir");
	if($status)
	{
		die "Failed to create folder $DFOLD_db_tools_dir\n";
	}
}
$DFOLD_db_tools_dir=abs_path($DFOLD_db_tools_dir);



if ( substr($DFOLD_db_tools_dir, length($DFOLD_db_tools_dir) - 1, 1) ne "/" )
{
        $DFOLD_db_tools_dir .= "/";
}

=pod
if (prompt_yn("DFOLD database will be installed into <$DFOLD_db_tools_dir> ")){

}else{
	die "The installation is cancelled!\n";
}
=cut

print "Start install DFOLD into <$DFOLD_db_tools_dir>\n"; 



chdir($DFOLD_db_tools_dir);

$database_dir = "$DFOLD_db_tools_dir/databases";
$tools_dir = "$DFOLD_db_tools_dir/tools";


if(!-d $database_dir)
{
	$status = system("mkdir $database_dir");
	if($status)
	{
		die "Failed to create folder ($database_dir), check permission or folder path\n";
	}
	`chmod -R 755 $database_dir`;
}
if(!-d $tools_dir)
{ 
	$status = system("mkdir $tools_dir");
	if($status)
	{
		die "Failed to create folder ($tools_dir), check permission or folder path\n";
	}
	`chmod -R 755 $tools_dir`;
}

####### tools compilation 
`mkdir -p $install_dir/installation/DFOLD_manually_install_files`;
if(-e "$install_dir/installation/DFOLD_manually_install_files/P1_install_boost.sh")
{
	`rm $install_dir/installation/DFOLD_manually_install_files/*sh`;
}

##### check gcc version
$check_gcc = system("gcc -dumpversion");
if($check_gcc)
{
	print "Failed to find gcc in system, please check gcc version";
	exit;
}

$gcc_v = `gcc -dumpversion`;
chomp $gcc_v;
@gcc_version = split(/\./,$gcc_v);
if($gcc_version[0] != 4)
{
	print "!!!! Warning: gcc 4.X.X is recommended for boost installation, currently is $gcc_v\n\n";
	sleep(2);
	
}


#### (2) Download basic tools
print("\n#### (2) Download basic tools\n\n");

chdir($tools_dir);

$basic_tools_list = "SCRATCH-1D_1.1.tar.gz;cns_solve_1.3.tar.gz;dssp-2.0.4-linux-amd64.tar.gz";
@basic_tools = split(';',$basic_tools_list);
foreach $tool (@basic_tools)
{
	$toolname = substr($tool,0,index($tool,'.tar.gz'));
	if(-d "$tools_dir/$toolname")
	{
		if(-e "$tools_dir/$toolname/download.done")
		{
			print "\t$toolname is done!\n";
			next;
		}
	}elsif(-f "$tools_dir/$toolname")
	{
			print "\t$toolname is done!\n";
			next;
	}				
	if(-e $tool)
	{
		`rm $tool`;
	}
	`wget http://sysbio.rnet.missouri.edu/multicom_db_tools/tools/$tool`;
	if(-e "$tool")
	{
		print "\n\t$tool is found, start extracting files......\n\n";
		`tar -zxf $tool`;
		`echo 'done' > $toolname/download.done`;
		`rm $tool`;
		`chmod -R 755 $toolname`;
	}else{
		die "Failed to download $tool from http://sysbio.rnet.missouri.edu/multicom_db_tools/tools, please contact chengji\@missouri.edu\n";
	}
}


$tooldir = $DFOLD_db_tools_dir.'/tools/SCRATCH-1D_1.1/';
if(-d $tooldir)
{
	print "\n#########  Setting up SCRATCH \n";
	chdir $tooldir;
	if(-f 'install.pl')
	{
		$status = system("perl install.pl");
		if($status){
			die "Failed to run perl install.pl \n";
			exit(-1);
		}
	}else{
		die "The configure.pl file for $tooldir doesn't exist, please contact us(Jie Hou: jh7x3\@mail.missouri.edu)\n";
	}
}


### change permission of SCRATCH, will write tmp file 
if(-d "$DFOLD_db_tools_dir/tools/SCRATCH-1D_1.1")
{
	`chmod -R 777 $DFOLD_db_tools_dir/tools/SCRATCH-1D_1.1`;
}


sub prompt_yn {
  my ($query) = @_;
  my $answer = prompt("$query (Y/N): ");
  return lc($answer) eq 'y';
}
sub prompt {
  my ($query) = @_; # take a prompt string as argument
  local $| = 1; # activate autoflush to immediately show the prompt
  print $query;
  chomp(my $answer = <STDIN>);
  return $answer;
}




sub configure_file{
	my ($option_list,$prefix) = @_;
	open(IN,$option_list) || die "Failed to open file $option_list\n";
	$file_indx=0;
	while(<IN>)
	{
		$file = $_;
		chomp $file;
		if ($file =~ /^$prefix/)
		{
			$option_default = $install_dir.$file.'.default';
			$option_new = $install_dir.$file;
			$file_indx++;
			print "$file_indx: Configuring $option_new\n";
			if (! -f $option_default)
			{
					die "\nOption file $option_default not exists.\n";
			}	
			
			open(IN1,$option_default) || die "Failed to open file $option_default\n";
			open(OUT1,">$option_new") || die "Failed to open file $option_new\n";
			while(<IN1>)
			{
				$line = $_;
				chomp $line;

				if(index($line,'SOFTWARE_PATH')>=0)
				{
					$line =~ s/SOFTWARE_PATH/$install_dir/g;
					$line =~ s/\/\//\//g;
					print OUT1 $line."\n";
				}else{
					print OUT1 $line."\n";
				}
			}
			close IN1;
			close OUT1;
		}
	}
	close IN;
}


sub configure_tools{
	my ($option_list,$prefix,$DBtool_path) = @_;
	open(IN,$option_list) || die "Failed to open file $option_list\n";
	$file_indx=0;
	while(<IN>)
	{
		$file = $_;
		chomp $file;
		if ($file =~ /^$prefix/)
		{
			$option_default = $DBtool_path.$file.'.default';
			$option_new = $DBtool_path.$file;
			$file_indx++;
			print "$file_indx: Configuring $option_new\n";
			if (! -f $option_default)
			{
					next;
					#die "\nOption file $option_default not exists.\n";
			}	
			
			open(IN1,$option_default) || die "Failed to open file $option_default\n";
			open(OUT1,">$option_new") || die "Failed to open file $option_new\n";
			while(<IN1>)
			{
				$line = $_;
				chomp $line;

				if(index($line,'SOFTWARE_PATH')>=0)
				{
					$line =~ s/SOFTWARE_PATH/$DBtool_path/g;
					$line =~ s/\/\//\//g;
					print OUT1 $line."\n";
				}else{
					print OUT1 $line."\n";
				}
			}
			close IN1;
			close OUT1;
		}
	}
	close IN;
}



sub configure_file2{
	my ($option_list,$prefix) = @_;
	open(IN,$option_list) || die "Failed to open file $option_list\n";
	$file_indx=0;
	while(<IN>)
	{
		$file = $_;
		chomp $file;
		if ($file =~ /^$prefix/)
		{
			@tmparr = split('/',$file);
			$filename = pop @tmparr;
			chomp $filename;
			$filepath = join('/',@tmparr);
			$option_default = $install_dir.$filepath.'/.'.$filename.'.default';
			$option_new = $install_dir.$file;
			$file_indx++;
			print "$file_indx: Configuring $option_new\n";
			if (! -f $option_default)
			{
					die "\nOption file $option_default not exists.\n";
			}	
			
			open(IN1,$option_default) || die "Failed to open file $option_default\n";
			open(OUT1,">$option_new") || die "Failed to open file $option_new\n";
			while(<IN1>)
			{
				$line = $_;
				chomp $line;

				if(index($line,'SOFTWARE_PATH')>=0)
				{
					$line =~ s/SOFTWARE_PATH/$install_dir/g;
					$line =~ s/\/\//\//g;
					print OUT1 $line."\n";
				}else{
					print OUT1 $line."\n";
				}
			}
			close IN1;
			close OUT1;
		}
	}
	close IN;
}


