#!/usr/bin/perl

open (corpus, "$ARGV[0]") || die "Can't open file.\n";
open (activ, "$ARGV[1]") || die "Can't open file.\n";

while($line = <corpus>)
  {
    #$aline = <activ>;
    if(!($line =~ "x"))
      {
	print "-1\n";
      }
    else
      {
	#$aline =~ s/([0-9]+):\s+([0-9.]+).*/\1 \2/g;
	while(!($aline =~ /Example/))
	  {
	    $aline = <activ>;
	  }
	$aline = <activ>;
	
	@activations=();
	@labels=();
	$i=1;
	$sum=0;
	while(($aline =~/^[0-9]+/) && ($&<1000))
	  {
	    $labels[$i]=$&;
	    $aline =~ /\s+[0-9e.+-]+[\n\*]+/;
	    $value = $&;
	    $value =~ s/\*//g; $value =~ s/\n//g;
	    $activations[$i] = exp($value);
	    $sum += $activations[$i];
	    $aline = <activ>;
	    $i++;
	  }
	for($i=1;$i<=9;$i++)
	{
	 $value = $activations[$i] / $sum;
	 print "$labels[$i]\t$value\n";
	}
	#print "\n";
      }
  }

