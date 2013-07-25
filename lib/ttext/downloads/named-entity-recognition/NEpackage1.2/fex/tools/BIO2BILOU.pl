#!/usr/bin/perl
# translates BIO corpus to BILOU corpus
if (@ARGV < 1)
{
  print "BIO corpus not specified\n";
  exit;
}

open (corpus, "$ARGV[0]") || die "Can't open file.\n";


$prevline = <corpus>;
while ($line = <corpus>)
  {
    ($ne, $a, $index, $phrase, $pos, $word, $x, $b, $c) = split(/\s+/, $line);
    ($ne1, $a1, $index1, $phrase1, $pos1, $word1, $x1, $b1, $c1) = split(/\s+/, $prevline);

    if(($ne eq "O") || ($ne eq ""))
      {
	if($ne1 =~ /^B/) { $ne1 =~ s/^B/U/g; }
	elsif ($ne1 =~ /^I/) { $ne1 =~ s/^I/L/g; }
      }
    print "$ne1\t$a1\t$index1\t$phrase1\t$pos1\t$word1\t$x1\t$b1\t$c1\n";
    $prevline = $line;
  }
