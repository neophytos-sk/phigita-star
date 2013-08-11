package provide tdom_procs 0.1

package require tdom

set dir [file dirname [info script]]

source [file join $dir xpathfunc.tcl]
source [file join $dir html-extract.tcl]



