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
	while(($aline =~/^[0-9]+/) && ($&<1000))
	  {
	    print "$& ";
	    $aline =~ /\s+[0-9e.+-]+\s+/;
	    print "$&\n";
	    $aline = <activ>;
	  }
	#print "\n";
      }
  }

