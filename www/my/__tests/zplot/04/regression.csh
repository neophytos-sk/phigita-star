#! /bin/csh -f

echo "make-plot: Output/plot.eps"
tclsh make-plot.tcl > Output/plot.eps

echo "bucketize"
tclsh bucketize-heat.tcl 

echo "make-heat: Output/heat.eps"
tclsh make-heat.tcl > Output/heat.eps

echo "make-scatter: Output/scatter.eps"
./make-scatter.tcl > Output/scatter.eps

echo "make-linespoints: Output/linespoints.eps"
./make-linespoints.tcl > Output/linespoints.eps





