
set dir [file dirname [info script]]

package ifneeded feed_procs 0.1 \
    "source [list [file join $dir tcl module-feed_procs.tcl]]"

