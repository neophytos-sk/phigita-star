# Simple httpd server 
# (based on minihttpd by Brent Welch and phttpd by Zoran Vasiljevic)

package require Thread


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

    set initcmd {
        package require core
        package require httpd
    }

    # Create thread pool with max 8 worker threads.
    # Using the internal C-based thread pool
    set Httpd(tpid) [tpool::create -maxworkers 8 -initcmd $initcmd]

    # init thread
    tpool::post -detached $Httpd(tpid) [list set _ {}]

    array set Httpd [list root $root default $default]
    if {![info exists Httpd(port)]} {
        set Httpd(host) $host
        set Httpd(port) $port
        set Httpd(listen) [socket -server Httpd_SockAcceptHelper -myaddr $host $port]
        set Httpd(accepts) 0
    }
    return $Httpd(port)
}

proc Httpd_SockGets {sock strVar} {
    upvar $strVar str

    set str {}
    set maxHeaderLineLen 1000
    set readCount 0
    set ch {}
    while { 1 } {
        set ch [chan read $sock 1]
        if { $ch eq "\n" } {
            break
        } elseif { $ch eq {} } {
            log "ch is empty string"
            return -1
        }
        append str $ch
        incr readCount

        if { $readCount >= $maxHeaderLineLen } {
            log "readCount (=$readCount) >= maxHeaderLineLen (=$maxHeaderLineLen)"
            return -1
        }
    }
    # puts str=$str
    return $readCount

}

# Helper procedure to solve Tcl shared-channel bug when responding
# to incoming connection and transfering the channel to other thread(s).
# (copied from the Thread package, see phttpd.tcl)

proc Httpd_SockAcceptHelper {sock ipaddr port} {
    after idle [list Httpd_SockAccept $sock $ipaddr $port]
}

# Accept a new connection from the server and set up a handler
# to read the request from the client.

proc Httpd_SockAccept {sock ipaddr port} {
    # log $sock
    global Httpd

    incr Httpd(accepts)
	# upvar #0 Httpd$sock data
    # set data(ipaddr) $ipaddr

    fconfigure $sock -blocking 0 -translation {auto crlf}

	#
    # Detach the socket from current interpreter/tnread.
    # One of the worker threads will attach it again.
    #

    thread::detach $sock

    #
    # Send the work ticket to threadpool.
    # 

    tpool::post -detached $Httpd(tpid) [list Httpd_SockTicket $sock]

}

# Job ticket to run in the thread pool thread.
proc Httpd_SockTicket {sock} {
    # log $sock
	thread::attach $sock

    fileevent $sock readable [list Httpd_SockRead $sock]

    # End of processing is signalized here.
    # This will release the worker thread.
    vwait ::done
}

# read data from a client request

