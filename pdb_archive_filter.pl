#!/usr/bin/perl

# DESCRIPTION:
# This program reads and processes PDB archive files
# in a way that retrieves the number of ATOMS in each
# file associated with publication year and resolution
# in Angstroms.
#
#------------------------------------------------------
# INPUT FORMAT:
# This program can only process PDB or CIF file formats.
# This means that inputs have to be PDB or CIF files.
# Also it is possible to provide a directory name that
# has PDB or CIF files stored in it for analysis. In
# this case the program will analyze every file in that
# directory.
#
#------------------------------------------------------
# OUTPUT FORMAT:
# Output format is a tab seperated text file. That
# has FILENAME, NUMBER_OF_ATOMS, PUBLICATION_DATE and
# RESOLUTION_VALUE fields. The fields are self
# explanatory. Each row represents a different file.
#
#------------------------------------------------------
# USAGE:
# Providing a directory with PDB files:
#	./pdb_archive_filter -d -pdb directory_path
#
# Providing an array of CIF files:
#	./pdb_archive_filter -cif file_1.cif \ 
#	file_2.cif file_3.cif.gz
#
# Providing a single PDB file:
#	./pdb_archive_filter -pdb file_1.pdb 
#
#------------------------------------------------------

use strict;
use warnings;

my ($svn_id) = ('$Id: pdb_file_statistics.pl 22 2023-01-09 14:09:29Z karolis $' =~ /^\$Id: (.*) \$$/);
print $svn_id, "\n\n";

#------------------------------------------------------
# Checking if required commands are installed in this
# linux device.
my $check = `bash scripts/command_check.sh`;

if( $check == 1 ) {
    die "Missing linux command cod-tools. You",
	" can download this command here: ",
	"https://github.com/cod-developers/cod-tools.";
}

#------------------------------------------------------
# Processing options and errors if there are any.

if( scalar @ARGV == 0 ) {
    die "No input file. In order for the ", 
	"program to work an input file or - for ", 
	"the standart input has to be specified ",
	"in program: ( $0 ).",
	"\n";
}

my $dash_option = 0;
my $directory_option = 0;
my $cif_option = 0;
my $pdb_option = 0;

my @arguments = @ARGV;

for my $element ( @arguments ) {
    if( $element =~ /^-$/ ) {
	$dash_option = 1;
	@ARGV = grep {$_ ne "-"} @ARGV;
    }

    elsif( $element =~ /^-pdb$/ ) {
	$pdb_option = 1;
	@ARGV = grep {$_ ne '-pdb'} @ARGV;
    }

    elsif( $element =~ /^-cif$/ ) {
	$cif_option = 1;
	@ARGV = grep {$_ ne '-cif'} @ARGV;
    }

    elsif( $element =~ /^-d$/ ) {
	$directory_option = 1;
	@ARGV = grep {$_ ne '-d'} @ARGV;
    }

    elsif( $element =~ /^-.+$/ ) {
	die "Unknown option specified. Option $element ",
	    "is unknown, please correct it or refer to the ",
	    "OPTIONS section in the README.txt file.",
	    "\n";
    }
}

my $sum = $directory_option + $dash_option + $pdb_option +
          $cif_option;

if( $sum == 0 ) {
    die "No options were specified. Because the program has ",
	"no default settings it is necessary to specify ",
	"options. Please refer to the OPTIONS section in the ",
	"README.txt file.",
	"\n";
}

elsif( $directory_option == $sum ) {
    die "Option -d has to be used with one another option. ",
	"Either -pdb or -cif according to the files that are ",
	"going to be analyzed. Please refer to the OPTIONS ",
	"section in the README.txt file.",
	"\n";
}

elsif( $directory_option == 1 && $dash_option == 1 ) {
    die "Option -d cannot be used with - option together. - ",
	"has to be used alone. -d option has to be used with ",
	"either -pdb or -cif options according to the files ",
	"you are analyzing. Please refer to the OPTIONS section ",
	"in the README.txt file.",
	"\n";
}

elsif( $pdb_option == 1 && $cif_option == 1 ) {
    die "Options -pdb and -cif cannot be used together. Use one ",
	"that refers to the type of files you are analyzing. ",
	"Please refer to the OPTIONS section in the README.txt ",
	"file.",
	"\n";
}

