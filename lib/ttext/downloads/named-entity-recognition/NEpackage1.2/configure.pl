#!/usr/bin/perl

#Mark Sammons, 11/23/04

# usage: ./configure.pl basic
#   or   ./configure.pl perl perlLibraryPath

#This script sets paths in key scripts, and if invoked with the
#'perl' option, will read in a path for the perl binaries and 
#will set the paths in all perl scripts to use that path. 

#in each case, the script to be modified is backed up first into
# <filename>.bak

use strict;

my $installType = $ARGV[0];

print "##in configure.pl...\n";


if($installType eq "basic")
{
  print "## setting paths...\n";

  #set paths...
    
  my $currentPath = `pwd`;
  chomp($currentPath);
  
  &changeFile("NEClassifier.pl", '\\$dir=', '$dir="'.$currentPath.'";'); 
  &changeFile('cscl/DoInfrBILOUGeneral2.pl', '\\$dir=', '$dir="'.$currentPath.'";');
  &changeFile('IncrementalNE.pl', '$dir=', '\\$dir=', '$dir="'.$currentPath.'";');
  &changeFile('newlistne/UpperCaseNEAll.pl', '\\$dir=', '$dir="'.$currentPath.'";');
  &changeFile('newlistne/UpperCaseNEAll.server.pl', '\\$dir=', '$dir="'.$currentPath.'";');
  &changeFile('server/startservers.sh', 'BASEDIR=', "BASEDIR=$currentPath");
  &changeFile('server/NEClassifier-server.pl', '\\$dir=', '$dir="'.$currentPath.'";');



} #end if ("basic")

elsif($installType eq "perl")
{
  shift @ARGV;
  my $perlPath = shift @ARGV;
  print "Perl library path: $perlPath\n";

  my @fileList = ("NEClassifier.pl", 
		  "IncrementalNE.pl",
		  "newlistne/UpperCaseNEAll.pl",
		  "newlistne/UpperCaseNEAll.server.pl",
		  "server/NEClassifier-server.pl",
		  "fex/fexClient.pl",
		  "fex/tools/acronyms.pl",
		  "fex/tools/BILOU2nNCm.pl",
		  "fex/tools/BIO2BILOU.pl",
		  "fex/tools/icapSequence.pl",
		  "cscl/DoInfrBILOUGeneral2.pl",
		  "sentence-boundary/sentence-boundary.pl",
		  "wordsplitter/counter.pl",
		  "wordsplitter/word-splitter.pl"
		  
		 );

  foreach my $perlFile (@fileList)
  {
    &changeFile($perlFile, '#!', '#!'.$perlPath);
  }
}
else 
{
  print "option not recognized.\n";
}


#changeFile expects the filename, a unique string identifying
#the change location, and the string to write to that location

sub changeFile
{
  print "##in changeFile...\n";
  my ($file, $key, $string) = @_;

print "file is $file, key is $key, string is $string...\n";

  `cp $file $file.bak`;
  `mv $file $file.tmp`;
  
  print "##backed up file, created temporary copy...\n";


  open (IN, "<$file.tmp")
    or die "Can't open file $file.tmp for input: $!\n";
  open (OUT, ">$file") 
    or die "Can't open $file for output: $!\n";
  
  while(<IN>) 
  {      
    if(/^$key/)
    {
      print "##found key $key; replacing with $string...\n";
      print OUT "$string\n";
#      print "$string\n";
    }
    else
    {
      print OUT $_;
#      print $_;
    }
      
  }

  close IN or die "Can't close $file.tmp: $!\n";
  close OUT or die "Can't close $file: $!\n";
  `rm $file.tmp`;

#reset permissions...
  `chmod u+rwx $file`;

}
