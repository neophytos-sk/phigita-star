
set dir [file dirname [info script]]

package ifneeded tlucene 0.1 \
    "source [list [file join $dir tcl module-tlucene.tcl]]"