elsif( $dash_option == 1 && scalar @ARGV != 1 ) {
    die "When using - option it can only be the single possible ",
	"argument. No other file names can be specified. ",
	"Please refer to the OPTIONS section in the READMNE.txt ",
	"file.",
	"\n";
}

#------------------------------------------------------  
# File processing part.

# Extracting the current year from localtime()
# function and saving the file names into an
# array.
my $current_time = localtime();
my @time_array = split( ' ', $current_time );
my $current_year = $time_array[4];
my $year_part = substr( $current_year, -2 );
my @file_array = @ARGV;

print "ID\tYEAR\tMETHOD\tRESOLUTION\tATOMCOUNT\n";

# This block is used to process files that are passed
# as arguments (not a directory) for either PDB or
# CIF formats.
if( $directory_option == 0 ) {
    if( $pdb_option == 1) {

	my $file = $ARGV[0];
	my $output = `bash scripts/one_file_processing.sh $file PDB`;
	my @output_arr = split('\|', $output);
	my $year = 0;

	for my $i (0 .. $#output_arr) {
	    if( $output_arr[$i] eq "" ) {
		$output_arr[$i] = "N\/A";
	    }
	} 
	
	if ( $output_arr[1] =~ /^\d{2}$/ ) {
		if( $output_arr[1] ne "N\/A" and int($output_arr[1]) > int($year_part) ) {
	    		$year = "19" . $output_arr[1];
		}
		else {
	    		$year = "20" . $output_arr[1];
		}
	}
	
	print "$output_arr[0]\t$year\t$output_arr[2]",
	      "\t$output_arr[3]\t$output_arr[4]\n";
	
    }
    elsif( $cif_option == 1) {
	
	my $file = $ARGV[0];
        my $output = `bash scripts/one_file_processing.sh $file CIF`;
        my @output_arr = split('\|', $output);

	for my $i (0 .. $#output_arr) {
            if( $output_arr[$i] eq "." or $output_arr[$i] eq "?" ) {
		$output_arr[$i] = "N\/A";
            }
        }

	print "$output_arr[0]\t$output_arr[1]\t$output_arr[2]",
	      "\t$output_arr[3]\t$output_arr[4]\n";

    }

}

# This block is used for processing a passed
# directory for either PDB or CIF files.
else {
    if( $pdb_option == 1 ){
	for my $element ( @ARGV ) {

	    # Getting file name information from a
	    # shell script.
	    my @files = `bash scripts/directory_processing.sh $element PDB`;
	    for my $filename ( @files ) {

		chomp( $filename );
		my $output = `bash scripts/one_file_processing.sh $element/$filename PDB`;
		my @output_arr = split('\|', $output);
		
		for my $i (0 .. $#output_arr) {
		    if( $output_arr[$i] eq "" ) {
			$output_arr[$i] = "N\/A";
		    }
		}
		
		my $year = 0;
		if ( $output_arr[1] =~ /^\d{2}$/ ) {
			if( $output_arr[1] ne "N\/A" and int($output_arr[1]) > int($year_part) ) {
	    			$year = "19" . $output_arr[1];
			}
			else {
	    			$year = "20" . $output_arr[1];
			}
		}

		print "$output_arr[0]\t$year\t$output_arr[2]",
		      "\t$output_arr[3]\t$output_arr[4]\n";
	    }	
	}
    }
    elsif( $cif_option == 1 ){
	for my $element ( @ARGV ) {

            # Getting file name information from a
	    # shell script.
            my @files = `bash scripts/directory_processing.sh $element CIF`;
            for my $filename ( @files ) {
		
                chomp( $filename );
                my $output = `bash scripts/one_file_processing.sh $element/$filename CIF`;
                my @output_arr = split('\|', $output);

		for my $i (0 .. $#output_arr) {
		    if( $output_arr[$i] eq "." or $output_arr[$i] eq "?" ) {
			$output_arr[$i] = "N\/A";
		    }
		}
		
                print "$output_arr[0]\t$output_arr[1]\t$output_arr[2]",
                      "\t$output_arr[3]\t$output_arr[4]\n";
            }
        }	
    }
}
