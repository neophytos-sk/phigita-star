#!/bin/sh


export ACS_ROOT_DIR=/web/service-phgt-0
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
### ./code_baskets_tags.tcl > ${FIMI_WORKDIR}/input-tags.txt
./code_itemset_tags.tcl ${FIMI_WORKDIR}/rules-words.txt ${FIMI_DIR}/stopwords.txt > ${FIMI_WORKDIR}/input-tags.txt
echo "Code Baskets: DONE"

## echo "Sorting..."
## sort -n  ${FIMI_WORKDIR}/input-tags.txt > ${FIMI_WORKDIR}/sorted-input-tags.txt 
## echo "Sorting...OK"

echo "FIMI: START"

### OLD - REPLACED WITH LCM 5.1: /opt/naviserver/bin/lcm_rule Afa  ${FIMI_WORKDIR}/input-tags.txt 5 3  ${FIMI_WORKDIR}/output-tag-rules.txt
/opt/naviserver/bin/lcm f -a 0.05 -u 2 ${FIMI_WORKDIR}/input-tags.txt 500  ${FIMI_WORKDIR}/output-tag-rules.txt

echo "FIMI: END"

echo "Results"
./decode_rules.tcl  ${FIMI_WORKDIR}/output-tag-rules.txt ${FIMI_WORKDIR}/rules-words.txt >  ${FIMI_WORKDIR}/output-tag-rules.sql

psql -U nsadmin -h aias -q -f  ${FIMI_WORKDIR}/output-tag-rules.sql buzzdb
