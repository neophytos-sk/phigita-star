#!/bin/sh

#### ./lcm_clusters.sh 24 500 C 5 5


#./code_docs_ngrams.tcl test_words.txt stopwords.txt test_docs.txt ${1} ${2} > test_docs_ngrams_0.txt


#./code_docs.tcl test_words.txt /web/service-phgt-0/packages/news/bin/fimi/stopwords.txt test_docs.txt ${1} > test_docs_ngrams_0.txt

./transpose.tcl < test_docs_ngrams_0.txt > test_docs_ngrams_1.txt

### test_docs N M 2 500 150 
### N = num_hours
### M = maximal
### min_docs_per_cluster=2
### max_docs_per_cluster=500
### min_number_of_features=150

/opt/naviserver/bin/lcm ${3}fI -l ${4} test_docs_ngrams_1.txt ${5} test_docs_1.out



###./decode_clusters.tcl test_docs_1.out test_words.txt test_docs.txt
###./decode_clusters2.tcl test_docs_1.out test_words.txt test_docs.txt
### ./decode_clusters3.tcl test_docs_1.out test_words.txt test_docs.txt
