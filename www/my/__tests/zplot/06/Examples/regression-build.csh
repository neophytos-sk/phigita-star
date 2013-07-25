#! /bin/csh -f

echo "bucketize"
tclsh bucketize-heat.tcl 

set files = `cat regression.files`

foreach t ($files)
    echo "make-${t}: ${t}.eps"
    rm -f Output/${t}.eps
    ./make-${t}.tcl 
end

