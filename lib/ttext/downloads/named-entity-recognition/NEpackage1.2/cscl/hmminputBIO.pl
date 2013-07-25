#!/usr/bin/perl

open (file, "$ARGV[0]") || die "Can't open file.\n";

#mapping:
#1: O ->1
#2: B-ORG ->3
#3: B-MISC->5
#4: B-PER ->4
#5: I-PER ->8
#6: B-LOC ->2
#7: I-ORG ->7
#8: I-MISC ->9
#9: I-LOC ->6

@mapit = (0,1,3,5,4,8,2,7,9,6);

print "0: O B-LOC B-ORG B-PER B-MISC I-LOC I-ORG I-PER I-MISC\n";
@activations = ();
$end=0;
while(($end==0) && ($line = <file>))
  {
    $counter=1;
    while (($end==0) && ($line ne "-1\n"))
      {
	for($bla=1;($bla<=9) && ($end==0);$bla++)
	  {
	    ($i, $a) = split(/\s+/, $line);
	    $activations[$mapit[$i]] = $a;
	    if(!($line = <file>)) {$end=1;};
	  }
	print "$counter:";
	for($i=1;$i<=9;$i++)
	  {
	    $activ = $activations[$i];
	    print " $activ";
	  }
	print "\n";
	$counter++;

      }
    print "-1:\n";
  }
