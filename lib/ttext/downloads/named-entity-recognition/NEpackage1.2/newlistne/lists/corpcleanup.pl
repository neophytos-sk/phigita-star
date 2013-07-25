#! /usr/bin/perl

open( myfile, "smallercorp");
open(newfile, ">>smallercorp2");

while(<myfile>)
{

s/^\s+//;
#s/,\s\n/\n/;
#s/,\n/\n/;
#s/&\n/\n/;
#s/&\s\n/\n/;	
#s/(\sCORP\.)|(\sLTD\.)|(\sS\.A\.)|(\sLTDA\.)|(\sLIMITED)|(\sCO\.)|(\sCO)|(\sINC\.)|(\sINC)|(\sBHD\.)|(\sSDN\.)|(\sS\.R\.L\.)|(\sC\.A\.)|(\sSA)|(\sLTDA)|(\sLTD)|(\sLDA)//g;
	print newfile $_;
}

close (myfile);
close (newfile);
