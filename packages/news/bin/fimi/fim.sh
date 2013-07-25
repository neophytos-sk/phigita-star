#!/bin/sh

echo "Dump Words: START"
psql -q -h turing -t -A -F ' ' -f words-dump.sql -o words.txt buzzdb
echo "Dump Words: DONE"

echo "Code Baskets: START"
./code_baskets.tcl > input.txt
echo "Code Baskets: DONE"

echo "FIMI: START"
./fim_all input.txt 250 output.txt
echo "FIMI: END"

echo "Results"
./decode_baskets.tcl output.txt

