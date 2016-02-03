# Simple Sample httpd server (based on minihttpd by Brent Welch)

# Httpd is a global array containing the global server state
#  root:	the root of the document directory
#  port:	The port this server is serving
#  listen:	the main listening socket id
#  accepts:	a count of accepted connections so far


global HttpdErrors
global HttpdErrorFormat

# HTTP/1.0 error codes (the ones we use)
array set HttpdErrors {
    204 {No Content}
    400 {Bad Request}
    404 {Not Found}
    500 {Server Internal Error}
    503 {Service Unavailable}
    504 {Service Temporarily Unavailable}
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
        # puts str=$str
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
        # puts str=$str
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

    if { ![info exists data(form_data)] } {

        set maxinput [expr { 1024*1024 }]
        set maxline 256
        set maxheaders 128

        set readCount [Httpd_SockGets $sock line]
        incr data(headers_length) $readCount
        incr data(n_headers)

        if { $readCount > $maxline } {
            HttpdSockDone $sock
            return
        }

        if { $data(n_headers) > $maxheaders } {
            HttpdSockDone $sock
            return
        }

        if { $data(headers_length) > $maxinput } {
            HttpdSockDone $sock
            return
        }

        if { ![info exists data(method)] } {

            lassign [split $line { }] data(method) data(url) proto_and_version
            lassign [split $proto_and_version {/}] data(proto) data(version)

            set data(method) [string tolower $data(method)]
            set data(proto) [string tolower $data(proto)]

            if { 
                $data(method) ni {post get}
                || $data(proto) ne {http}
                || $data(version) ni {1.0 1.1}
            } {
                HttpdError $sock 400
                Httpd_Log $sock Error "bad first line:$line"
                HttpdSockDone $sock
                return
            }

            set index [string first {?} $data(url)]
            set data(query) [string range $data(url) [expr { $index + 1 }] end]

        } else {
            if { $line ne {} } {
                set index [string first {: } $line]
                set key [string range $line 0 [expr { $index - 1 }]]
                set value [string range $line [expr { $index + 2 }] end]
                lappend data(headers) [string tolower $key] $value
            } else {
                set data(form_data) {}
                fconfigure $sock -translation binary
            }
        }

    } else {


        # The Content-Length entity-header field indicates the size of the entity-body,
        # in decimal number of OCTETs, sent to the recipient or, in the case of the HEAD
        # method, the size of the entity-body that would have been sent had the request
        # been a GET.
        #
        # http://www.w3.org/Protocols/rfc2616/rfc2616-sec4.html#sec4.4

        if { ![info exists data(form_data_length] } {
            array set headers $data(headers)
            set data(form_data_length) [value_if headers(content-length) "0"]

            set maxinput [expr { 1024*1024 }]
            if { $data(headers_length) + $data(form_data_length) > $maxinput } {
                HttpdSockDone $sock
                return
            }

        }

        if { [string length $data(form_data)] < $data(form_data_length) } {
            set nl [read $sock 1]
            append data(form_data) [read $sock]
        }
        
        if { [string length $data(form_data)] >= $data(form_data_length) } {
            Httpd_Respond $sock
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

proc Httpd_ParseFormData {sock} {
    global Httpd
    global Httpd_FormData
    array unset Httpd_FormData
    upvar #0 Httpd$sock data

    array set headers $data(headers)
    set content_type_hdr [value_if headers(content-type) ""]
    lassign [split $content_type_hdr {;}] content_type boundary_hdr

    if { $content_type eq {} || $content_type eq {application/x-www-form-urlencoded} } {

        ###  enctype="application/x-www-form-urlencoded" (default)
        #
        # Content-Type: application/x-www-form-urlencoded
        #
        # msg2=test+post-2&msg3=this+is+a+test

        if { $data(query) ne {} && $data(form_data) ne {} } {
            append data(query) {&}
        }

        append data(query) $data(form_data)

    } elseif { $content_type eq {multipart/form-data} } {

        # The content type "application/x-www-form-urlencoded" is inefficient 
        # for sending large quantities of binary data or text containing non-ASCII 
        # characters. The content type "multipart/form-data" should be used for
        # submitting forms that contain files, non-ASCII data, and binary data.
        #
        # https://www.w3.org/TR/html401/interact/forms.html#h-17.13.4.2

        set index [string first {=} $boundary_hdr]
        set data(boundary) [string range $boundary_hdr [expr { $index + 1 }] end]


        ### form enctype="multipart/form-data"
        #
        # Content-Type: multipart/form-data; boundary=----kOy3aw5Lqc5AG4Q3 
        # ------kOy3aw5Lqc5AG4Q3
        # Content-Disposition: form-data; name="msg2"
        #
        # test post-3
        # ------kOy3aw5Lqc5AG4Q3
        # Content-Disposition: form-data; name="upload_file"; filename=""
        # Content-Type: application/octet-stream
        #
        #
        # ------kOy3aw5Lqc5AG4Q3--

        # log boundary=$data(boundary)

        set boundary_len [string length $data(boundary)]
        set startIndex [string first "--$data(boundary)\r\n" $data(form_data)]
        while { $startIndex != -1 } {
            set startIndex [expr { $startIndex + 4 + $boundary_len }]
            set endIndex [string first "\r\n--$data(boundary)" $data(form_data) $startIndex]

            if { $endIndex == -1 } {
                break
            }

            set part [string range $data(form_data) $startIndex [expr { $endIndex - 1 }]]

            # ParseMimePart
            set midIndex [string first "\r\n\r\n" $part]
            set part_hdrs [string range $part 0 [expr { $midIndex - 1 }]]
            set part_body [string range $part [expr { $midIndex + 4 }] end]

            log [list startIndex=$startIndex midIndex=$midIndex endIndex=$endIndex]
            # log part=$part
            # log part_hdrs=$part_hdrs
            # log part_body=$part_body

            set part_hdrs_lst [list]
            foreach part_hdr [split $part_hdrs "\n"] {
                set part_hdr_index [string first {: } $part_hdr]
                set key [string range $part_hdr 0 [expr { $part_hdr_index - 1 }]]
                set val [string range $part_hdr [expr { $part_hdr_index + 2 }] end]
                lappend part_hdrs_lst [string tolower $key] [split $val {;}]
            }
            array set part_hdrs_a $part_hdrs_lst
            set content_disposition $part_hdrs_a(content-disposition)
            lassign $content_disposition _disposition_type _parm_1 _parm_2
            lassign [split $_parm_1 {=}] _name_str_ name
            lassign [split $_parm_2 {=}] _filename_str_ filename

            # assert { $_name_str eq {name} }

            log form_data,content->name=$name

            # TODO: use array structure for parsed form data
            set key [string trim ${name} "\""]
            set val ${part_body}
            set Httpd_FormData(${key}) ${val}

            set startIndex $endIndex
            incr startIndex 2 ;# \r\n

        }

    } else {
        HttpdError $sock 400
        Httpd_Log $sock Error "unknown content type $content_type"
        HttpdSockDone $sock
        return
    }

    # process query params along with posted params (if any)
    set xs [split $data(query) {&}]
    foreach x $xs {
        lassign [split $x {=}] key val
        set Httpd_FormData(${key}) ${val}
    }


}

# Respond to the query.

proc Httpd_Respond { sock } {
    global Httpd
    upvar #0 Httpd$sock data
    
    Httpd_ParseFormData $sock

    set path [Httpd_url2file $Httpd(root) $data(url)]

    if { $path eq {} } {
        HttpdError $sock 400
        Httpd_Log $sock Error "$data(url) invalid path"
        HttpdSockDone $sock
        return
    }

    set ext [string trimleft [file extension $path] {.}]

    set data(outputheaders) {}
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
        puts $sock "HTTP/1.0 200 OK"
        puts $sock "Date: [HttpdDate [clock seconds]]"
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
    global Httpd
    upvar #0 Httpd$sock data

    package require templating

    if { [catch { set html [::xo::tdp::process $path] } errmsg] } {
        HttpdError $sock 500
        HttpdSockDone $sock
        return
    }

    # data(method)
    # data(form_data)
    #

    puts $sock "HTTP/1.1 200 OK"
    lappend data(outputheaders) "Cache-Control" "private, max-age=0"
    lappend data(outputheaders) "Content-Type" "text/html; charset=UTF-8"
    lappend data(outputheaders) "Date" [HttpdDate [clock seconds]]
    lappend data(outputheaders) "Expires" "-1"
    lappend data(outputheaders) "Server" "phigita"
    lappend data(outputheaders) "Status" "200 OK"
    lappend data(outputheaders) "Version" "HTTP/1.1"
    foreach {key value} $data(outputheaders) {
        puts $sock "${key}: ${value}"
    }
    puts $sock ""
    flush $sock

    puts $sock $html
    HttpdSockDone $sock
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
    puts $sock "Date: [HttpdDate [clock seconds]]"
    puts $sock "Content-Length: [string length $message]"
    puts $sock ""
    puts $sock $message
}

# Generate a date string in HTTP format.

proc HttpdDate {seconds} {
    return [clock format $seconds -format {%a, %d %b %Y %T %Z}]
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
