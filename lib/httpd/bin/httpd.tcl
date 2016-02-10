#!/bin/sh
##\
  exec tclsh "$0" "$@"

package require core
package require httpd

set host [config get ::httpd host]
set port [config get ::httpd port]
set homedir [config get ::httpd homedir]
set default_page [config get ::httpd default_page]

puts host=$host
puts port=$port
puts homedir=$homedir
puts default_page=$default_page

Httpd_Server $homedir $host $port $default_page

# Httpd_Server $env(HOME)/public_html 8080 index.html
# puts stderr "home dir: $env(HOME)"
# puts stderr "Starting Tcl httpd server on [info hostname] port 8080"
vwait forever		;# start the Tcl event loop


