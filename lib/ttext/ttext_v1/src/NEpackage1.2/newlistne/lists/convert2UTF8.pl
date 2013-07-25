#!/usr/bin/perl 

@files = `ls *.txt`;
map { chomp($_); } @files;#$temp = $_; $temp =~ s/\.orig//g; `cp $_ $temp`; } @files;

foreach $file(@files)
{
	`cp $file $file.orig`;
	`iconv -f "ISO-8859-1" -t "UTF-8" $file > $file.tmp`;
	`rm $file`;
	`mv $file.tmp $file`;
}
