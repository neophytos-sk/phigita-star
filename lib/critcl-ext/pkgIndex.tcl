
set dir [file dirname [info script]]

package ifneeded critcl-ext 0.1 [list source [file join $dir tcl module-critcl-ext.tcl]]

