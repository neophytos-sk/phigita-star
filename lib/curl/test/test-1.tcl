source ../../naviserver_compat/tcl/module-naviserver_compat.tcl

::xo::lib::require curl
::xo::lib::require tdom_procs

set url http://www.philenews.com/
set url http://www.sigmalive.com/

::xo::http::fetch html $url
::xo::html::extract links html {//a/@href} "" "values"

puts $links
