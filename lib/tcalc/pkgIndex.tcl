
set dir [file dirname [info script]]

package ifneeded tcalc 0.1 [list source [file join $dir tcl module-tcalc.tcl]]

