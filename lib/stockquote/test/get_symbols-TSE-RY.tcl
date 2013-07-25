source ../../naviserver_compat/tcl/module-naviserver_compat.tcl

package require TclCurl
::xo::lib::require curl
::xo::lib::require stockquote

 ::ext::StockQuote::get_historical_prices metadata data TSE RY 2010-01-01 2011-01-01

puts $data