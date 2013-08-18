#!/bin/sh

  /web/service-phigita/packages/news/bin/bow/crossbow --verbosity=0 -d /web/data/news/model-crossbow/Politics.World/ --method=hem-cluster --hem-branching-factor=8 --hem-maximum-depth=2 --hem-max-num-iterations=150 --lex-white --print-word-num=3 --cluster > /dev/null