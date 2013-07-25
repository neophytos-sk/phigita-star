
set dir [file dirname [info script]]

package ifneeded critbit_tree 0.1 [list source [file join $dir tcl module-critbit_tree.tcl]]

