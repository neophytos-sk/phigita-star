
set dir [file dirname [info script]]

package ifneeded geoip 0.1 [list source [file join $dir tcl module-geoip.tcl]]

