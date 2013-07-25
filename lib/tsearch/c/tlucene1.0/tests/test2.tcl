package require XOTcl; namespace import -force ::xotcl::*

load /opt/naviserver/lib/libnsd.so
load /opt/naviserver/bin/tlucene1.0.so
load /opt/naviserver/bin/libttext0.4.so

source ../lib/tlucene.tcl

namespace path {::ttext::analysis}

set spec ::ttext::analysis::tsQueryField



puts [plain_to_tsquery "hello world this is a test"]
puts [plain_to_tsquery "test"]
puts [plain_to_tsquery "test2"]
puts [plain_to_tsquery ""]