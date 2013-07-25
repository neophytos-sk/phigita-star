#!/bin/sh
./code_docs.tcl test_words.txt stopwords.txt test_docs.txt ${1} > test_docs_0.txt

./transpose.tcl < test_docs_0.txt > test_docs_1.txt

### test_docs_hmetis N MfI 2 500 150 0.5
### N = num_hours
### M = maximal
### min_docs_per_cluster=2
### max_docs_per_cluster=500
### min_number_of_features=150
### min_confidence for finding association rules = 0.5

/opt/naviserver/bin/lcm ${2} -a ${6} -l ${3} -u ${4} test_docs_1.txt ${5} test_docs_hmetis_1.txt

cat test_docs_hmetis_1.txt


#./decode_clusters.tcl /web/tmp/test_docs_1.out /web/tmp/test_words.txt /web/tmp/test_docs.txt
./decode_clusters2.tcl test_docs_1.out test_words.txt test_docs.txt
