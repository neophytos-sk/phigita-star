#!/bin/sh

DIMENSIONS=${1}
FMT=${2}


CHACO_PARAMS="/web/tmp/test_chaco.graph /web/tmp/test_chaco.out 1 200 ${DIMENSIONS} 1 n"



rm /web/tmp/test_chaco.out;./trans_rules_to_chaco.tcl /web/tmp/test_docs_hmetis_1.txt /web/tmp/vertex_to_doc.txt ${FMT} > /web/tmp/test_chaco.graph
echo ${CHACO_PARAMS} | ./chaco 
cat /web/tmp/test_chaco.out; ./trans_parts_to_urls.tcl /web/tmp/test_chaco.out /web/tmp/vertex_to_doc.txt /web/tmp/test_docs.txt 
