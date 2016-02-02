# Simple Sample httpd/1.0 server in 250 lines of Tcl
# Stephen Uhler / Brent Welch (c) 1996 Sun Microsystems
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.

# This is a working sample httpd server written entirely in TCL with the
# CGI and imagemap capability removed.  It has been tested on the Mac, PC
# and Unix.  It is intended as sample of how to write internet servers in
# Tcl. This sample server was derived from a full-featured httpd server,
# also written entirely in Tcl.
# Comments or questions welcome (stephen.uhler@sun.com)

# Httpd is a global array containing the global server state
#  root:	the root of the document directory
#  port:	The port this server is serving
#  listen:	the main listening socket id
#  accepts:	a count of accepted connections so far

# HTTP/1.0 error codes (the ones we use)

global HttpdErrors
global Httpd
global HttpdErrorFormat

array set HttpdErrors {
    204 {No Content}
    400 {Bad Request}
    404 {Not Found}
    503 {Service Unavailable}
    504 {Service Temporarily Unavailable}
}

array set Httpd {
    bufsize	32768
    sockblock	0
    handler,html Httpd_handle_static_page
    handler,tdp  Httpd_handle_dynamic_page
}

set HttpdErrorFormat {
    <title>Error: %1$s</title>
    Got the error: <b>%2$s</b><br>
    while trying to obtain <b>%3$s</b>
}


# Start the server by listening for connections on the desired port.

proc Httpd_Server {root {host localhost} {port 80} {default index.html}} {
    global Httpd

    array set Httpd [list root $root default $default]
    if {![info exists Httpd(port)]} {
        set Httpd(host) $host
        set Httpd(port) $port
        set Httpd(listen) [socket -server Httpd_SockAccept -myaddr $host $port]
        set Httpd(accepts) 0
    }
    return $Httpd(port)
}

proc Httpd_SockGets {sock strVar} {
    upvar $strVar str

    if {0} {
        set readCount [gets $sock str]
        puts str=$str
        return $readCount
    } else {

        set str {}
        set maxHeaderLineLen 1000
        set readCount 0
        set ch {}
        while { 1 } {
            set ch [chan read $sock 1]
            if { $ch eq "\n" } {
                break
            }
            append str $ch
            incr readCount

            if { $readCount >= $maxHeaderLineLen } {
                break
            }
        }
        puts str=$str
        return $readCount
    }

}

# Accept a new connection from the server and set up a handler
# to read the request from the client.

proc Httpd_SockAccept {newsock ipaddr port} {
    global Httpd
    upvar #0 Httpd$newsock data

    incr Httpd(accepts)

    fconfigure $newsock -blocking $Httpd(sockblock) \
        -buffersize $Httpd(bufsize) \
        -translation {auto crlf}

    Httpd_Log $newsock Connect $ipaddr $port

    set data(ipaddr) $ipaddr
    fileevent $newsock readable [list Httpd_SockRead $newsock]
}

# read data from a client request

proc Httpd_SockRead { sock } {
    upvar #0 Httpd$sock data

    set maxinput [expr { 1024*1024 }]
    set maxline 256
    set maxheaders 128

    set readCount [Httpd_SockGets $sock line]
    incr data(request_length) $readCount
    incr data(n_headers)

    if { $readCount > $maxline } {
        HttpdSockDone $sock
        return
    }

    if { $data(n_headers) > $maxheaders } {
        HttpdSockDone $sock
        return
    }

    if { $data(request_length) > $maxinput } {
        HttpdSockDone $sock
        return
    }

    append data(request_string) $line "|"

    # puts linelen=[string length $line]
    if { $line eq {} } {
        Httpd_SockHandle $sock
    }
}

proc Httpd_SockHandle {sock} {
    upvar #0 Httpd$sock data

    set index [string first "|" $data(request_string)]
    set line [string range $data(request_string) 0 [expr { $index - 1 }]]
    set readCount [string length $line]

    puts line=$line

    if {![info exists data(state)]} {
        if [regexp {(POST|GET) ([^?]+)\??([^ ]*) HTTP/1[.][0-9]} \
            $line x data(proto) data(url) data(query)] {

                set data(state) mime
                Httpd_Log $sock Query $line
                HttpdRespond $sock

        } else {
            HttpdError $sock 400
            Httpd_Log $sock Error "bad first line:$line"
            HttpdSockDone $sock
        }
        return
    }

    return

    # string compare $readCount 0 maps -1 to -1, 0 to 0, and > 0 to 1

    set state [string compare $readCount 0],$data(state),$data(proto)
    log state=$state
    switch -- $state {
        0,mime,GET	-
        0,query,POST	{ 
            HttpdRespond $sock 
        }
        0,mime,POST	{ set data(state) query }
        1,mime,POST	-
        1,mime,GET	{
            if [regexp {([^:]+):[ 	]*(.*)}  $line dummy key value] {
                set data(mime,[string tolower $key]) $value
            }
        }
        1,query,POST	{
            set data(query) $line
            HttpdRespond $sock
        }
        default {
            if [eof $sock] {
                Httpd_Log $sock Error "unexpected eof on <$data(url)> request"
            } else {
                Httpd_Log $sock Error "unhandled state <$state> fetching <$data(url)>"
            }
            HttpdError $sock 404
            HttpdSockDone $sock
        }
    }
}

