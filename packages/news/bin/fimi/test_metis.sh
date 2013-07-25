#!/bin/sh
NPARTS=${1}
rm /web/tmp/test_metis.graph.part.${NPARTS}
./trans_rules_to_pmetis.tcl /web/tmp/test_docs_hmetis_1.txt /web/tmp/vertex_to_doc.txt /web/tmp/pmetis_edges.txt > /web/tmp/test_pmetis.graph
./pmetis5.0pre2 /web/tmp/test_pmetis.graph ${NPARTS}
cat /web/tmp/test_pmetis.graph.part.${NPARTS}
./trans_parts_to_urls.tcl /web/tmp/test_pmetis.graph.part.${NPARTS}  /web/tmp/vertex_to_doc.txt /web/tmp/test_docs.txt 
