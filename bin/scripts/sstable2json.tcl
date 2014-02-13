#!/usr/bin/env tclsh

package require XOTcl;namespace import -force ::xotcl::*

set ACS_ROOT_DIR /web/service-phgt-0
set PKG_DIR ${ACS_ROOT_DIR}/packages/kernel/



source ${PKG_DIR}/tcl/20-xo/10-io/00-readwrite-procs.tcl
source ${PKG_DIR}/tcl/20-xo/10-io/BufferedRandomAccessFile-procs.tcl-orig
source ${PKG_DIR}/tcl/20-xo/20-db/SSTable.tcl

set exporter [SSTableExport new]
puts [$exporter export /var/lib/cassandra/data/Keyspace1/Standard2-1-Data.db]

