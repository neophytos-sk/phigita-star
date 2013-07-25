# $Id: makefile,v 1.12 2004/09/28 19:15:08 bernhard Exp $
# Copyright (C) 1997-2000, 2004 Bernhard Reiter <bernhard@intevation.de>
#
# The programm is Free Software published under the GNU GPL v>=2
# and comes without any warranty or fitness for a particular purpose.

# you have to change the following paths to where you have installed plotutils
BASE=/usr
PLOTLIBPATH=$(BASE)/lib
PLOTBINPATH=$(BASE)/bin
PLOTINCLUDEPATH=$(BASE)/include

PLOT2X=$(PLOTBINPATH)/plot -T X

# -ansi-strict
CC=gcc -Wall
CFLAGS= -I$(PLOTINCLUDEPATH)
#CFLAGS= -g -I$(PLOTINCLUDEPATH) -DDEBUG
LDFLAGS= -L$(PLOTLIBPATH)

# for OSF1/alpha 4.0d's cc, try
#CC=cc -w0 -std1


all: piechart test


test:: piechart probe.dat
	<probe.dat ./piechart -r0.6 -d0.05 -C skyblue2,green,aquamarine -t "Hello World" -fr -p "Joe Box" -T X -B 300x500+50+0 -n 0.1

moretests:: piechart probe.dat
	<probe.dat ./piechart -r0.6 -d0.05 -C skyblue2,green,aquamarine -t "Hello World" -p "Cliff" -n 0.15 | $(PLOT2X)
	<probe.dat ./piechart -r0.6 -d0.05 -C skyblue2,green,aquamarine -t "Hello World" | $(PLOT2X)


	
probe.dat:
	echo '#just a very small input file for testing piechart'>probe.dat
	echo 'Bernhard 50'  >>probe.dat
	echo 'Cliff	20' >>probe.dat
	echo 'Joe Box 10'   >>probe.dat
	
piechart: piechart.c $(PLOTLIBPATH)/libplot.so
	$(CC) $(CFLAGS) $(LDFLAGS) \
		piechart.c -o $@ -lplot -lm
