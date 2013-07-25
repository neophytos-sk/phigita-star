#! /bin/csh -f

set f = $argv[1]

awk -f build-libs.awk $f 


