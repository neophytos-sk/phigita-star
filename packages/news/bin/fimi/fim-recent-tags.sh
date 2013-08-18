#!/bin/sh


export ACS_ROOT_DIR=/web/service-phigita
export FIMI_DIR=${ACS_ROOT_DIR}/packages/news/bin/fimi/
export FIMI_WORKDIR=/web/data/news/fimi

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
./code_itemset_tags.tcl ${FIMI_WORKDIR}/itemset-words.txt ${FIMI_DIR}/stopwords.txt 7 > ${FIMI_WORKDIR}/input-recent-tags.txt
echo "Code Baskets: DONE"

## echo "Sorting..."
## sort -n input-recent-tags.txt > sorted-input-recent-tags.txt 
## echo "Sorting...OK"

echo "FIMI: START"

## /opt/naviserver/bin/lcm Cfq -u 5 sorted-input-recent-tags.txt 3 output-recent-tags.txt
/opt/naviserver/bin/lcm Cfq -u 5 ${FIMI_WORKDIR}/input-recent-tags.txt 3 ${FIMI_WORKDIR}/output-recent-tags.txt


echo "FIMI: END"

echo "Results"
./decode_recent_tags.tcl ${FIMI_WORKDIR}/output-recent-tags.txt ${FIMI_WORKDIR}/itemset-words.txt > output-recent-tags.sql
psql -U nsadmin -h aias -q -f output-recent-tags.sql buzzdb
