#!/usr/bin/perl

open (IN,$ARGV[0]);
$word_count = 0;
while($line = <IN>){
	@sentence = split(" ",$line);
	$word_count += $#sentence + 1;
}
print $word_count . "\n";

