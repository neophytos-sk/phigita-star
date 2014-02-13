#!/bin/bash

BUILD_DATE=`date -u +%Y-%m-%d`

UNPACK=/web/bin/unpack.sh

export WEBHOME=~nsadmin
FILEDIR=${WEBHOME}/files/
SRCDIR=${WEBHOME}/code/

SSLDIR=/web/data/ssl



PREFIX=/opt
WORKDIR=/usr/local/src/squanti-install-${BUILD_DATE}
SUFFIX=cvs-20070128


NAMESPACE=XO

MONGODB=mongodb-src-r1.8.2
MONGODB_HOME=${PREFIX}/mongodb-${BUILD_DATE}



#PGSQL=postgresql-8.2.3
#PGSQL=postgresql-8.3.1
PGSQL=postgresql-8.3.7
#PGSQL=postgresql-9.0.1
PGSQL=postgresql-9.0.4
#POSTGIS=postgis-1.3.3
POSTGIS=postgis-1.4.1

PGTCL=pgtcl1.5
SWIPL=pl-5.6.34
AOLSERVER=aolserver-4.5.1

#TCL=tcl8.4.15
#TCL=tcl-2007-08-31
#TCL=tcl8.5.7
#TCL=tcl8.5.8
#TCL=tcl8.5.9
#TCL=tcl8.5.10
#TCL=tcl8.5.11
#TCL=tcl8.5.12
#TCL=tcl8.6b2
TCL=tcl8.5.14
#TCL=tcl8.6.0

# TCL_THREAD_LIB=thread2.6.6
TCL_THREAD_LIB=thread2.6.7
# NOTE:
# - thread2.7.0 segfaults with naviserver 4.99.5
# - in particular, sv_* crashes whereas tsv::* work
#
TCL_THREAD_LIB=thread2.7.0-p20130529


#TDOM=tDOM-0.8.3
TDOM=tdom-20120716

#TCLLIB=tcllib-1.10
TCLLIB=tcllib-1.12
#TCLGD=Tclgd_1.3.0
TCLGD=tcl.gd-2009-11-30

#XOTCLVERSION=1.6.5
#XOTCLVERSION=1.6.6
#XOTCL=xotcl-${XOTCLVERSION}
XOTCL=nsf2.0b3
#XOTCL=nsf2.0b5

#TCLCURL=TclCurl-7.16.4
#TCLCURL=TclCurl-7.17.1
#TCLCURL=TclCurl-7.19.6
TCLCURL=TclCurl-7.22.0

#NAVISERVER=naviserver-4.99.2
#NAVISERVER=naviserver-4.99.3
#NAVISERVER=naviserver-4.99.3-phigita-2010.0
#NAVISERVER=naviserver-phigita-2012.1
#NAVISERVER=naviserver-phigita-2012.2
#NAVISERVER=naviserver-phigita-2012.3
#NAVISERVER=naviserver-phigita-2012.4
#NAVISERVER=naviserver-phigita-2013.1
#NAVISERVER=naviserver-phigita-2013.2
#NAVISERVER=naviserver-phigita-2013.3
#NAVISERVER=naviserver-phigita-2013.4
#NAVISERVER=naviserver-phigita-2013.5
#NAVISERVER=naviserver-phigita-2013.6
#NAVISERVER=naviserver-phigita-2013.7
#NAVISERVER=naviserver-phigita-2013.8
#NAVISERVER=naviserver-phigita-2013.9
#NAVISERVER=naviserver-phigita-2013.10
#NAVISERVER=naviserver-phigita-2014.1
NAVISERVER=naviserver-phigita-2014.2


#MAPSERVER=mapserver-5.0.2
MAPSERVER=mapserver-5.0.0

JEMALLOC=jemalloc-3.0.0

# scala play20 framework
#PLAYFRAMEWORK=play-2.0.3
PLAYFRAMEWORK=play-2.0.4

MYSQL=mysql-5.5.27

PGHOME=${PREFIX}/${PGSQL}
MSHOME=${PREFIX}/${MAPSERVER}
PLHOME=${PREFIX}/${SWIPL}
AOLSERVERHOME=${PREFIX}/${AOLSERVER}
YUICOMPRESSOR=yuicompressor-2.2.5
MYSQL_HOME=${PREFIX}/${MYSQL}

### GOOGLE PROJECTS
CLOSURE_COMPILER=compiler-latest
OPEN_VCDIFF=open-vcdiff-0.7


#NGINX=nginx-0.6.29
#NGINX=nginx-0.7.21
#NGINX=nginx-0.7.30
#NGINX=nginx-0.7.34
#NGINX=nginx-0.7.44
#NGINX=nginx-0.7.63
#NGINX=nginx-0.8.53
#NGINX=nginx-1.1.17
NGINX=nginx-1.2.3

#THRIFT=thrift-2008-11-29
#THRIFT=thrift-2008-08-09
#THRIFT=thrift-20080411p1
THRIFT=thrift-2009-11-22
CASSANDRA=cassandra-2008-12-04

#CLUCENE=clucene-2008-12-09
# CLUCENE now uses symbolic links to point to the right file
# see /web/files/clucene/clucene.tar.bz2
CLUCENE=clucene


TA_LIB=ta-lib-0.4.0
LIBXLS=libxls-0.2.0

OSM2PGSQL=osm2pgsql-20090707


JAVA_HOME=/opt/jdk1.7.0/
ANT_HOME=/opt/apache-ant-1.7.0
LUCENE_HOME=/web/lucene-2.4-dev

PATH=${ANT_HOME}/bin:${JAVA_HOME}/bin:${JAVA_HOME}/jre/bin/:/opt/naviserver/bin/:/opt/postgresql/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/javacc-4.1
LD_LIBRARY_PATH=${JAVA_HOME}/lib:/usr/local/lib:/usr/lib:/opt/naviserver/lib:/opt/postgresql/lib:/opt/clucene/lib
CLASSPATH=.:${ANT_HOME}:${JAVA_HOME}:${LUCENE_HOME}



#export PYVERSION=2.5
#export PYVERSION=2.4
#export PYTHONPATH=/usr/lib/python${PYVERSION}:/usr/lib/python${PYVERSION}/site-packages:/usr/lib/python${PYVERSION}/site-packages/thrift:/web/cassandra/interface/gen-py:/usr/local/include/thrift

MIME4J=apache-mime4j-0.3


TCLHOME=/opt/${TCL}

WEBSERVER=naviserver
NSHOME=${PREFIX}/${NAVISERVER}-${BUILD_DATE}



if [ -a /etc/make.conf ]; then
    source /etc/make.conf
fi

export CFLAGS
export CHOST
export CXXFLAGS
export MAKEOPTS
