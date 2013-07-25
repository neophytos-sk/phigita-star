
set dir [file dirname [info script]]

package ifneeded json 0.1 \
    "source [list [file join $dir tcl module-json.tcl]]"

