
set dir [file dirname [info script]]

package ifneeded liblinear 0.1 [list source [file join $dir tcl module-liblinear.tcl]]

