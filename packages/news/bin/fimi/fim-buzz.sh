#!/bin/sh


export ACS_ROOT_DIR=/web/service-phigita
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
./code_baskets_buzz.tcl > input-buzz.txt
echo "Code Baskets: DONE"

echo "Sorting..."
sort -n input-buzz.txt > sorted-buzz-tags.txt 
echo "Sorting...OK"

echo "FIMI: START"

../../../../bin/lcm_rule Afa input-buzz.txt 50 100 output-buzz-rules.txt

echo "FIMI: END"

echo "Results"
./decode_rules.tcl output-buzz-rules.txt > output-buzz-rules.sql
#psql -U nsadmin -h turing -q -f output-tag-rules.sql buzzdb
