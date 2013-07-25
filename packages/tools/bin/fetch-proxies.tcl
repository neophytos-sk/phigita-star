load /opt/naviserver/lib/libnsd.so
package require TclCurl
package require tdom

source /web/service-phgt-0/packages/kernel/tcl/0000-utils/ZZ-xpathfunc-procs.tcl

set useragent "Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.1.6) Gecko/20100219 Gentoo Firefox/3.5.6"

set url http://tools.rosinstrument.com/proxy/l100.xml
curl::transfer -useragent $useragent -bodyvar xml -url $url

#puts $xml

set doc [dom parse $xml]
set textvalues [$doc selectNodes {textvalues(//*[local-name()='link'])}]

set proxies [string map {{%2B} {} {http://rosinstrument.com/cgi-bin/shdb.pl?key=} {}} $textvalues]



puts [join $proxies \n]


set fp [open proxies.source_rosinstrument.txt w]
puts $fp $proxies
close $fp

#set fp [open l100.xml]
#set data [read $fp]; set x 1
#close $fp
