#!/bin/sh
TMPDATE=`date -u --iso-8601=date`
cd /web/cvs/
tar cf naviserver-${TMPDATE}.tar naviserver naviserver-modules
bzip2 naviserver-${TMPDATE}.tar
mv naviserver-${TMPDATE}.tar.bz2 /web/files/naviserver/