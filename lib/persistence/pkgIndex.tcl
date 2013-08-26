
set dir [file dirname [info script]]

package ifneeded persistence 0.1 \
    "source [list [file join $dir tcl module-persistence.tcl]]"

