#! /bin/csh -f

echo "make-plot: Output/plot.eps"
tclsh make-plot.tcl > Output/plot.eps

echo "bucketize"
tclsh bucketize-heat.tcl 

set files = `cat regression.files`

foreach t ($files)
    echo "make-${t}: Output/${t}.eps"
    rm -f Output/${t}.eps
    ./make-${t}.tcl 
end

