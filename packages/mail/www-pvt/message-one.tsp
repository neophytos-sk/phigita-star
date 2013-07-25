::xo::kit::require_secure_conn

package require mime

namespace eval ::xo::mail {;}





ad_page_contract {
    @author Neophytos Demetriou
} {
    msg_id:trim,notnull
    {with_header:boolean "f"}
}

set maildir [::xo::mail::maildir]
set filename [file join $maildir cur $msg_id]

set mail_file [file join $maildir message-list.txt]
set index_file [file join $maildir message-list.idx]

set fp [open $index_file]
while { ![eof $fp] } {
    if { [catch {array set index [::xo::io::readString $fp]} errMsg] } {
	break
    }
}
close $fp


set offset $index($msg_id)
set fp [open $mail_file]
fconfigure $fp -encoding binary
seek $fp $offset
#::xo::io::readString $fp message_list
::xo::io::readVarText $fp message_list utf-8
close $fp


set msg [::mime::initialize -file $filename]

lassign $message_list msgname date spam_p langclass from subject attachments calendar

tmpl::master -title $subject -context_bar [ad_context_bar "One Message"] {

    p
    div { b { t "Date: " }; t $date }
    div { b { t "Spam: " }; t [::util::decode $spam_p 0 No 1 Yes] }
    div { b { t "LangClass: "}; t $langclass }
    div { b { t "From: " }; t $from }
    div { b { t "Subject: " }; t $subject }
    if { $attachments ne {} } {
	div { 
	    b { t "Attachments: " }
	    foreach attachment $attachments {
		if { [incr count] > 1 } {
		    t ", "
		}
		lassign $attachment attachment_id attachment_name attachment_type
		set attachment_url "attachment/${attachment_name}?attachment_id=${attachment_id}&attachment_type=${attachment_type}"
		a -href $attachment_url {
		    t $attachment_name
		}
	    }
	}
    }
    if { $calendar ne {} } {
	div { b { t "Calendar: " }; t $calendar }
    }

    p

    if { $with_header } {
	foreach {key valuelist} [::mime::getheader $msg] {
	    div {
		b { t "${key}: " }
		foreach value $valuelist {
		    t "[::mime::field_decode $value] "
		}
	    }
	}
    }

    pre {
	code {
	    nt [::xo::mail::render_part_t $msg]
	}
    }
}

::mime::finalize $msg
