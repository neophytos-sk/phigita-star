
set dir [file dirname [info script]]

package ifneeded tchart 0.1 [list source [file join $dir tcl module-tchart.tcl]]

