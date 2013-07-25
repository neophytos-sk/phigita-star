
set dir [file dirname [info script]]

package ifneeded nssmtpd 0.1 [list source [file join $dir tcl module-nssmtpd.tcl]]

