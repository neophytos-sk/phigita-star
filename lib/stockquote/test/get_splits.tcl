source ../../naviserver_compat/tcl/module-naviserver_compat.tcl

package require TclCurl
::xo::lib::require curl
::xo::lib::require stockquote

 ::ext::StockQuote::get_splits metadata data NYSE IBM 1900-01-01 2011-01-01

puts $data