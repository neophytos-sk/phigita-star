source ../../naviserver_compat/tcl/module-naviserver_compat.tcl

package require TclCurl
::xo::lib::require curl
::xo::lib::require stockquote

::ext::StockQuote::get_historical_prices metadata data NYSE IBM 2010-01-17 2011-05-23

puts $data