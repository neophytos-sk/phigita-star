#!/bin/sh

export LANG=el_GR.utf8
export LC_CTYPE="el_GR.utf8"
export LC_NUMERIC="el_GR.utf8"
export LC_TIME="el_GR.utf8"
export LC_COLLATE="el_GR.utf8"
export LC_MONETARY="el_GR.utf8"
export LC_MESSAGES="el_GR.utf8"
export LC_PAPER="el_GR.utf8"
export LC_NAME="el_GR.utf8"
export LC_ADDRESS="el_GR.utf8"
export LC_TELEPHONE="el_GR.utf8"
export LC_MEASUREMENT="el_GR.utf8"
export LC_IDENTIFICATION="el_GR.utf8"
export LC_ALL=el_GR.utf8

echo "Code Baskets: START"
./code_baskets_A.tcl > input.txt
echo "Code Baskets: DONE"

echo "Sorting..."
sort -n input.txt > sorted_input.txt 
echo "Sorting...OK"

echo "FIMI: START"

#../lcm50/lcm Mf sorted_input.txt 2 output.txt

#../lcm50/lcm Cf -l 3 -u 3 sorted_input.txt 3 output.txt

../../../../bin/lcm Cfq -u 3 -U 200 sorted_input.txt 10 output.txt

echo "FIMI: END"

echo "Results"
./decode_baskets.tcl output.txt

