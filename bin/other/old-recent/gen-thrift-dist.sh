#!/bin/sh
cd /web/cvs/
TMPDATE=`date -u --iso-8601=date`
cp -R thrift/trunk thrift-${TMPDATE}
tar cjf thrift-${TMPDATE}.tar.bz2 thrift-${TMPDATE}
rm -rf thrift-${TMPDATE}