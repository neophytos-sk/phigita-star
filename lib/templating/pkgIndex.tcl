
set dir [file dirname [info script]]

package ifneeded templating 0.1 \
    "source [list [file join $dir tcl module-templating.tcl]]"

