# get more proxy servers from xroxy.com

package require TclCurl
source /opt/naviserver/lib/TclCurl7.19.6/tclcurl.tcl

#set proxy_list_url "http://www.multiproxy.org/txt_all/proxy.txt"
#
set fp [open proxy.txt]
set proxylist1 [read $fp]
close $fp

#set proxy_list_url http://tools.rosinstrument.com/proxy/l100.xml
set fp [open proxies.source_rosinstrument.txt]
set proxylist2 [read $fp]
close $fp

set proxies [concat $proxylist2 $proxylist1]

#set proxies "" ;# REMOVE THIS FOR THE proxy.txt FILE TO TAKE EFFECT
lappend proxies "www-proxy.cytanet.com.cy:8080"
lappend proxies 92.52.125.20:80
lappend proxies 88.146.213.224:3128
lappend proxies 148.244.96.178:80


set proxies "127.0.0.1:9050" ;# tor proxy
#set proxy [lindex $proxies [expr { int(rand() * [llength $proxies]) }]]


# encoding: Sets the contents of the Accept-Encoding: header sent in an HTTP request, and enables decoding of a response when a Content-Encoding: header is received
# identity (which does nothing), 
# deflate (which requests server to compress its response)
# and gzip (which requests the gzip algorithm). 
# Use all to send an Accept-Encoding: header containing all supported encodings.
set encoding "all"


set timeout "30" ;# in seconds

# proxytype: available options are socks5 socks4 http1.0 http
# There are 3 versions of SOCKS you are likly to run into:
# SOCKS4 (which only uses IP addresses)
# SOCKS5 (which usually uses IP addresses in practice)
# SOCKS4a (which uses hostnames)  --- use with TclCurl >=7.19.6 
#set proxytype socks5hostname
set proxytype socks4a

set proxytype "http"
foreach proxy $proxies {
    lassign [split $proxy {:}] proxyurl proxyport

    puts "trying with proxy $proxy"
    set useragent "Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.1.6) Gecko/20100219 Gentoo Firefox/3.5.6"
    catch {
	set url http://www.facebook.com/people/neophytos.demetriou
	set url http://www.phigita.net/
	#set url http://www.google.com/

	set body ""
	curl::transfer              \
	    -encoding $encoding     \
	    -timeout $timeout       \
	    -proxy $proxyurl        \
	    -proxyport $proxyport   \
	    -proxytype $proxytype   \
	    -useragent $useragent   \
	    -url $url               \
	    -bodyvar body
    } errmsg

    puts "[string length $body] $proxy errmsg=$errmsg"

}


puts [encoding convertfrom [encoding system] $body]
puts [encoding system]