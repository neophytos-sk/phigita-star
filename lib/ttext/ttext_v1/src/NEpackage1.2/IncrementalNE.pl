#!/usr/bin/perl


# this version accepts bracket-tagged input

if($#ARGV != 1 )
  {
    die "Usage: IncrementalNE.pl <inputfile> <iterations (eg. 2)>";
  }


$dir="/home/roth/metzler1/ne/NEpackage1.1";
$newinputfile = "$dir/tmp/newinput.tmp$$";
$sentbound="$dir/tmp/sentbound.tmp$$";
$wordsplit = "$dir/tmp/wordsplit.tmp$$";
$columninput = "$dir/tmp/columninput.tmp$$";
$FEX = "$dir/fex/fex";
$SNOW = "$dir/snow/snow";

$listoutput = "$dir/tmp/listoutput.tmp$$";
$listcolumn = "$dir/tmp/listcolumn.tmp$$";
$LISTNE = "$dir/newlistne/UpperCaseNEAll.pl";
$LISTCOLIFY = "$dir/newlistne/makelistscolumn.pl";

$input = $ARGV[0];

#convert bracket tags
open(IN, "$input") || die "couldnt open input file";
open(OUT, ">$newinputfile") || die "couldnt create file";
$newinput = "";
while($line = <IN>)
{
  $line =~ s/\[PER([^\]]+)\]/xNESTARTxPER$1xNEENDx/g;
  $line =~ s/\[LOC([^\]]+)\]/xNESTARTxLOC$1xNEENDx/g;
  $line =~ s/\[ORG([^\]]+)\]/xNESTARTxORG$1xNEENDx/g;
  $line =~ s/\[MISC([^\]]+)\]/xNESTARTxMISC$1xNEENDx/g;
  $newinput .= $line;
}	
print OUT $newinput;
close(IN);
close(OUT);

#preprocess and put into table format
`$dir/sentence-boundary/sentence-boundary.pl -d $dir/sentence-boundary/HONORIFICS -i $newinputfile -o - > $sentbound`;
`$dir/wordsplitter/word-splitter.pl $sentbound > $wordsplit`;

# NEW STEP in V1.1 : Add results from list-bases NE to column 2
`$LISTNE $wordsplit > $listoutput`;
`$LISTCOLIFY $listoutput > $listcolumn`;

#create vanilla column format with tags (no pos, no chunking, etc.. since NE doesnt use it)
open(SOURCE2, "$wordsplit") || die "couldn't load wordsplit data";
open(COLUMN, ">$columninput") || die "couldn't create column file";
open(LIST, "$listcolumn") || die "couldnt open list file";

$col="";
$numwords=0;
while($line = <SOURCE2>)
  {

    #escape the slash
    $line =~ s/^\//\\\//g;
    $line =~ s/[^\\]\// \\\//g;
   @wordarr = split(/\s+/, $line);
    $wordcounter=0;
    $inNE=0;
    $prefix="";

    #    foreach $word(@wordarr)
    for($i=0;$i<=$#wordarr;$i++) #inNE: 0=outside 1=begin 2=end 3=inside
      {
	$listlabel = <LIST>;
	chomp($listlabel);

       if($inNE==0) {$label="O";}
	if($wordarr[$i] =~ /^xNESTARTx/)
 	  {
	    $wordarr[$i] =~ s/^xNESTARTx//g;
	    $label = $wordarr[$i];
	    $inNE=1;
	  }
	elsif($wordarr[$i] eq "xNEENDx")
	  {
	    $inNE=2;
	    $label="O";
	  }
	else
	  {
	    $prefix="";
	    if($inNE==0) {$prefix="";}
	    if($inNE==1 && ($wordarr[$i+1] ne "xNEENDx")) {$prefix="B-";}
	    elsif($inNE==1 && ($wordarr[$i+1] eq "xNEENDx")) {$prefix="U-";}
	    if($inNE==2) {$prefix="";}
	    if($inNE==3) {$prefix="I-";}
	    if($inNE==3 && ($wordarr[$i+1] eq "xNEENDx")) {$prefix="L-";}
	
	    $word = $wordarr[$i];
	    $col .= "$prefix$label\t$listlabel\t$wordcounter\tO\tO\t$word\tx\tx\t0\n";
	    $wordcounter++;
	    $numwords++;
	    if($inNE==1) {$inNE=3;}
	  }
      }
    $col .= "\n";
  }

$col =~ s/\n\n+$/\n/g;
$col =~ s/\n\n\n+/\n\n/g;
$total = "";
for($i=0;$i<$ARGV[1];$i++)
  {
    $total .= $col;
  }
print COLUMN $total;
close(COLUMN);

`$FEX -p localwideconll.scr BILOU.lex $columninput $columninput.ex`;

#check if fex worked

$numWords = `cat $columninput |grep 'x' |wc -l`;
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

`$SNOW -test -i + -F BILOUtrain.net -I $columninput.ex`;

unlink( $newinputfile, $sentbound, $wordsplit, $columninput, "$columninput.ex", $listoutput, $listcolumn);
