set dir [file dirname [info script]]

package ifneeded critcl 2.1 [list source [file join $dir tcl module-critcl.tcl]]
