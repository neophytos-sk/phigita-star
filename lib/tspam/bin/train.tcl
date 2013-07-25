#! /usr/bin/tclsh

package require mime

proc msg_to_text {token {resultVar ""}} {

    if { $resultVar ne {} } {
        upvar $resultVar result
    } else {
        set result ""
    }

    set content [mime::getproperty $token content]
    #append result "(content=$content)"

    # puts "Looking at $content."
    switch $content {
        application/x-wordperfect6.1  -
        application/ppt  -
        application/pdf  -
        image/jpeg  -
        application/x-gzip  -
        application/msword  -
        application/octet-stream  -
        application/x-tar  -
        application/msword -
        application/x-wordperfect6.1 -
        application/x-msdownload -
        application/x-tar -
        application/zip {
            # Is there anything printable here?
            append result "--------------------------------------\n content-type=$content part-token=$token"
        }
        text/html {
            # How do you want to handle this?
            set body [::mime::getbody $token]
            array unset params
            set params(charset) ""
            array set params [::mime::getproperty $token params]
            if { $params(charset) ne {} } {
                set body [encoding convertfrom [::mime::reversemapencoding $params(charset)] $body]
            }
            append result "--------------------------------------\n$body"
        }
        message/rfc822 -
        TEXT/PLAIN -
        text/rfc822-headers -
        text/enriched -
        text/plain {

            set body [::mime::getbody $token]

            #if { [is_uuencoded $body] } { }
            #puts --------------------------------------\n$body

            array unset params
            set params(charset) ""
            array set params [::mime::getproperty $token params]
            if { $params(charset) ne {} } {
                set body [encoding convertfrom [::mime::reversemapencoding $params(charset)] $body]
            }
            append result "--------------------------------------\n$body"
        }
        message/delivery-status -
        multipart/digest -
        multipart/related -
        multipart/report -
        multipart/alternative -
        multipart/mixed {
            foreach part [mime::getproperty $token parts] {
                msg_to_text $part result
            }
        }
        default {
            #puts stderr "Whoops!  What is a '$content'?"
            append result "Whoops!  What is a '$content'?"
        }
    }
    return $result
}

proc msg_to_text_file {msg_file} {
    set msg [::mime::initialize -file $msg_file]

    set filename "/web/servers/service-phgt-0/lib/tspam/tmp/[file tail ${msg_file}].txt"
    if { [file exists $filename] } { return $filename }
    set fp [open $filename w]
    foreach {key valuelist} [::mime::getheader $msg] {
	puts -nonewline $fp "${key}: "
	foreach value $valuelist {
	    puts -nonewline $fp "$value "
        }
	puts $fp ""
    }
    puts $fp [msg_to_text $msg]
    close $fp

    ::mime::finalize $msg

    puts $filename
    return $filename
}


proc main {} {
    puts "argc=$::argc argv0=$::argv0"
    set package_dir "/web/servers/service-phgt-0/lib/tspam/"

    if { $::argc < 2 } {
	puts "Usage: $::argv0 (spam|ham) dirname"
	puts "dirname must either be a spam or a ham directory"
	exit
    }

    lassign $::argv spam_or_ham dirname

    if { $spam_or_ham eq {spam} } {
	set spam_p 1
	set flags "-s"
    } else {
	set spam_p 0
	set flags "-n"
    }

    set cmd [file join $package_dir bin bmf]
    set filelist [glob -directory $dirname *]
    foreach msg_file $filelist {
	puts msg_file=$msg_file
	if { [catch {exec ${cmd} {*}${flags} -f text -d [file join $package_dir dict] -m maildir -i $msg_file} errMsg] } {
	    # something wrong with ham
	    # puts $errMsg
	}
    }
    exit

    set maildir "/web/data/mail/"
    set filename [file join $maildir "message-list.txt"]

    set fp [open $filename]
    set data [read $fp]
    close $fp


    foreach {msg date spam_p from subject } $data {
	set msg_file [file join $maildir cur $msg]
	if { $spam_p } {
	    if { [catch {exec ./bmf -s -f text -d dict -m maildir -i [msg_to_text_file $msg_file]} errMsg] } {
		puts errMsg=$errMsg
	    }
	    #exec ./bmf -s -f db -d dict -m maildir -i $msg_file
	} else {
	    incr count
	    if { [catch {exec ./bmf -n -f text -d dict -m maildir -i [msg_to_text_file $msg_file]} errMsg] } {
		puts "count=$count msg_file=$msg_file"
	    }
	}
    }
}

main
