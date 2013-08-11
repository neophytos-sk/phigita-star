package provide curl 0.1


set dir [file dirname [info script]]

source [file join $dir curl.tcl]
source [file join $dir http-fetch.tcl]



