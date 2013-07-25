
set dir [file dirname [info script]]

package ifneeded ta-lib 0.1 [list source [file join $dir tcl module-ta-lib.tcl]]

