
set dir [file dirname [info script]]

package ifneeded stockquote 0.1 \
    "source [list [file join $dir tcl module-stockquote.tcl]]"

