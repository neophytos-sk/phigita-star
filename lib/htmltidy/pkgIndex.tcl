
set dir [file dirname [info script]]

package ifneeded htmltidy 0.1 [list source [file join $dir tcl module-htmltidy.tcl]]

