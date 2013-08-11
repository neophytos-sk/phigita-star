
set dir [file dirname [info script]]

package ifneeded tdom_procs 0.1 \
    "source [list [file join $dir tcl module-tdom_procs.tcl]]"

