#!/usr/bin/perl

open(myfile, "universityFinal.txt");
open(newfile,">>uFinal.txt");
while(<myfile>)
{
	s/'/ '/g;
	print newfile $_;
}

close(myfile);
close(newfile);