# Close a socket.
# We'll use this to implement keep-alives some day.

proc HttpdSockDone { sock } {
    upvar #0 Httpd$sock data
    unset data
    close $sock
}

# Respond to the query.

proc HttpdRespond { sock } {
    global Httpd
    upvar #0 Httpd$sock data

    # transforms query to list of getopt arguments
    set ::argv $data(url)
    set xs [split $data(query) {&}]
    foreach x $xs {
        set parts [split $x {=}]
        append ::argv { } --[list [lindex $parts 0]] { } [list [lindex $parts 1]]
    }
    # log argv=$::argv

    set path [Httpd_url2file $Httpd(root) $data(url)]

    if { $path eq {} } {
        HttpdError $sock 400
        Httpd_Log $sock Error "$data(url) invalid path"
        HttpdSockDone $sock
        return
    }

    set ext [string trimleft [file extension $path] {.}]

    if { [info exists Httpd(handler,$ext)] } {
        $Httpd(handler,$ext) $sock $path
    } else {
        Httpd_handle_static_page $sock $path
    }
}

proc Httpd_handle_static_page {sock path} {
    global Httpd
    upvar #0 Httpd$sock data

    if {![catch {open $path} in]} {
        puts $sock "HTTP/1.0 200 Data follows"
        puts $sock "Date: [HttpdDate [clock clicks]]"
        puts $sock "Last-Modified: [HttpdDate [file mtime $path]]"
        puts $sock "Content-Type: [HttpdContentType $path]"
        puts $sock "Content-Length: [file size $path]"
        puts $sock ""
        fconfigure $sock -translation binary -blocking $Httpd(sockblock)
        fconfigure $in -translation binary -blocking 1
        flush $sock
        #	copychannel $in $sock $Httpd(bufsize)
        fcopy $in $sock
        HttpdSockDone $sock
    } else {
        HttpdError $sock 404
        Httpd_Log $sock Error "$data(url) $in"
        HttpdSockDone $sock
    }
}

proc Httpd_handle_dynamic_page {sock path} {
   package require templating
   set html [::xo::tdp::process $path]
   puts $sock $html
   HttpdSockDone $sock
}


# convert the file suffix into a mime type
# add your own types as needed

array set HttpdMimeType {
    {}		text/plain
    .txt	text/plain
    .htm	text/html
    .html	text/html
    .gif	image/gif
    .jpg	image/jpeg
    .xbm	image/x-xbitmap
}

proc HttpdContentType {path} {
    global HttpdMimeType

    set type text/plain
    catch {set type $HttpdMimeType([file extension $path])}
    return $type
}

# Generic error response.

proc HttpdError {sock code} {
    upvar #0 Httpd$sock data
    global HttpdErrors HttpdErrorFormat

    append data(url) ""
    set message [format $HttpdErrorFormat $code $HttpdErrors($code)  $data(url)]
    puts $sock "HTTP/1.0 $code $HttpdErrors($code)"
    puts $sock "Date: [HttpdDate [clock clicks]]"
    puts $sock "Content-Length: [string length $message]"
    puts $sock ""
    puts $sock $message
}

# Generate a date string in HTTP format.

proc HttpdDate {clicks} {
    return [clock format $clicks -format {%a, %d %b %Y %T %Z}]
}

# Log an Httpd transaction.
# This should be replaced as needed.

proc Httpd_Log {sock reason args} {
    global httpdLog httpClicks
    if {[info exists httpdLog]} {
        if ![info exists httpClicks] {
            set last 0
        } else {
            set last $httpClicks
        }
        set httpClicks [clock clicks]
        puts $httpdLog "[clock format [clock seconds]] ([expr $httpClicks - $last])\t$sock\t$reason\t[join $args { }]"
    }
}

# Convert a url into a pathname.
proc Httpd_url2file {homedir url} {
    global Httpd

    array set url_a [url split $url]
    set homedir [file normalize $homedir]
    set filename [file normalize [file join $homedir $url_a(path)]]

    # ensures that normalized homedir + url_a(path) is under homedir
    # i.e. checks for parent dir dots (..)
    set len [string length $homedir]
    if { [string range $filename 0 [expr { $len - 1 }]] ne $homedir } {
        error "url2file: must be under homedir (=$homedir)"
    }

    if { [file isdirectory $filename] } {
        set filename [file join $filename $Httpd(default)]
    }
    return $filename
}

# Decode url-encoded strings.


proc bgerror {msg} {
    global errorInfo
    puts stderr "bgerror: $msg\n$errorInfo"
}
