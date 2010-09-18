#!/usr/bin/perl

# Name: RightLogLite
# RightLog light edition
# Author: Sébastien Roux
# Mailto: roux.sebastien@gmail.com
# License: GPLv3, see attached license
# Version: 1.1 - september 2010

# The MIT License
# Copyright (c) 2010 Sébastien Roux
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# Modules include
use Getopt::Std;
use File::Find;

#use Strict;

# Set argument parameters
# -i input,	-o output,		-d date,	-c categories
# -h help,	-s separator,	-f filter,	-t header
# -p path
getopts( "i:o:d:chs:f:tp:", \%opts ) or DisplayUsage();

# Verify arguments
DisplayHelp();
TestInputFileArg();
TestFilterArg();
TestDateFormatArg();
TestSeparatorArg();

# File output arg (-o)
if ( $opts{o} ) {
	open( OUTPUT, ">$opts{o}" )
	  or die print "Error: could not open output file:\n$opts{o}\n";

	# Header arg (-t)
	if ( $opts{t} ) {
		print OUTPUT SetHeader();
	}
}

# StdOut arg
else {

	# Header arg (-t)
	if ( $opts{t} ) {
		print SetHeader();
	}
}

# For each log file
foreach $i (@i) {

	# Open logfile
	open( LOGFILE, "$i" )
	  or die print "Error: '$i' not found in specified path\n";

	while (<LOGFILE>) {

		# Skip blank lines
		next unless ( !/^(\s)*$/ );

		# Advanced delimiter (not "[")
		if (/^(Mon|Tue|Wed|Thu|Fri|Sat|Sun)/i) {
			chomp;
			$Line = $_;    # Current line
			EssDelimitedLog();
		}

		# Default delimiter ("[")
		elsif (/^\[(Mon|Tue|Wed|Thu|Fri|Sat|Sun)/i) {
			chomp;
			$Line  = $_;           # Current line
			$Line2 = <LOGFILE>;    # Read next line
			chomp($Line2);
			EssClassicLog();
		}

		# Other case (description)
		else {
			chomp;
			$Line = $_;            # Current line
			Other();
		}

		# File ouput arg (-o) or
		# Excel output arg (-x) or
		# Query ouput arg (-q)
		if ( $opts{o} ) {

			# Filtering
			unless ( $Line !~ /.*$f.*$/ ) {
				print OUTPUT $Line . "\n";
			}
		}

		# StdOut output
		else {

			# Filtering
			unless ( $Line !~ /.*$f.*$/ ) {
				print $Line. "\n";
			}
		}
	}
	close(LOGFILE);
}
exit;

#------------------------------------------------------------
# FUNCTIONS
#------------------------------------------------------------
# Essbase v.5, 6, 7, 9, 11 classic delimiters ([, ])
sub EssClassicLog {

	$Line =~ s/^\[//;                # Replace opening bracket ([) with nothing
	$Line =~ s/\]/$s/;               # Replace closing bracket (])
	$Line =~ s/\ /$s/ for 1 .. 4;    # Replace 4 1st whitespace
	$Line =~ s/\//$s/gm;             # Replace slash delimiters (/)

	ChangeDateFormat();

	# Categories arg (-c)
	if ( $opts{c} ) { AddMessageCategory(); }
	else {
		$Line =~ s/[()]/$s/ for 1 .. 2;    # Replace bracket delimiters ((,))
	}

	unless ( $Line2 =~ /^(\s)*$/ ) {       # Join with next line if not empty
		$Line = $Line . $Line2;
	}

	$Line =~ s/ +/ /gm;        # Replacing multi-space by single space
	$Line =~ s/[ \t]+$//gm;    # Deleting eol tab/space
}

#--------------------------------
# Essbase v. 6, 7, 9, 11 advanced delimiters
# DELIMITEDMSG setting in config file with parameter: *, :, &, #, ~
sub EssDelimitedLog {

	my @f = split /[~^*&:]/, $Line;    # Split according to defined pattern
	                                   # and fill a list
	$lastf = scalar(@f);
	$Line =
	    join( $s, @f[ 0 .. 3 ] ) . ':'
	  . join( ':', @f[ 4 .. 5 ] )
	  . $s
	  . join( $s,  @f[ 6 .. 11 ] )
	  . join( '',  @f[ 12 .. 13 ] ) . ' '
	  . join( ' ', @f[ 14 .. $lastf ] );

	ChangeDateFormat();

	# Categories arg (-c)
	if ( $opts{c} ) { AddMessageCategory(); }
	else {
		$Line =~ s/[()]/$s/ for 1 .. 2;    # Replace bracket delimiters ((,))
	}

	$Line =~ s/ +/ /gm;        # Replacing multi-space by single space
	$Line =~ s/[ \t]+$//gm;    # Deleting eol tab/space
}

#--------------------------------
sub Other {

	# Date arg (-d)
	if ( $opts{d} ) {

		# Categories arg (-c)
		if ( $opts{c} ) {
			$Line = "$s$s$s$s$s$s$s$s$s$Line";
		}
		else {
			$Line = "$s$s$s$s$s$s$s$s$Line";
		}
	}
	else {
		if ( $opts{c} ) {
			$Line = "$s$s$s$s$s$s$s$s$s$s$s$s$Line";
		}
		else {
			$Line = "$s$s$s$s$s$s$s$s$s$s$s$Line";
		}
	}
	$Line =~ s/ +/ /gm;        # Replacing multi-space by single space
	$Line =~ s/\t//gm;         # Deleting tab
	$Line =~ s/[ \t]+$//gm;    # Deleting eol tab/space
}

#--------------------------------
sub DisplayHelp {

	# Help arg (-h) or
	# no arg
	if ( $opts{h} || @ARGV > 0 ) {
		print "DESCRIPTION:\n"
		  . "RightLogLite : parse ANY Essbase (v.5-v.11) server and application logs.\n"
		  . "Generate a full custom delimited spreadsheet or database ready output for enhanced analysis.\n"
		  . "Options available: advanced date formatting, headers insertion detailed message categories, ouput filtering, custom delimiter, stdout or file output\n\n";
		print "VERSION:\n" . "v.1.1 - september 2010\n\n";
		print "AUTHOR:\n"
		  . "Written by Sebastien Roux <roux.sebastien\@gmail.com>\n\n";
		print "LICENSE:\n" . "MIT License\n\n";
		print "NOTES:\n"
		  . "Use at your own risk!\n"
		  . "You will be solely responsible for any damage\n"
		  . "to your computer system or loss of data\n"
		  . "that may result from the download\n"
		  . "or the use of the following application/script.\n\n";
		DisplayUsage();
	}
}

#--------------------------------
sub DisplayUsage {

	print "USAGE: EssbaseRightLog -i <logfile(s)>|-p <dir>\n"
	  . "[-o <outputfile>, -c, -d <arg>, -t, -s <arg>, -f <arg>, -h]\n\n";
	print " -i specify log(s), args: <logfile1[;logfile2;...]>\n";
	print " -p specify logs directory, args: <dir1[;dir2;...]>\n";
	print " -o specify output file, arg: <outputfile>\n";
	print " -c specify message categories\n";
	print " -d specify date format, arg: <ISO|EUR|US>\n";
	print " -t specify headers on top\n";
	print " -s specify separator, arg: <*>\n";
	print " -f specify filter (case sensitive), arg: <regex>\n";
	print " -h display usage\n";
	exit;
}

#--------------------------------
sub TestInputFileArg {

	# Log files specified one by one
	if ( $opts{i} ) {
		@i = split /;/, $opts{i};

		foreach $i (@i) {
			if ( !-e $i ) {
				print "Error: input file '$i' does not exists!\n";
				DisplayUsage();
			}
		}
	}

# Log directory specified one by one, each directory will be scanned for .LOG files
	elsif ( $opts{p} ) {
		@p = split /;/, $opts{p};

		foreach $p (@p) {
			find(
				sub {
					if ( -f && /.LOG?/ ) { push @i, $File::Find::name; }
				},
				$p
			);
		}
	}
	else {
		DisplayUsage();
	}
}

#--------------------------------
sub TestDateFormatArg {

	# Date arg (-d)
	if (   $opts{d}
		&& ( uc( $opts{d} ) ne "ISO" )
		&& ( uc( $opts{d} ) ne "EUR" )
		&& ( uc( $opts{d} ) ne "US" ) )
	{
		print
		  "Error: '$opts{d}' is not a valid argument for date format (-d)!\n";
		DisplayUsage();
	}
}

#--------------------------------
# Add category for message code
sub AddMessageCategory {

	my $MsgCode;
	my $MsgType;

	if ( $Line =~ m/\d{7,7}/ ) {
		$MsgCode = $&;

		if ( $MsgCode ge 1001000 && $MsgCode le 1001999 ) {
			$MsgType = "Report writer";
		}
		elsif ( $MsgCode ge 1002000 && $MsgCode le 1002999 ) {
			$MsgType = "General server";
		}
		elsif ( $MsgCode ge 1003000 && $MsgCode le 1003999 ) {
			$MsgType = "Data load";
		}
		elsif ( $MsgCode ge 1004000 && $MsgCode le 1004999 ) {
			$MsgType = "General server";
		}
		elsif ( $MsgCode ge 1005000 && $MsgCode le 1005999 ) {
			$MsgType = "Backup, export, or validate";
		}
		elsif ( $MsgCode ge 1006000 && $MsgCode le 1006999 ) {
			$MsgType = "Data cache";
		}
		elsif ( $MsgCode ge 1007000 && $MsgCode le 1007999 ) {
			$MsgType = "Outline restructure";
		}
		elsif ( $MsgCode ge 1008000 && $MsgCode le 1008999 ) {
			$MsgType = "System calls, portable layer, ASD, or agent";
		}
		elsif ( $MsgCode ge 1009000 && $MsgCode le 1009999 ) {
			$MsgType = "Restoring ASCII data";
		}
		elsif ( $MsgCode ge 1010000 && $MsgCode le 1010999 ) {
			$MsgType = "Internal - block numbering";
		}
		elsif ( $MsgCode ge 1011000 && $MsgCode le 1011999 ) {
			$MsgType = "Internal - utilities";
		}
		elsif ( $MsgCode ge 1012000 && $MsgCode le 1012999 ) {
			$MsgType = "Calculator";
		}
		elsif ( $MsgCode ge 1013000 && $MsgCode le 1013999 ) {
			$MsgType = "Requestor";
		}
		elsif ( $MsgCode ge 1014000 && $MsgCode le 1014999 ) {
			$MsgType = "Lock manager";
		}
		elsif ( $MsgCode ge 1015000 && $MsgCode le 1015999 ) {
			$MsgType = "Alias table";
		}
		elsif ( $MsgCode ge 1016000 && $MsgCode le 1016999 ) {
			$MsgType = "Report writer";
		}
		elsif ( $MsgCode ge 1017000 && $MsgCode le 1017999 ) {
			$MsgType = "Currency";
		}
		elsif ( $MsgCode ge 1018000 && $MsgCode le 1018999 ) {
			$MsgType = "Not currently used";
		}
		elsif ( $MsgCode ge 1019000 && $MsgCode le 1019999 ) {
			$MsgType = "Database artifacts";
		}
		elsif ( $MsgCode ge 1020000 && $MsgCode le 1020999 ) {
			$MsgType = "Spreadsheet extractor";
		}
		elsif ( $MsgCode ge 1021000 && $MsgCode le 1021999 ) {
			$MsgType = "Essbase SQL interface";
		}
		elsif ( $MsgCode ge 1022000 && $MsgCode le 1022999 ) {
			$MsgType = "Security";
		}
		elsif ( $MsgCode ge 1023000 && $MsgCode le 1023999 ) {
			$MsgType = "Partitioning";
		}
		elsif ( $MsgCode ge 1024000 && $MsgCode le 1024999 ) {
			$MsgType = "Query extractor";
		}
		elsif ( $MsgCode ge 1030000 && $MsgCode le 1030999 ) {
			$MsgType = "API";
		}
		elsif ( $MsgCode ge 1040000 && $MsgCode le 1040999 ) {
			$MsgType = "General network";
		}
		elsif ( $MsgCode ge 1041000 && $MsgCode le 1041999 ) {
			$MsgType = "Network - Named Pipes";
		}
		elsif ( $MsgCode ge 1042000 && $MsgCode le 1042999 ) {
			$MsgType = "Network - TCP";
		}
		elsif ( $MsgCode ge 1043000 && $MsgCode le 1049999 ) {
			$MsgType = "Not currently used";
		}
		elsif ( $MsgCode ge 1050000 && $MsgCode le 1055999 ) {
			$MsgType = "Agent";
		}
		elsif ( $MsgCode ge 1056000 && $MsgCode le 1059999 ) {
			$MsgType = "Not currently used";
		}
		elsif ( $MsgCode ge 1060000 && $MsgCode le 1060999 ) {
			$MsgType = "Outline API";
		}
		elsif ( $MsgCode ge 1061000 && $MsgCode le 1069999 ) {
			$MsgType = "Not currently used";
		}
		elsif ( $MsgCode ge 1070000 && $MsgCode le 1070999 ) {
			$MsgType = "Index manager";
		}
		elsif ( $MsgCode ge 1071000 && $MsgCode le 1079999 ) {
			$MsgType = "Not currently used";
		}
		elsif ( $MsgCode ge 1080000 && $MsgCode le 1080099 ) {
			$MsgType = "Transaction manager";
		}
		elsif ( $MsgCode ge 1081000 && $MsgCode le 1089999 ) {
			$MsgType = "Not currently used";
		}
		elsif ( $MsgCode ge 1090000 && $MsgCode le 1099999 ) {
			$MsgType = "Rules file processing";
		}
		elsif ( $MsgCode ge 1010000 && $MsgCode le 1019999 ) {
			$MsgType = "Not currently used";
		}
		elsif ( $MsgCode ge 1100000 && $MsgCode le 1100999 ) {
			$MsgType = "Not currently used";
		}
		elsif ( $MsgCode ge 1110000 && $MsgCode le 1119999 ) {
			$MsgType = "Web Analysis";
		}
		elsif ( $MsgCode ge 1120000 && $MsgCode le 1129999 ) {
			$MsgType = "Grid API";
		}
		elsif ( $MsgCode ge 1130000 && $MsgCode le 1139999 ) {
			$MsgType = "Miscellaneous";
		}
		elsif ( $MsgCode ge 1140000 && $MsgCode le 1149999 ) {
			$MsgType = "Linked Reporting Objects";
		}
		elsif ( $MsgCode ge 1150000 && $MsgCode le 1159999 ) {
			$MsgType = "Outline synchronization";
		}
		elsif ( $MsgCode ge 1160000 && $MsgCode le 1169999 ) {
			$MsgType = "Outline change records";
		}
		elsif ( $MsgCode ge 1170000 && $MsgCode le 1179999 ) {
			$MsgType = "Attributes";
		}
		elsif ( $MsgCode ge 1180000 && $MsgCode le 1189999 ) {
			$MsgType = "Showcase";
		}
		elsif ( $MsgCode ge 1190000 && $MsgCode le 1199999 ) {
			$MsgType = "Enterprise Integration Services";
		}
		elsif ( $MsgCode ge 1200000 && $MsgCode le 1200999 ) {
			$MsgType = "Calculator framework";
		}
		else { $MsgType = "Other"; }
		$Line =~ s/\(\d{7,7}\)/$s$MsgCode$s$MsgType$s/;
	}
}

#--------------------------------
sub ChangeDateFormat {

	ChangeMonthString();

	my @l = split /[$s]/, $Line;
	my $last;

	# Set date format to ISO 8601 extended style (YYYY-MM-DD)
	if ( uc( $opts{d} ) eq "ISO" ) {
		$last = scalar(@l);
		$Line =
		    @l[ 4 .. 4 ] . '-'
		  . @l[ 1 .. 1 ] . '-'
		  . @l[ 2 .. 2 ]
		  . $s
		  . join( $s, @l[ 3 .. 3 ] )
		  . $s
		  . join( $s, @l[ 5 .. $last - 1 ] );
	}

	# Set date format to US style (MM/DD/YYYY)
	elsif ( uc( $opts{d} ) eq "US" ) {
		$last = scalar(@l);
		$Line =
		    @l[ 1 .. 1 ] . '/'
		  . @l[ 2 .. 2 ] . '/'
		  . @l[ 4 .. 4 ]
		  . $s
		  . join( $s, @l[ 3 .. 3 ] )
		  . $s
		  . join( $s, @l[ 5 .. $last - 1 ] );
	}

	# Set date format to European style (DD/MM/YYYY)
	elsif ( uc( $opts{d} ) eq "EUR" ) {
		$last = scalar(@l);
		$Line =
		    @l[ 2 .. 2 ] . '/'
		  . @l[ 1 .. 1 ] . '/'
		  . @l[ 4 .. 4 ]
		  . $s
		  . join( $s, @l[ 3 .. 3 ] )
		  . $s
		  . join( $s, @l[ 5 .. $last - 1 ] );
	}
}

#--------------------------------
# Replace month label by month number
sub ChangeMonthString {

	my $MonthIndex;

	if ( $Line =~ m/(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)/ ) {
		if    ( lc($&) eq "jan" ) { $MonthIndex = "01"; }
		elsif ( lc($&) eq "feb" ) { $MonthIndex = "02"; }
		elsif ( lc($&) eq "mar" ) { $MonthIndex = "03"; }
		elsif ( lc($&) eq "apr" ) { $MonthIndex = "04"; }
		elsif ( lc($&) eq "may" ) { $MonthIndex = "05"; }
		elsif ( lc($&) eq "jun" ) { $MonthIndex = "06"; }
		elsif ( lc($&) eq "jul" ) { $MonthIndex = "07"; }
		elsif ( lc($&) eq "aug" ) { $MonthIndex = "08"; }
		elsif ( lc($&) eq "sep" ) { $MonthIndex = "09"; }
		elsif ( lc($&) eq "oct" ) { $MonthIndex = "10"; }
		elsif ( lc($&) eq "nov" ) { $MonthIndex = "11"; }
		elsif ( lc($&) eq "dec" ) { $MonthIndex = "12"; }
		$Line =~ s/$&/$MonthIndex/;
	}
}

#--------------------------------
# Set default separator (|) if separator arg not specified
sub TestSeparatorArg {

	my $defaultseparator = "	";

	# Separator arg (-s)
	if   ( not( $opts{s} ) ) { $s = $defaultseparator; }
	else                     { $s = $opts{s}; }

	return $s;
}

#--------------------------------
# Set default filter to empty if filter arg not specified
sub TestFilterArg {

	my $defaultfilter = "";

	# Filter arg (-f)
	if ( not( $opts{f} ) ) {
		$f = $defaultfilter;
	}
	else {
		$f = $opts{f};
	}

	return $f;
}

#--------------------------------
sub SetHeader {

	my $Header;

	# Date arg (-d)
	if ( $opts{d} ) {

		# Categories arg (-c)
		if ( $opts{c} ) {
			$Header =
			    "date" 
			  . $s . "time" 
			  . $s 
			  . "server" 
			  . $s
			  . "application"
			  . $s
			  . "database"
			  . $s . "user"
			  . $s
			  . "msglevel"
			  . $s
			  . "msgcode"
			  . $s
			  . "msgcat"
			  . $s
			  . "description\n";
		}

		# No categories
		else {
			$Header =
			    "date" 
			  . $s . "time" 
			  . $s 
			  . "server" 
			  . $s
			  . "application"
			  . $s
			  . "database"
			  . $s . "user"
			  . $s
			  . "msglevel"
			  . $s
			  . "msgcode"
			  . $s
			  . "description\n";
		}
	}

	# Default date format
	else {

		# Categories
		if ( $opts{c} ) {
			$Header =
			    "day" 
			  . $s . "month" 
			  . $s 
			  . "daynum" 
			  . $s . "time" 
			  . $s . "year"
			  . $s
			  . "server"
			  . $s
			  . "application"
			  . $s
			  . "database"
			  . $s . "user"
			  . $s
			  . "msglevel"
			  . $s
			  . "msgcode"
			  . $s
			  . "msgcat"
			  . $s
			  . "description\n";
		}

		# No categories
		else {
			$Header =
			    "day" 
			  . $s . "month" 
			  . $s 
			  . "daynum" 
			  . $s . "time" 
			  . $s . "year"
			  . $s
			  . "server"
			  . $s
			  . "application"
			  . $s
			  . "database"
			  . $s . "user"
			  . $s
			  . "msglevel"
			  . $s
			  . "msgcode"
			  . $s
			  . "description\n";
		}
	}
	return $Header;
}
__END__
