#!/bin/sh


export ACS_ROOT_DIR=/var/lib/naviserver/service-phigita
export FIMI_DIR=${ACS_ROOT_DIR}/packages/news/bin/fimi/

cd $FIMI_DIR

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
./code_related_query.tcl > input-related-query.txt
echo "Code Baskets: DONE"

echo "Sorting..."
sort -n input-related-query.txt > sorted-input-related-query.txt 
echo "Sorting...OK"

echo "FIMI: START"

../../../../bin/lcm Cfq -u 5 sorted-input-related-query.txt 100 output-related-query.txt


echo "FIMI: END"

echo "Results"
./decode_related_query.tcl output-related-query.txt > output-related-query.sql
psql -U nsadmin -h turing -q -f output-related-query.sql buzzdb
