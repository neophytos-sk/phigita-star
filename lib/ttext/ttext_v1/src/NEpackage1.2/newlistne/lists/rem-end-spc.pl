#!/usr/bin/perl

while(<>)
{
	s/\s+\n/\n/;
	print $_;
}
