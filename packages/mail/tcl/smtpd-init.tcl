package require mime
#::xo::lib::require tspam
#::xo::lib::require ttext

namespace eval ::xo::mail {

    variable spam_keywords {
	koi8
	gb2312
	valium
	vicodin
	barbiturate
	viagra
	penis
	enlargement
	cialis
	rolex
	{replica watches}
	erections
    }

}

proc mimeGetPartName {token} {
    set params [mime::getproperty $token params]
    set i [lsearch -exact $params name]
    if {$i >= 0} {
	incr i
	return [::mime::field_decode [lindex $params $i]]
    }
    return
}


proc decode_attachment_file {file} {
    global debug
    if {![catch {set f [open $file r]}]} {
	# if {$debug} {textOut "\t\tFile info:"}
	set l {}
	set decode 0
	set encoding text
	set data {}
	while {![eof $f]} {
            gets $f l
            set l $l
            if {!$decode} {
		# if {$debug && [string length $l]} {textOut "\t\t\t$l"}
		if {![string length $l]} {
		    #if {$encoding == "text"} { break }
		    set decode 1
		} elseif {[lindex [string map {\" {}} $l] 0] == "Content-Transfer-Encoding:"} {
		    set encoding [lindex [string map {\" {}} $l] 1]
		}

            } else {
		set data "[set data]\n$l"
            }
	}
	seek $f 0 start
	close $f
	if {$decode && $encoding == "base64"} {
            set f [open $file w+]
            fconfigure $f -translation binary
            set data [base64::decode $data]
            puts -nonewline $f $data
            close $f
	} elseif {$decode} {
            set f [open $file w+]
            #fconfigure $f -translation binary
            #set data [base64::decode $data]
            puts -nonewline $f $data
            close $f
	}
    }
}


proc ::xo::mail::parse_part_t {token resultVar} {

    upvar $resultVar result


    if { [catch {
	set content [mime::getproperty $token content]
    } errmsg] } {
	ns_log error "parse_part_t (processing continues): token=$token errmsg=$errmsg"
	return
    }


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
	application/vnd.ms-excel -
	application/zip {
	    # save attachments
	    set attachment_count [incr result(attachment_count)]
	    set part_name [mimeGetPartName $token]
	    set attachment_id $result(msgname).${attachment_count}
	    set attachment_file [file join /web/data/mail/attachment/ ${attachment_id}]
	    if { ![file exists $attachment_file] } {
		set f [open $attachment_file w+]
		::mime::copymessage $token $f
		close $f
		decode_attachment_file $attachment_file
	    }
	    
	    lappend result(attachments) [list $attachment_id $part_name $content]
	}
	text/html {
	    # How do you want to handle this?

	    set html [::mime::getbody $token]

	    #if { [is_uuencoded $body] } { }
	    #puts --------------------------------------\n$body

	    array unset params
	    set params(charset) ""
	    array set params [::mime::getproperty $token params]
	    if { $params(charset) ne {} } {
		set html [encoding convertfrom [::mime::reversemapencoding $params(charset)] $html]
	    }
	    append result(html) $html ;# ad_html_to_text -- $html
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

	    append result(text) $body ;# mail_to_html $body
	}
	message/delivery-status -
	multipart/digest -
	multipart/related -
	multipart/report -
	multipart/alternative -
	multipart/mixed {
	    set parts [mime::getproperty $token parts]
	    foreach part ${parts} {
		::xo::mail::parse_part_t $part result
	    }
	}
	text/calendar {
	    set body [mime::getbody $token]
	    array unset params
	    set params(charset) ""
	    array set params [::mime::getproperty $token params]
	    if { $params(charset) ne {} } {
		set body [encoding convertfrom [::mime::reversemapencoding $params(charset)] $body]
	    }
	    lappend result(calendar) $body
	}
	default {
	    #puts stderr "Whoops!  What is a '$content'?"
	    append result(text) "Whoops!  What is a '$content'?"
	}
    }
}


proc ::xo::mail::get_indexable_text {token {resultVar ""}} {

    if { $resultVar ne {} } {
	upvar $resultVar result
    } else {
	set result ""
    }

    if { [catch {
	set content [mime::getproperty $token content]
    } errmsg] } {
	ns_log error "get_indexable_text:  (processing continues): token=$token errmsg=$errmsg"
	return
    }

    # puts "Looking at $content."
    switch $content {
	text/html {
	    # How do you want to handle this?
	    set body [::mime::getbody $token]

	    #if { [is_uuencoded $body] } { }
	    #puts --------------------------------------\n$body

	    array unset params
	    set params(charset) ""
	    array set params [::mime::getproperty $token params]
	    if { $params(charset) ne {} } {
		set body [encoding convertfrom [::mime::reversemapencoding $params(charset)] $body]
	    }
	    append result [ns_striphtml ${body}]
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
	    append result $body
	}
	message/delivery-status -
	multipart/digest -
	multipart/related -
	multipart/report -
	multipart/alternative -
	multipart/mixed {
	    set parts [mime::getproperty $token parts]
	    foreach part ${parts} {
		get_indexable_text $part result
	    }
	}
	text/calendar {
	    set body [mime::getbody $token]
	    array unset params
	    set params(charset) ""
	    array set params [::mime::getproperty $token params]
	    if { $params(charset) ne {} } {
		set body [encoding convertfrom [::mime::reversemapencoding $params(charset)] $body]
	    }
	    append result $body
	}
	default {
	    #puts stderr "Whoops!  What is a '$content'?"
	}
    }
    return $result
}



proc ::xo::mail::parse_message {filename messageVar} {
    upvar $messageVar message

    array set message [list subject "" date "" from "" to "" text "" html "" attachments "" calendar "" attachment_count 0 header ""]

    # msgname is used by parse_part_t, for naming attachments
    set message(msgname) [file tail $filename]
    set msg [::mime::initialize -file $filename]
    set message(token) $msg
    set message(header) [::mime::getheader $msg]
    foreach {key valuelist} $message(header) {
	foreach value $valuelist {
	    append message([string tolower ${key}]) $value
	}
    }

    parse_part_t $msg message

    ::mime::finalize $msg

}

proc ::xo::mail::is_spam {filename} {

    #set filename "/web/data/mail/cur/20111026T174414.1319651054_7fe1f893e700"
    #TODO: set is_spam [tspam::classify $filename]
    set is_spam 0
    return $is_spam
}

proc ::xo::mail::is_spam_by_rules {messageVar langclass} {


    if { ${langclass} ne {} } {
	set lang_ok 0
	set accepted_langclass_list {en.utf8 sco.utf8 el.utf8}
	foreach accepted_langclass $accepted_langclass_list {
	    if { ${accepted_langclass} in ${langclass} } {
		set lang_ok 1
		break
	    }
	}
	if { !${lang_ok} } {
	    return 1 ;# it is spam
	}
    }

    variable spam_keywords 
    upvar $messageVar message

    set subject $message(subject)

    set spam_p 0
    foreach spam_keyword $spam_keywords {
	if { [string match -nocase "*${spam_keyword}*" $subject] } {
	    set spam_p 1
	    break
	}
    }
    return $spam_p
}

proc ::xo::mail::maildir {} {
    return "/web/local-data/mail"
}

proc ::xo::mail::process_incoming_mail {} {

    set maildir [::xo::mail::maildir]
    set newdir [file join $maildir new]
    set tmpdir [file join $maildir tmp]
    set curdir [file join $maildir cur]
    set errdir [file join $maildir err]

    set mail_file [file join $maildir message-list.txt]
    set index_file [file join $maildir message-list.idx]

    # move files back to newdir
    set filelist [lsort -increasing [glob -nocomplain -directory $tmpdir *]]
    foreach filename $filelist {
	file rename -force $filename $newdir
    }


    set index_map [list]
    set fp [open $mail_file "a"]
    #fconfigure $fp -encoding binary

    # process each file in newdir
    set filelist [lsort -increasing [glob -nocomplain -directory $newdir *]]
    foreach newfile $filelist {
	set msgname [file tail $newfile]
	set tmpfile [file join $tmpdir $msgname]

	ns_log notice "msgname=$msgname newfile=$newfile tmpfile=$tmpfile tmpdir=$tmpdir curdir=$curdir"

	# first, move file under tmpdir
	file rename -force $newfile $tmpfile

	# parse subject, sender, and recipient

	if { [catch {
	    parse_message $tmpfile message
	    set date $message(date)
	    set from $message(from)
	    set attachments $message(attachments)
	    set calendar $message(calendar)
	    set text $message(text)

	    # Sender (the array) is of the form:
	    #property    value
	    #========    =====
	    #address     local@domain
	    #comment     822-style comment
	    #domain      the domain part (rhs)
	    #error       non-empty on a parse error 
	    #group       this address begins a group
	    #friendly    user-friendly rendering
	    #local       the local part (lhs)
	    #memberP     this address belongs to a group
	    #phrase      the phrase part
	    #proper      822-style address specification
	    #route       822-style route specification (obsolete)


	    set sender_parts [::mime::parseaddress $from]
	    if { $sender_parts ne {} } {
		array set sender [lindex ${sender_parts} 0]
		set from [list $sender(address) [::mime::field_decode $sender(friendly)]]
	    } else {
		set from ""
	    }

            ### binary scan [join [mime::parseaddress ${from}]] a* address

	    # set to $message(to)
	    set subject [::mime::field_decode $message(subject)]
	} errMsg] } {
	    ns_log notice "$msgname errMsg=$errMsg"
	    file rename -force $tmpfile $errdir
	    continue
	}

	if { $from eq {} && $subject eq {} } { 
	    ns_log notice "$msgname - without sender and subject"
	    file rename -force $tmpfile $errdir
	    continue 
	}


	#if {0} {
	#    set otherfile /web/tmp/test-spam.txt
	#    set other_fp [open $otherfile w]
	#    foreach {key valuelist} $message(header) {
	#	puts -nonewline $other_fp "${key}: "
	#	foreach value $valuelist {
	#	    puts -nonewline $other_fp ${value}
	#	}
	#	puts $other_fp ""
	#    }
	#    puts $other_fp ""
	#    puts $other_fp $message(text)
	#    puts $other_fp $message(html)
	#    close $other_fp
	#}


	set indexable_text ""
	get_indexable_text $message(token) indexable_text

	set langclass ""
	if { $indexable_text ne {} || ${subject} ne {} } {
	    set langclass [::ttext::langclass ${subject}\n${indexable_text}]
	}

	set spam_p [::xo::mail::is_spam_by_rules message $langclass]
	if { !$spam_p } {
	    set spam_p [::xo::mail::is_spam $tmpfile]
	}

	set offset [tell $fp]
	lappend index_map $msgname $offset
	# insert info into db/message-list
	#puts $fp [list $msgname $date $spam_p $from $subject $attachments $calendar]
	::xo::io::writeVarText $fp [list $msgname $date $spam_p $langclass $from $subject $attachments $calendar] utf-8

	# move file into curdir
	file rename -force $tmpfile $curdir
    }

    close $fp
    set fp [open $index_file "a"]
    # TODO: write offsets in binary (not text) form
    ::xo::io::writeString $fp $index_map
    close $fp
    
}

if { [ns_config ns/server/[ns_info server] is_mail_server_p 0] } {
    #ns_schedule_proc -once 0 ::mail_server do -async init_mail_server
    #ad_after_server_initialization init_mail_server {
	#::mail_server do -async init_mail_server
    #init_mail_server
    #}

    ns_schedule_proc 90 ::xo::mail::process_incoming_mail

}
