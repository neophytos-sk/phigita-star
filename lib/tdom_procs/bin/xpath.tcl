#!/bin/sh
## -*- tcl -*- \
exec tclsh "$0" ${1+"$@"}

package require curl
package require tdom_procs
package require htmltidy

set url [lindex $argv 0]
set xpath [lindex $argv 1]

xo::http::fetch html $url

set html [htmltidy::tidy $html]

set doc [dom parse -html $html]
set result [$doc selectNodes $xpath]
$doc delete


puts [join $result \n]