proc Httpd_SockRead { sock } {
    upvar #0 Httpd$sock data

    set data(state) "SockRead"
    set maxinput [expr { 1024*1024 }]
    set maxline 256
    set maxheaders 128

    # deletes readable event handler
    fileevent $sock readable {}

    # 1. loops instead of waiting for readable file event
    # 2. ensures socket still exists
    while { [info exists data] } {

        # http request consists of two parts, the headers and the form data,
        # once the headers have been read, data(form_data) is set to {}

        if { ![info exists data(form_data)] } {

            set readCount [Httpd_SockGets $sock line]
            if { $readCount == -1 } {
                Httpd_SockDone $sock
                return
            }

            incr data(headers_length) $readCount
            incr data(n_headers)

            if { $readCount > $maxline } {
                HttpdError $sock 400
                Httpd_SockDone $sock
                return
            }

            if { $data(n_headers) > $maxheaders } {
                HttpdError $sock 400
                Httpd_SockDone $sock
                return
            }

            if { $data(headers_length) > $maxinput } {
                HttpdError $sock 400
                Httpd_SockDone $sock
                return
            }

            # The request method (get, post, or head) is part of the first 
            # line of the headers, e.g. GET /somepage.html HTTP/1.0
            #
            # The condition is used here to check whether the first line 
            # has been read, as it is distinguished from the rest of the headers.

            if { ![info exists data(method)] } {

            # log line=$line

                lassign [split $line { }] data(method) data(url) proto_and_version
                lassign [split $proto_and_version {/}] data(proto) data(version)

                set data(method) [string tolower $data(method)]
                set data(proto) [string tolower $data(proto)]

                if { 
                    $data(method) ni {get post head}
                    || $data(proto) ne {http}
                    || $data(version) ni {1.0 1.1}
                } {
                    HttpdError $sock 400
                    Httpd_Log $sock Error "bad first line:$line"
                    Httpd_SockDone $sock
                    return
                }

                set index [string first {?} $data(url)]
                set data(query) [string range $data(url) [expr { $index + 1 }] end]

            } else {

            # an empty line separates the request headers from the body (form data),
            # a non-empty line is expected to be part of the headers

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

            # The Content-Length entity-header field indicates the size of the 
            # entity-body, in decimal number of OCTETs, sent to the recipient or, 
            # in the case of the HEAD method, the size of the entity-body that 
            # would have been sent had the request been a GET.
            #
            # http://www.w3.org/Protocols/rfc2616/rfc2616-sec4.html#sec4.4

            if { ![info exists data(form_data_length] } {
                array set headers $data(headers)
                set data(form_data_length) [value_if headers(content-length) "0"]

                if { $data(headers_length) + $data(form_data_length) > $maxinput } {
                    Httpd_SockDone $sock
                    return
                }

            }

            set len [string length $data(form_data)] 
            if { $len < $data(form_data_length) } {
                if { $len == 0 } {
                    set nl [chan read $sock 1]
                }
                append data(form_data) [chan read $sock]
            }

            if { [string length $data(form_data)] >= $data(form_data_length) } {
                # deletes readable event handler
                fileevent $sock readable {}

                Httpd_Respond $sock
            }

        }
    }

}

# Close a socket.
# We'll use this to implement keep-alives some day.

proc Httpd_SockDone { sock } {
    upvar #0 Httpd$sock data
    unset data
    close $sock

    log $sock

	variable done
	set done 1  ;# releases the request thread (see SockTicket proc)
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
        # Content-Type: multipart/form-data; boundary=kOy3aw5Lqc5AG4Q3 
        # --kOy3aw5Lqc5AG4Q3
        # Content-Disposition: form-data; name="msg2"
        #
        # test post-3
        # --kOy3aw5Lqc5AG4Q3
        # Content-Disposition: form-data; name="upload_file"; filename=""
        # Content-Type: application/octet-stream
        #
        #
        # --kOy3aw5Lqc5AG4Q3--

        # log boundary=$data(boundary)

        set boundary_len [string length $data(boundary)]
        set startIndex [string first "--$data(boundary)\r\n" $data(form_data)]
        while { $startIndex != -1 } {
            set startIndex [expr { $startIndex + 4 + $boundary_len }]
            set endIndex [string first "\r\n--$data(boundary)" $data(form_data) $startIndex]

            if { $endIndex == -1 } {
                break
            }

            # ParseMimePart
            set midIndex [string first "\r\n\r\n" $data(form_data) $startIndex]
            set part_hdrs [string range $data(form_data) $startIndex [expr { $midIndex - 1 }]]
            set part_body [string range $data(form_data) [expr { $midIndex + 4 }] [expr { $endIndex - 1}]]

            set part_hdrs_lst [list]
            foreach part_hdr [split $part_hdrs "\n"] {
                set part_hdr_index [string first {: } $part_hdr]
                set key [string range $part_hdr 0 [expr { $part_hdr_index - 1 }]]
                set val [string range $part_hdr [expr { $part_hdr_index + 2 }] end]
                lappend part_hdrs_lst [string tolower $key] $val
            }

            array set part_hdrs_a $part_hdrs_lst
            set content_disposition $part_hdrs_a(content-disposition)

            # Content-Disposition: form-data; name="msg"
            # Content-Disposition: form-data; name="upload_file"; filename="abc.pdf"
            # Content-Disposition: attachment; filename="fname.ext"

            lassign [split $content_disposition {;}] _disposition_type _parm_1 _parm_2
            lassign [split $_parm_1 {=}] _name_str_ part_name
            lassign [split $_parm_2 {=}] _filename_str_ part_filename
            set part_name [string trim $part_name "\""]

            # log form_data,content->part_name=$part_name

            if { $part_filename ne {} } {

                # set tmpfile /tmp/test.pdf
                # file delete -force -- $tmpfile
                # if {[catch {set fp [open $tmpfile {RDWR CREAT EXCL}]} errmsg]} {
                #     log errmsg=$errmsg
                # }
                # fconfigure $fp -translation binary
                # puts $fp $part_body
                # close $fp
                #
                # if filename string:
                # offset
                # length
                # headers

                set Httpd_FormData(${part_name}.filename) ${part_filename}
            }

            set Httpd_FormData(${part_name}) ${part_body}

            set startIndex $endIndex
            incr startIndex 2 ;# \r\n

        }

    } else {
        HttpdError $sock 400
        Httpd_Log $sock Error "unknown content type $content_type"
        Httpd_SockDone $sock
        return
    }

    # process query params along with posted params (if any)
    set xs [split $data(query) {&}]
    foreach x $xs {
        set index [string first {=} $x]
        set key [string range $x 0 [expr { $index - 1 }]]
        set val [url decode [string range $x [expr { $index + 1 }] end]]
        set Httpd_FormData(${key}) ${val}
    }

    # cleanup
    unset data(form_data)

}

# Respond to the query.

proc Httpd_Respond { sock } {
    global Httpd
    upvar #0 Httpd$sock data
    
set Httpd(root) [file normalize [file join [file dirname [info script]] ../www]]

    set path [Httpd_url2file $Httpd(root) $data(url)]

    if { $path eq {} } {
        HttpdError $sock 400
        Httpd_Log $sock Error "$data(url) invalid path"
        Httpd_SockDone $sock
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
        lappend data(outputheaders) "Cache-Control" "private, max-age=0"
        lappend data(outputheaders) "Content-Type" "text/html; charset=UTF-8"
        lappend data(outputheaders) "Date" [HttpdDate [clock seconds]]
        lappend data(outputheaders) "Expires" "-1"
        lappend data(outputheaders) "Server" "phigita"
        lappend data(outputheaders) "Status" "200 OK"
        lappend data(outputheaders) "Version" "HTTP/1.1"
        lappend data(outputheaders) "Connection" "close"
        puts $sock "HTTP/1.0 200 OK"
        foreach {key value} $data(outputheaders) {
            puts $sock "${key}: ${value}"
        }
        # puts $sock "Date: [HttpdDate [clock seconds]]"
        # puts $sock "Last-Modified: [HttpdDate [file mtime $path]]"
        # puts $sock "Content-Type: [HttpdContentType $path]"
        # puts $sock "Content-Length: [file size $path]"
        # puts $sock "Connection: close"
        puts $sock ""
        fconfigure $sock -translation binary -blocking $Httpd(sockblock)
        fconfigure $in -translation binary -blocking 1
        flush $sock
        #	copychannel $in $sock $Httpd(bufsize)
        fcopy $in $sock
        Httpd_SockDone $sock
    } else {
        HttpdError $sock 404
        Httpd_Log $sock Error "$data(url) $in"
        Httpd_SockDone $sock
    }
}

proc Httpd_handle_dynamic_page {sock path} {
    global Httpd
    upvar #0 Httpd$sock data

    Httpd_ParseFormData $sock

    lappend data(outputheaders) "Cache-Control" "private, max-age=0"
    lappend data(outputheaders) "Content-Type" "text/html; charset=UTF-8"
    lappend data(outputheaders) "Date" [HttpdDate [clock seconds]]
    lappend data(outputheaders) "Expires" "-1"
    lappend data(outputheaders) "Server" "phigita"
    lappend data(outputheaders) "Status" "200 OK"
    lappend data(outputheaders) "Version" "HTTP/1.1"
    lappend data(outputheaders) "Connection" "close"

    if { [catch { set html [::xo::tdp::process $path] } errmsg] } {
        HttpdError $sock 500
        Httpd_SockDone $sock
        return
    }

    lappend data(outputheaders) "Content-Length" [string length ${html}]

    # data(method)
    # data(form_data)
    #

    puts $sock "HTTP/1.1 200 OK"
    foreach {key value} $data(outputheaders) {
        puts $sock "${key}: ${value}"
    }
    puts $sock ""
    flush $sock

    puts $sock $html
    Httpd_SockDone $sock
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
