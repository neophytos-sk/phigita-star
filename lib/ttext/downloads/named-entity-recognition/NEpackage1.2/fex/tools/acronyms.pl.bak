#!/usr/bin/perl


if (@ARGV < 1)
{
  print "This script extracts all acronyms (only-cap words) from the text zone of documents from a corpus in table format. It also records the the index of the document along with the acronym. It also finds words sequences in the same document that match the acronym\n";
  print "usage: acronyms.pl corpus > output\n";
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
    #find acronyms
    $x=0;
    while($x< ($i-2))
      {
	$word = $DOC[$x];
	
	#print "$word ";
	# find an acronym and look for a sequence of equivalent words in document
	if($word =~ /^[A-Z][A-Z]+$/)
	  {
	    @letters = split(//,$word);
	    
	    # now find string sequence
	    for($index=1;$index<=($#DOC - $#letters+1); $index++)
	      {
		$correct=1;
		
		# find matching sequence
		for($wordnum=0; ($wordnum<=$#letters) && ($correct==1); $wordnum++)
		  {
		    ($first) = split(//, $DOC[$index+$wordnum-1]);
		    if(!($first eq $letters[$wordnum]))
		      {
			$correct=0;
		      }
		  }
		#it is only correct, however, if previous and next word are not capitalized
		if($index==0) {$prev="";} else {$prev=$DOC[$index-2];}
		$at = $index+$#letters -1;
		if($at==$#DOC) {$next="";} else {$next=$DOC[$at+1];}
		if( ($prev =~ /^[A-Z]/) || ($next =~ /^[A-Z]/) )
		  {
		    $correct=0;
		  }
		if($correct==1)
		  {
		  #  print "prev:$prev next:$next\n";
		  #  ($bla , $docindex) = split(/\//, $zoneindex);
		    
		    print "$docindex ";
		    for($wordnum=0; ($wordnum<=$#letters); $wordnum++)
		      {
			print "$letters[$wordnum]";
		      }
		    print " ";
		    for($wordnum=0; ($wordnum<=$#letters); $wordnum++)
		      {
			print "$DOC[$index+$wordnum-1]";
			if($wordnum!=$#letters) {print "_";}
		      }
		    print "\n";
		  }

	      }
	  }
	$x++;
      }
  #  print "\n--------------------------------------------------------\n";

    seek(corpus, $pos, 0);
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
