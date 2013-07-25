# make

all: 
	./build-libs.csh libs.tcl > Lib/zplot.tcl
	cat Lib/zplot.tcl > Lib/zplot-import.tcl
	echo "namespace import Zplot::*" >> Lib/zplot-import.tcl

count:
	wc -l args.tcl drawable.tcl etc.tcl legend.tcl libs.tcl newaxis.tcl plot.tcl ps.tcl style.tcl table.tcl util.tcl  
	wc -l Examples/make-*.tcl


compare:	
	./build-compare.csh 05

compare-examples:
	./build-compare-examples.csh 05

