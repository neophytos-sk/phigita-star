
set dir [file dirname [info script]]

package ifneeded ttext 0.1 [list source [file join $dir tcl module-ttext.tcl]]

