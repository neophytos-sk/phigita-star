#!/bin/sh
NPARTS=${1}
rm /web/tmp/test_hmetis.graph.part.${NPARTS}
./trans_rules_to_hmetis.tcl /web/tmp/test_docs_hmetis_1.txt /web/tmp/vertex_to_doc.txt /web/tmp/hmetis_edges.txt > /web/tmp/test_hmetis.graph
## balance=190%
## iterations=100
## Ctype=hedge (4)
## otype=cut (1)
## vcycle=ForMin(2)
## dbglvl = debug level = 0
./khmetis /web/tmp/test_hmetis.graph ${NPARTS} 190 100 4 1 2 0
cat /web/tmp/test_hmetis.graph.part.${NPARTS}
./trans_parts_to_urls.tcl /web/tmp/test_hmetis.graph.part.${NPARTS}  /web/tmp/vertex_to_doc.txt /web/tmp/test_docs.txt 
