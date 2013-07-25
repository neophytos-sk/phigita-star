#!/bin/sh


fuser -s -k -n tcp 1821
/web/service-phgt-0/packages/news/bin/bow/rainbow --verbosity=0 --method=svm -d /web/data/news/model-rainbow/topic --lex-white --build-and-save --use-saved-classifier --query-server=1821 &
fuser -s -k -n tcp 1822
/web/service-phgt-0/packages/news/bin/bow/rainbow --verbosity=0 --method=svm -d /web/data/news/model-rainbow/edition --lex-white --build-and-save  --use-saved-classifier  --query-server=1822 &

