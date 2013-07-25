
set dir [file dirname [info script]]

package ifneeded dns 2.0 \
    "source [list [file join $dir tcl module-dns.tcl]]"

