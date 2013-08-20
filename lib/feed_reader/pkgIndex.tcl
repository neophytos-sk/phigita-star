
set dir [file dirname [info script]]

package ifneeded feed_reader 0.1 \
    "source [list [file join $dir tcl module-feed_procs.tcl]]"

