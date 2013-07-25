set dir [file dirname [info script]]

package ifneeded platform 1.0.3 [list source [file join $dir tcl platform.tcl]]
package ifneeded critcl 2.1 [list source [file join $dir tcl critcl.tcl]]
