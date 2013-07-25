#!/usr/bin/perl


if (@ARGV < 1)
{
  print "This script identifies longest subsequences of initcap word from a document in column format\n";
  print "usage: icapSequence.pl corpus > output\n";
  exit;
}

open (corpus, "$ARGV[0]") || die "Can't open file.\n";

#print "$ARGV[0]\n";

while($done==0)
  {
    $line = <corpus>;
    #print "$line";
    #this should be the -DOCSTART- line
    if(!($line =~ /DOCSTART/)) { die "Missed a DOCSTART.\n";}

    # get a document
    $done=0;
    @DOC = ();
    $i=0;$word="";
    while(!($word =~ /DOCSTART/) && $done==0)
      {
        $pos = tell(corpus);
	if($line = <corpus>)
	  {
	    ($x, $x, $x, $x, $x, $word, $x, $zoneindex, $rest) = split(/\s+/, $line);
	    if($zoneindex =~ /TXT/)
	      {
		$DOC[$i] = $word;
		($bla , $docindex) = split(/\//, $zoneindex);
		$i++;
	      }
	  }
	else  { $done=1; }
      }

    #print "$zoneindex\n";

    #record all initcap sequences
    @SEQS = ();
    for($x=0 ; $x<=$#DOC ; $x++)
      {
	$seq = "";
	$word = $DOC[$x];
	
	#$first = 1;
	while($word =~ /^[A-Z][^A-Z]+/) # initcap found
	  {
	   # print "before add: $seq\n";
	   # print "after add: $seq\n";
	   # if($first==1) { $seq = $word; }
	    $seq =  $seq . "_" . $word;
	    #print "word: $word ";
	    $x++;
	    $word = $DOC[$x];
	    $first = 0;
	  }
	$seq = $seq . "_";
	if( $seq =~ /[A-Z].*_[A-Z].*/) { push @SEQS, $seq; }#print "seq: $seq\n"; }
      }


    for($x=0 ; $x<=$#SEQS ; $x++)
      {
	$SEQS[$x] =~ /[A-Z].*_[A-Z]*.*_[A-Z].*/;
	@WORDS = split(/_/, $&);
	for($y=0 ; $y<=$#WORDS ; $y++)
	  {
	    $found=0;
	   # print "$WORDS[$y]\n";
	    for($z=$#WORDS; ($z>=0 && $found==0) ; $z--)
	      {
		$subseq = "";
		#$subseq = $WORDS[$y];
		for($a = $y; $a<= $z; $a++)
		  {
		    $subseq = $subseq . "_" . $WORDS[$a];
		  }
		$subseq = $subseq . "_";
		
		# now try to find the subsequence
		if($z>$y)
		  {
		    for($a = 0; ($a<=$#SEQS  && $found==0); $a++)
		      {
			if( ($SEQS[$a] =~ /$subseq/) && ($a != $x) )
			  {
			    $found=1;
			    $subseq =~ s/_(.+)_/\1/g;
			    #$subseq =~ s/_/ /g;
			    push @OUTPUT,  "$ docindex $subseq\n";
			  }
		      }
		  }
	      }
	    if($found==1) { $y = $z+1; }
	  }
	
      }
 
  #  print "\n--------------------------------------------------------\n";

    seek(corpus, $pos, 0);
}


for($i=0;$i<$#OUTPUT;$i++)
  {
    if(!($last eq $OUTPUT[$i]))
      {
	print "$OUTPUT[$i]";
      }
	$last = $OUTPUT[$i];
  }

close (corpus);
#while($line = <corpus>)
#  {
#    ($x, $x, $x, $x, $x, $word, $x, $zoneindex, $rest) = split(/\s+/, $line);
#
#    #check if all uppercase (&more than one letter)
#    if(($word =~ /^[A-Z][A-Z]+$/) && ($zoneindex =~ /TXT/))
#      {
#	$zoneindex =~ /[0-9]+/;
#	
#	print "$&\t$word\n";
#      }
#  }
