#!/bin/sh

fuser -s -k -n tcp 1821 1822

rm -rf /web/data/news/model-rainbow/*
rm -rf /web/data/news/model-crossbow/*

#Topic Classification
/web/service-phgt-0/packages/news/bin/bow/rainbow --verbosity=0 -d /web/data/news/model-rainbow/topic --lex-white --no-stemming --no-stoplist --index /web/data/news/tc/topic/*

#Edition Classification
/web/service-phgt-0/packages/news/bin/bow/rainbow --verbosity=0 -d /web/data/news/model-rainbow/edition --lex-white --no-stemming --no-stoplist --index /web/data/news/tc/edition/*

