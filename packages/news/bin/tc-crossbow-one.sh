#!/bin/sh

  /web/service-phgt-0/packages/news/bin/bow/crossbow --verbosity=0 -d /web/data/news/model-crossbow/$1 --hem-em-acceleration=1.8 --hem-branching-factor=2 --hem-maximum-depth=3 --hem-max-num-iterations=256 --hem-split-kl-threshold=0.025 --lex-white --no-stemming --no-stoplist --print-word-num=15 --method=hem-cluster --cluster > /dev/null