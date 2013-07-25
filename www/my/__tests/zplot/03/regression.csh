#! /bin/csh -f

echo "make-plot: ~/Desktop/plot.eps"
tclsh make-plot.tcl > ~/Desktop/plot.eps

echo "bucketize"
tclsh bucketize-heat.tcl 

echo "make-heat: ~/Desktop/heat.eps"
tclsh make-heat.tcl > ~/Desktop/heat.eps





