
set dir [file dirname [info script]]

package ifneeded tspam 0.1 [list source [file join $dir tcl module-tspam.tcl]]

