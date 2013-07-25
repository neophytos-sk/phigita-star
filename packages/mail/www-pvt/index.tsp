#::xo::kit::reload [acs_root_dir]/lib/nssmtpd/tcl/nssmtpd-procs.tcl
#::xo::kit::reload [acs_root_dir]/packages/kernel/tcl/20-xo/00-utils/15-KitUtils-procs.tcl



::xo::kit::require_secure_conn

package require mime

ad_page_contract {
    @author Neophytos Demetriou
} {
    {show_spam_p:boolean,notnull "f"}
    {offset:naturalnum "0"}
    {limit:naturalnum "100"}
}

set maildir [::xo::mail::maildir]

#set message_files [lsort -decreasing [glob -nocomplain -tails -directory $maildir *]]
set mail_file [file join $maildir message-list.txt]
set fp [open $mail_file]
# set data [read $fp]

set message_list [list]
while {![eof $fp]} {
    if { [catch {::xo::io::readVarText $fp line utf-8} errMsg] } {
	break
    }
    lappend message_list $line
}
set message_list [lreverse $message_list]

::xo::html::add_style {
    .button {background:#a00;color:#fff;font-weight:bold;padding:3px 5px 3px 5px;text-decoration:none;}
}

tmpl::master -title "Your Mail" {

    a -href "message-compose" -class button { t "COMPOSE" }

    table {
	foreach line $message_list {
	    # set line [encoding convertfrom utf-8 $line]
	    lassign $line msg_id date spam_p langclass from subject attachments calendar

	    if { $spam_p && !$show_spam_p } { continue }
	    incr count
	    if { $count < $offset } continue
	    if { $count - $offset > $limit } break
	    tr {
		td -width "4%" {
		    if { $spam_p } {
			b { t "SPAM " }
		    }
		}
		td -style "width:4%;" {
		    lassign $from address friendly
		    #set friendly [::smtpd::decodeHdr $friendly]
		    # friendly in message-list.txt has already been decoded
		    set friendly "$friendly"
		    div -title $address {
			t [::util::coalesce $friendly $address]
		    }
		}
		td {
		    a -href "message-one?msg_id=$msg_id" {
			#t [::util::coalesce [::smtpd::decodeHdr $subject] "Untitled"]
			# subject in message-list.txt has already been decoded
			t [::util::coalesce $subject "Untitled"]
		    }
		}
		td {
		    if { $attachments ne {} } {
			img -src /graphics/paperclip.gif -width 15 -height 15
		    }
		    if { $calendar ne {} } {
			img -src /graphics/calendar/calbr1.gif
		    }
		}
		td -nowrap "" -align "right" {
		    lassign [split $date ".+"] timestamp_ansi __microseconds_and_tz__
		    set seconds [clock scan $timestamp_ansi]
		    # if seconds > start_of_today_seconds then show time
		    # i.e. clock format $seconds -format "%l:%M%p"
		    # else clock format $seconds -format "%b %d"
		    t [clock format $seconds -format "%b %d %l:%M%p"]
		}
	    }
	}
    }
}


close $fp


