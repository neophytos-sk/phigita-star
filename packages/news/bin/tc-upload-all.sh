#!/bin/sh

cd /web/data/news/tmp/crossbow-clustering/
for file in *.sql;
do
  psql -q -h turing -U postgres -f $file newsdb
  rm -f $file
done
