#!/usr/bin/perl

use IO::Socket;

my $DEBUG_NE = 1;

$dir="/home/nkd/my/experiments/NEpackage1.2";

$sentbound="$dir/tmp/sentbound.tmp$$";
$wordsplit = "$dir/tmp/wordsplit.tmp$$";
$columninput = "$dir/tmp/columninput.tmp$$";
$classout = "$dir/tmp/classout.tmp$$";
$finalcolumn = "$dir/tmp/finalcolumn.tmp$$";
$FEX = "$dir/fex/fex";
$INFERENCEDIR = "$dir/cscl";
$SNOW = "$dir/snow/snow";
$LISTNE = "$dir/newlistne/UpperCaseNEAll.pl";
$LISTCOLIFY = "$dir/newlistne/makelistscolumn.pl";
$TARGETLEXICON = "$dir/labelsFromLexicon.txt";
#listne related files
$listoutput = "$dir/tmp/listoutput.tmp$$";
$listcolumn = "$dir/tmp/listcolumn.tmp$$";
$colone = "$dir/tmp/colone.tmp$$";
$colrest = "$dir/tmp/colrest.tmp$$";


#print "Processed stuff: **$ARGV[0]***\n";
$input = $ARGV[0];
#preprocess and put into table format
`$dir/sentence-boundary/sentence-boundary.pl -d $dir/sentence-boundary/HONORIFICS -i $input -o - | perl -ne 'if(\$_ =~ /\\S+/) {print \$_;}' >  $sentbound`;
`$dir/wordsplitter/word-splitter.pl $sentbound > $wordsplit`;

if(1 == $DEBUG_NE) {

  print "## creating col format text... writing to $columninput...\n";
}

#create vanilla column format (no pos, no chunking, etc.. since NE doesnt use it)
open(SOURCE2, "$wordsplit") || die "couldn't load wordsplit data";
open(COLUMN, ">$columninput") || die "couldn't create column file";
$col="";
$numwords=0;
while($line = <SOURCE2>)
  {
    #ignore leading newlines
    if($numwords==0 && $line =~ /^\s*\n$/)
    {next;}
    #escape the slash
    $line =~ s/^\//\\\//g;
    $line =~ s/[^\\]\// \\\//g;
   
    #convert word splitter's LBR/RBR back to (/)
    $line =~ s/\-LBR\-/\(/g;
    $line =~ s/\-RBR\-/\)/g;

    @wordarr = split(/\s+/, $line);
    $wordcounter=0;
    foreach $word(@wordarr)
      {
	$col .= "O\t0\t$wordcounter\tO\tO\t$word\tx\tx\t0\n";
	$wordcounter++;
	$numwords++;
      }
    $col .= "\n";
  }
$col =~ s/\n*$//g;
$col =~ s/\n\n\n+/\n\n/g;
print COLUMN $col;
close(COLUMN);

if(1 == $DEBUG_NE) {

  print "## adding list-based NE... writing to $listoutput...\n";
}


# NEW STEP in V1.1 : Add results from list-bases NE to column 2
`$LISTNE $wordsplit > $listoutput`;
`$LISTCOLIFY $listoutput > $listcolumn`;
`cut -f1 $columninput > $colone`;
`cut -f3- $columninput > $colrest`;
`rm $columninput`;
`paste $colone $listcolumn $colrest > $columninput`; 

if(1 == $DEBUG_NE) {

  print "## creating col format text... writing to $columninput...\n";
  print "## calling FEX...\n";
}


# classify and infer...
`$FEX -p localwideconll.scr BILOU.lex $columninput $columninput.ex`;

#check if fex worked

if(1 == $DEBUG_NE) {

  print "## checking if fex worked...\n";
}


$numWords = `cat $columninput |grep '^O' |wc -l`;
$numWords =~ /\s+[0-9]+\s+/;
$numWords = $&;
$numWords =~ s/\s+//g;

$numExamples = `wc -l $columninput.ex`;
$numExamples =~ /\s+[0-9]+\s+/;
$numExamples = $&;
$numExamples =~ s/\s+//g;


if($numWords != $numExamples) # fex screwed up...
  {
    print "ERROR:Feature Extraction error. Request terminated.\n";
    print "$numwords $numExamples";
    exit 0;
  }

if(1 == $DEBUG_NE) {

  print "## calling SNOW, writing to $classout...\n";
}

# call snow to classify examples
`$SNOW -test -F BILOUtrain.net -I $columninput.ex -o allactivations > $classout`;

#die "done.";

if(1 == $DEBUG_NE) {

  print "## calling INFERENCE step, writing to $finalcolumn...\n";
}


`$INFERENCEDIR/DoInfrBILOUGeneral2.pl $columninput $classout $TARGETLEXICON $finalcolumn PER LOC ORG MISC`;

open(FINALCOL, "$finalcolumn") ||die "could not open $finalcolumn";

#print "output...\n";
seek(SOURCE2,0,0);
while($line = <SOURCE2>)
  {
    #print "in output..\n";
    @wordarr = split(/\s+/, $line);
    $inNE=0;
    foreach $word(@wordarr)
      {
	#add brackets
	if($word eq "-LBR-") { $word = "(";}
	if($word eq "-RBR-") { $word = ")";}
	$label = <FINALCOL>;
	if($label !~ /[A-Z]/) {$label = <FINALCOL>;}
	if($word =~ /^\-[LR]BR\-$/) {$label="O";}
	if($label =~ /^[BU]/)
	  {
	    if($label =~ /^B/) 
	      {
		$inNE=1;
		$label =~ /[A-Z][A-Z]+/;
		print "[$& $word ";
	      }
	    else
	      {
		$inNE=0;
		$label =~ /[A-Z][A-Z]+/;
		print "[$& $word ] ";
	      }
	  }
	elsif($label =~ /^L/)
	  {
	    print "$word ] ";
	    $inNE=0;
	  }
	elsif( ($label =~ /^O/) && ($inNE==1))
	  {
	    print "] $word ";$inNE=0;
	  }
	else { print "$word ";}
	
#	print "$word\t$label";
      }
   print "\n";
  }
print "\n";
#$outp = `cat $finalcolumn`;

if(1 == $DEBUG_NE) {

  print "## finished.  Cleaning up...\n";
}


unlink($sentbound, $wordsplit, $classout, $finalcolumn, $columninput, "$columninput.ex", $listoutput, $listcolumn, $colone, $colrest);
