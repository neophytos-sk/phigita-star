source [acs_root_dir]/packages/xo-messaging/tcl/mms-procs.tcl
set filename [acs_root_dir]/tmp/neo-mms.raw
set fp [open $filename]
fconfigure $fp -translation binary
set o [::messaging::mms::RequestHandler new -data [read $fp]]
close $fp
set msg [$o msg]
foreach varName [$msg info vars] {
    lappend debug [list $varName [$msg set $varName]]
}

doc_return 200 text/plain [join $debug \n]
