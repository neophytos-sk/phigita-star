#!/usr/bin/perl

$dir="/home/nkd/my/experiments/NEpackage1.2";

$processed_FN="$dir/tmp/processed.tmp";
$hmminput_FN="$dir/tmp/hmminput.tmp";
$initial_FN="$dir/tmp/initial.tmp";
$pss_FN="$dir/tmp/pss.tmp";
$allow_FN="$dir/tmp/allow.tmp";
$outtmp_FN="$dir/tmp/outtmp.tmp";
$HMMProg="$dir/cscl/HMMPure";


open (corpus, "$ARGV[0]") || die "Can't open file.\n";
open (activ, "$ARGV[1]") || die "Can't open file.\n";
open (lexicon, "$ARGV[2]") || die "lexicon file not specified.\n";
#open (outfile, "$ARGV[3]") || die "cant open outfile.\n";
open (processed, ">$processed_FN") || die "Can't open processed output file.\n";
open (hmminput, ">$hmminput_FN") || die "Can't open hmminput output file.\n";
open (initial, ">$initial_FN") || die "Can't open p1 file for output.\n";
open (pss, ">$pss_FN") || die "Can't open pss file for output.\n";
open (allow, ">$allow_FN") || die "Can't open allow file for output.\n";

@NEtypes = @ARGV[4..$#ARGV];
$numLabels = 4*($#NEtypes+1) + 1;
#print $numLabels;

$lab = `grep colOne $ARGV[2]`;

$lab =~ s/.*\[O\].*/O/g;
$lab =~ s/.*([BILU]-[A-Z]+).*/\1 /g;
@labels = split(/\s+/,$lab);

# we only care about the labels given as parameters
@labelarr=();
@numberarr=();

@labelexists = ();
$labelexists[1] = 1;

push @labelarr, "O";
push @numberarr, 1;
for($i=1;$i<= $#labels;$i++)
  {
    for($j=0;(($j<=$#NEtypes) && ($labels[$i] !~ $NEtypes[$j]));$j++) {}

    if($j<=$#NEtypes)
      {
	push @labelarr, $labels[$i];
	push @numberarr, ($i+1);
	$labelexists[$i+1]=1;
      }
  }

#foreach $x(@labels) {print "$x ";}
#$numLabels == ($#labels+1) || die "Number of labels inconsistent in lexicon.\n";

Exponentialize();
close(processed);
open(processed, "$processed_FN") || die "????";
HMMinput();
MakeInitial();
MakePSS();
MakeAllow();

$a=`$HMMProg $initial_FN $pss_FN $hmminput_FN $allow_FN > $outtmp_FN`;
$a=`cat $outtmp_FN | perl -ne 's/\n/\n\n/g;s/ /\n/g;print $_;' > $ARGV[3]`;

sub Exponentialize#()
  {
    my($line, $aline, $i, @activations, @labels, $sum, $value);
    seek(corpus,0,0);
    seek(activ,0,0);
    while($line = <corpus>)
      {
	#$aline = <activ>;
	if(!($line =~ "x"))
	  {
	    print processed "-1\n";
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
	    for($i=1;$i<=$#labels;$i++)
	      {
		if($labelexists[$labels[$i]]==1)
		  {
		    $value = $activations[$i] / $sum;
		    print processed "$labels[$i]\t$value\n";
		  }
	      }
	    #print "\n";
	  }
      }
  }


sub HMMinput#()
  {
    my ($x, @activations, $end, $counter, $line, $bla, $a);
    seek(processed,0,0);
#    for($x=0;$x<1000;$x++) {$u = <processed>;print "f $u f";}
    $end=0;
    print hmminput "0: ";
    for($x=0;$x<=$#labelarr;$x++)
      {
	print hmminput $labelarr[$x];
	if($x==$#labelarr) {print hmminput "\n";}
	else {print hmminput " ";}
      }

    while(($end==0) && ($line = <processed>))
      {
	$counter=1;
	while (($end==0) && ($line ne "-1\n"))
	  {
	    for($bla=1;($bla<=$numLabels) && ($end==0);$bla++)
	      {
		($i, $a) = split(/\s+/, $line);
		$activations[$i] = $a;
		if(!($line = <processed>)) {$end=1;};
	      }
	    print hmminput "$counter:";
	    for($i=1;$i<=$numLabels;$i++)
	      {
		$activ = $activations[$i];
		print hmminput " $activ";
	      }
	    print hmminput "\n";
	    $counter++;
	    
	  }
	print hmminput "-1:\n";
      }
    
  }

sub MakeInitial#()
  {
    my $x;
   print initial "total\t1\t1\n";
   foreach $x(@labelarr)
     {
       print initial "$x\t";
       if($x =~ /^[BUO]/) {print initial "1\t1\n";}
       else {print initial "0\t0\n"}
     }
  }

sub MakePSS#()
  {
    my $x;
    print pss "\ttotal";
    foreach $x(@labelarr)
      {
	print pss "\t$x";
      }
    print pss "\ntotal";
    foreach $x(@labelarr)
      {
	print pss "\t1";
      }
    print pss "\t1\n";

    foreach $x(@labelarr)
      {
	print pss "$x\t1";
	foreach $y(@labelarr)
	  {
	    $result = ValidTransition($x, $y);
	    print pss "\t$result";
	  }
	print pss "\n";
      }

    #now repeat that because the file format requires it...
    print pss "\n";
    
    print pss "\ttotal";
    foreach $x(@labelarr)
      {
	print pss "\t$x";
      }
    print pss "\ntotal";
    foreach $x(@labelarr)
      {
	print pss "\t1";
      }
    print pss "\t1\n";

    foreach $x(@labelarr)
      {
	print pss "$x\t1";
	foreach $y(@labelarr)
	  {
	    $result = ValidTransition($x, $y);
	    print pss "\t$result";
	  }
	print pss "\n";
      }
  }

sub ValidTransition#()
  {
    my $a = $_[0];
    my $b = $_[1];
    my $x = $a;
    my $y = $b;
    my $sameClass=0;
    if($x ne "O") {$x =~ s/.*\-(.*)/\1/g;}
    if($y ne "O") {$y =~ s/.*\-(.*)/\1/g;}
    if($x eq $y) { $sameClass=1};

    if($a =~ /^B/ || $a =~ /^I/)
      {
	if($b =~ /^B/ || $b =~ /^U/ || $b =~ /^O/ || $sameClass==0 ) {return 0;}
	else {return 1;}
      }
    else
      {
	if($b =~ /^O/ || $b =~ /^U/ || $b =~ /^B/) {return 1;}
	else {return 0;}
      }

  }

sub MakeAllow#()
  {
    my ($x, $y);
    foreach $x(@labelarr)
      {
	if($x =~ /^[LOU]/) {print allow "$x\t1\n";}
	else {print allow "$x\t0\n";}
      }
  }

close(processed);
#unlink("$processed_FN", "$initial_FN", "$hmminput_FN", "$pss_FN", "$allow_FN", "$outtmp_FN");
