::xo::kit::reload [acs_root_dir]/packages/tools/tcl/storage-procs.tcl

set out ""
append out "\n [::cbt::id SIMPLEX-814.cbt_db]"
::xo::storage::dumpall

doc_return 200 text/plain $out
