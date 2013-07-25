#!/usr/bin/tclsh


source ../../naviserver_compat/tcl/module-naviserver_compat.tcl
::xo::lib::require critbit_tree

set books_cbt [::cbt::create ::cbt::STRING_KEYS "bookdb"]
::cbt::restore $books_cbt "../data/books_ts_index.cbt_db"

# always destroy but, for now, we first have to make sure we have a valid tree (due to restore)
#::cbt::destroy $books_cbt
