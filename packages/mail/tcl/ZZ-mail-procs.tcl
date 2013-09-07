namespace eval mail {;}
namespace eval mail::msg {;}

proc mail::msg::pretty_size { size } {
    return "[format "%.1f" [expr $size/1024.0]]KB"
}

package require mime



proc mail_decode_body { username m mailid msgid bodydata { bodyid "" } } {

    set struct(type) text
    set struct(body.charset) iso-8859-1
    array set struct ${bodydata}

    if { $struct(type) == "multipart" } {
      set body ""
      set files ""
	for { set i 1 } { $i <= $struct(part.count) } { incr i } {
	    array unset part
	    set part(body.charset) iso-8859-1
	    array set part $struct(part.$i)

	    if {[string equal [string tolower $struct(subtype)] alternative] && [string equal [string tolower $part(subtype)] "html"]} continue;

	    if { $bodyid != "" } { set partid "$bodyid.$i" } else { set partid $i }
	    if { $part(type) == "multipart" } {
		append body [mail_decode_body ${username} ${m} $mailid $msgid $struct(part.$i) $partid]
		continue
	    }
	    if { [info exists part(body.name)] } {
		append files "<TR><TD><a href=\"attachment/[mime::field_decode $part(body.name)]?id=${msgid}&m=${m}&part=${partid}&username=${username}\">[mime::field_decode $part(body.name)]</a></TD>
		    <TD>[string tolower \"$part(type)/$part(subtype)\"]</TD>
		    <TD>[mail::msg::pretty_size $part(bytes)]</TD>
		    </TR>"
	    } else {
		append body [mail_format_body [::encoding convertfrom [::mime::reversemapencoding $part(body.charset)] [ns_imap body $mailid $msgid $partid -decode -flags UID]] $part(subtype)]
	    }
	    append body "\n"
	}
	if { $files != "" } {
        append body "<TABLE WIDTH=100% BORDER=0><TR CLASS=osswebFirstRow><TD COLSPAN=3><B>Attachments</B></TD></TR>" $files "</TABLE>"
	}
    } else {
	if { $bodyid != "" } { set partid "$bodyid.1" } else { set partid 1 }
	set body [mail_format_body [::encoding convertfrom [::mime::reversemapencoding $struct(body.charset)] [ns_imap body $mailid $msgid $partid -decode -flags UID]] $struct(subtype)]
    }
    return $body
}

# Formats body text according to given type, used for putting
# email body into display form, takes care about all dangerous tags/symbols
proc mail_format_body { body type } {
    return [ns_quotehtml $body]
    switch $type {
	HTML {
	    set body [::util::striphtml $body]
	}
	default {
	    set body [ns_quotehtml ${body}]
	}
    }
    return $body
}

proc mail_to_html { body } {
    regsub -nocase -all {(^|[^a-zA-Z0-9]+)(http|https)(://[^\(\)"<>\s]+)} $body "\\1\x001sTaRtUrL\\2\\3eNdUrL\x001" body
    regsub -all {([]!?.:;,<>\(\)\}"'-]+)(eNdUrL\x001)} $body {\2\1} body
    regsub -all {\x001sTaRtUrL([^\x001]*)eNdUrL\x001} $body {<a href="\1">\1</a>} body
    set body [string map {"\n" "<br />"} $body]
}

# Returns a list with all IMAP folders, performs
# caching of the list for some time
proc mail_folders { mailid username } {
    set maildir INBOX. 
      set folders [list]
      set index [string length $maildir]
      foreach { name flags } [ns_imap list $mailid "[ns_imap getparam $mailid mailbox.host]" $maildir*] {
        if { [string match "*noselect*" $flags] } { continue }
        set name [string range $name $index end]
        lappend folders "<a href=.?m=${name}&username=${username}>$name</a>"
      }
    
    set folders [lsort $folders]
    return $folders
}

namespace eval ::xo::mail {;}




# this looks extremely similar to parse_part_t
proc ::xo::mail::render_part_t {token {resultVar ""}} {

    if { $resultVar ne {} } {
	upvar $resultVar result
    } else {
	set result ""
    }

    if { [catch {
	set content [mime::getproperty $token content]
    } errmsg] } {
	ns_log error "render_part_t (processing continues): token=$token errmsg=$errmsg"
	return
    }


    # puts "Looking at $content."
    switch $content {
	application/x-wordperfect6.1  -
	application/ppt  -
	application/pdf  -
	image/jpeg  -
	image/gif -
	image/png -
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
	    # Is there anything printable here?
	    set part_name [::util::coalesce [mimeGetPartName $token] untitled]
	    append result "--------------------------------------\n content-type=$content part-token=$token part-name=$part_name"

	}
	text/html {
	    # How do you want to handle this?
	    if {1} {
		set body [::mime::getbody $token]

		#if { [is_uuencoded $body] } { }
		#puts --------------------------------------\n$body

		array unset params
		set params(charset) ""
		array set params [::mime::getproperty $token params]
		if { $params(charset) ne {} } {
		    set body [encoding convertfrom [::mime::reversemapencoding $params(charset)] $body]
		}
		append result "--------------------------------------\n content-type=$content \n [ad_html_to_text -- $body]"
	    }
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
	    append result "--------------------------------------\n[mail_to_html $body]"
	}
	message/delivery-status -
	multipart/digest -
	multipart/related -
	multipart/report -
	multipart/alternative -
	multipart/mixed {
	    foreach part [mime::getproperty $token parts] {
		render_part_t $part result
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
	    append result "calendar: $body"
	}
	default {
	    #puts stderr "Whoops!  What is a '$content'?"
	    append result "Whoops!  What is a '$content'?"
	}
    }
    return $result
}
