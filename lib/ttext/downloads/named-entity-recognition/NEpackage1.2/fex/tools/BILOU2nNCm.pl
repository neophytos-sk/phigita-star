#!/usr/bin/perl
# adds nNCm tags to 2nd column of corpus
if (@ARGV < 1)
{
  print "BIO corpus not specified\n";
  exit;
}

open (corpus, "$ARGV[0]") || die "Can't open file.\n";


while(($line=<corpus>) && ($done==0))
  {
  #  print "DAMN!";

    # get a document
    ($ne, $x, $rest) = split(/\s+/, $line);

    if($ne =~ /^B/)
      {
	@LINES = ();
	$m=1;
	$word=$ne;
	$done=0;
	while(!($word =~ /^L/) && $done==0)
	  {
	    $m++;
	    push @LINES, $line;
	    $pos = tell(corpus);
	    if($line = <corpus>)
	      {
		($word, $x, $rest) = split(/\s+/, $line);
	      }
	    else { $done=1; }
	  }
	push @LINES,  $line;
	$ne =~ s/[A-Z]\-([A-Z]+)/\1/g;
	for($i=0;$i<=$#LINES;$i++)
	  {
	    $n = $i+1;
	    if($#LINES<9) # don't process long, weird entities
	    { $x = "$n$ne$m";}
	    else {$x = "O";}
	    ($word, $bla, @rest) = split(/\s+/, $LINES[$i]);
	    print "$word\t$x";
	    foreach $word (@rest) { print"\t$word"; }
	    print "\n";
	  }
      }
    elsif($ne =~ /^U/)
      {
	$n=1;
	$m=1;
	$ne =~ s/[A-Z]\-([A-Z]+)/\1/g;
	$x = "$n$ne$m";
	($word, $bla, @rest) = split(/\s+/, $line);
	print "$word\t$x";
	foreach $word (@rest) { print"\t$word"; }
	print "\n";

      }
    elsif($ne =~ /^O/)
      {
	($word, $bla, @rest) = split(/\s+/, $line);
	print "$word\tO";
	foreach $word (@rest) { print"\t$word"; }
	print "\n";
      }
    else { print $line;}

  }
