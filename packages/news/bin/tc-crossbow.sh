#!/bin/sh


start_time_in_seconds=`date +%s`
rm -rf /web/data/news/tmp/crossbow-clustering/*
cd /web/data/news/tc/cluster_sk
for topic in *;
do
  cd /web/data/news/model-crossbow/${topic}
  rm -f crossbow-*-*

  /web/service-phigita/packages/news/bin/tc-crossbow-one.sh ${topic}

  rm -f crossbow-*-?
  rm -f crossbow-*-??
  touch crossbow-words-000
  touch crossbow-classifications-000


  echo "begin;" > /web/data/news/tmp/crossbow-clustering/${topic}.sql

  # words
  cat `ls -r crossbow-words-* | head -n 1` | /web/service-phigita/packages/news/bin/crossbow-words-to-sql.tcl ${start_time_in_seconds} ${topic} xo.xo__clustering__class >> /web/data/news/tmp/crossbow-clustering/${topic}.sql

  # classifications
  cat `ls -r crossbow-classifications-* | head -n 1` | /web/service-phigita/packages/news/bin/crossbow-classifications-to-sql.tcl ${start_time_in_seconds} ${topic} xo.xo__clustering__class xo.xo__sw__agg__url >> /web/data/news/tmp/crossbow-clustering/${topic}.sql

  echo "end;" >> /web/data/news/tmp/crossbow-clustering/${topic}.sql

  cp `ls -r crossbow-classifications-* | head -n 1` crossbow-classifications.done
  cp `ls -r crossbow-words-* | head -n 1` crossbow-words.done

  /web/service-phigita/packages/news/bin/tc-upload.sh /web/data/news/tmp/crossbow-clustering/${topic}.sql
done

