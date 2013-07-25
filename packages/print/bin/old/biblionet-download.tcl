#!/usr/bin/tclsh
package require TclCurl
set url [lindex $argv 0]
set url2 [lindex $argv 1]


set urlHandler [curl::init]
$urlHandler configure -url $url -headervar header -bodyvar body
$urlHandler perform

#puts [$urlHandler getinfo cookielist]
#puts "Header: [array names header]"

#lassign [join $header(Set-Cookie)] cookie
#set cookie [string trim $cookie {;}]

set cookie $header(Set-Cookie)


#set cookielist ASPSESSIONIDAAADTBDC=NCBHOFEAKOCDEIFJDEMILFBL

$urlHandler configure -url $url2 -cookie $cookie -headervar header2 -bodyvar body2
$urlHandler perform
puts $body2

$urlHandler cleanup