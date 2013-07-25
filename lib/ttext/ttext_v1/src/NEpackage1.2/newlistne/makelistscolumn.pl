#!/usr/bin/perl

open(FILE, "$ARGV[0]")||die "couldn't open file";

$class="";
$word="";
while ($line=<FILE>)
  {
    chomp($line);
    @words = split(/\s+/,$line);
    for($i=0;$i<=$#words;$i++)
      {
	if($words[$i] eq "[")
	  {
	    if($words[$i+1] =~ /[BI]\-/)
	      {
		$class = $words[$i+1];
		$class =~ s/[BI]\-//g;
		print "$class\n";
		$i = $i + 3;
	      }
	    else {print "O\n";}
	  }
	else {print "0\n";}
      }
   if($line =~ /\S+/) { print "\n"};
  }
