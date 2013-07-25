#!/usr/bin/perl

open(file, "$ARGV[0]") || die "Can't open file.\n";

#mapping:
#1"O", ->1
#2"U-ORG",->14
#3"U-MISC",->17
#4"B-PER",->4
#5"L-PER",->12
#6"U-LOC",->15
#7"B-ORG",->2
#8"L-ORG",->10
#9"I-PER",->8
#10"U-PER",->16
#11"B-MISC",->5
#12"I-MISC",->9
#13"L-MISC",->13
#14"I-ORG",->6
#15"B-LOC",->3
#16"L-LOC",->11
#17"I-LOC")->7

@mapit = (0,1,14,17,4,12,15,2,10,8,16,5,9,13,6,3,11,7);

print "0: O B-ORG B-LOC B-PER B-MISC I-ORG I-LOC I-PER I-MISC L-ORG L-LOC L-PER L-MISC U-ORG U-LOC U-PER U-MISC\n";
@activations = ();
$end=0;
while(($end==0) && ($line = <file>))
  {
    $counter=1;
    while (($end==0) && ($line ne "-1\n"))
      {
	for($bla=1;($bla<=17) && ($end==0);$bla++)
	  {
	    ($i, $a) = split(/\s+/, $line);
	    $activations[$mapit[$i]] = $a;
	    if(!($line = <file>)) {$end=1;};
	  }
	print "$counter:";
	for($i=1;$i<=17;$i++)
	  {
	    $activ = $activations[$i];
	    print " $activ";
	  }
	print "\n";
	$counter++;

      }
    print "-1:\n";
  }
