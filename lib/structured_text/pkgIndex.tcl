
set dir [file dirname [info script]]

package ifneeded structured_text 0.1 \
    "source [list [file join $dir tcl module-structured_text.tcl]]"

