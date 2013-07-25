package require mime


ad_page_contract {
    @author Neophytos Demetriou
} {
    {offset:integer "0"}
    {limit:integer "25"}
    {m:trim ""}
    {username:trim,notnull "k2pts"}
}

if { -1 == [lsearch "webmaster k2pts" $username] } {
	doc_return 200 text/plain "wrong username"
	return
}
###############################################################################



# Open new connection
#set mailbox {{localhost/ssl/novalidate-cert}INBOX.30-groups.openacs}
#set mailbox [format {{localhost/ssl/novalidate-cert}%s} [join "INBOX ${m}" .]]
set mailbox [format {{127.0.0.1/ssl/novalidate-cert}%s} [join "INBOX ${m}" .]]

set mailid [ns_imap open -mailbox ${mailbox} -user $username -password 662051]    


# Save authentication data into mail session
ns_imap setparam $mailid user_id [ad_conn user_id]
ns_imap setparam $mailid session_id [ad_conn session_id]


set test [ns_imap status ${mailid}]
if { [expr [llength ${test}] % 2] == 0 } {
    array set status "[ns_imap status ${mailid}]"
} else {
    array set status "[ns_imap status ${mailid}] 1"
}

set nmsgs $status(Messages)
#set nmsgs 10
set end [expr ${nmsgs}-${offset}]
set start [expr ${end}-${limit}+1]
if { ${start} < 1 } {
	set start 1
}
set prevoffset [expr ${offset}-${limit}]
set nextoffset [expr ${offset}+${limit}]
tmpl::master -docStyleId doc3 -context_bar [ad_context_bar [::util::coalesce ${m} "Inbox"]] -title "Your Mail - Offset ${offset}" { 
    style {
	c {
	    ul#mailnav {
	    margin: 0;
	    padding: .5em 0;
	    float:right;
	    border:none;
  	    }

	    ul#mailnav li {
	    list-style: none;
            display:inline;
            }	    
	    .mail table tr td {
		width:100%;
		font-size:80%;
		background-color:#f0f0f0;
		padding:5px;
	    }
    .b {
	font-weight:bold;
     }
	}
    }

a -href "message-compose" {
    t "Compose Message"
}
p
    t [ns_imap status ${mailid}]
    p
    t [ns_imap ping $mailid]
    p
    b { t "Messages: " }
    t $status(Messages)
    br
    b { t "Last Access Time: " }
    t [clock format $status(Last\ Access\ Time)]

    
    ul -id "mailnav" {
    if { ${prevoffset} >= 0 } {
      li -class "prev" {
	  a -href "?username=${username}&m=${m}&offset=${prevoffset}" {
   	  t "« Newer "
        }
      }
    }

    t -disableOutputEscaping &nbsp;
    if { ${nextoffset} < ${nmsgs} } {
      li -class "next" {
	  a -href "?username=${username}&m=${m}&offset=${nextoffset}" {
	  t "Older »"
        }
      }
    }
}

div -style "clear:both;"

    div -class "mail" {
    table {

	    tr {
		th { t Sender  }
		th { t Subject }
		th { }
		th { t Date    }
		th { t Size    }
	    }

	for {set msg ${end}} {${msg} >= ${start}} {incr msg -1} {
	    set UID [ns_imap uid ${mailid} ${msg}]
	    ns_imap struct ${mailid} ${msg} -array struct
	    set date "$struct(internaldate.year)-$struct(internaldate.month)-$struct(internaldate.day) $struct(internaldate.hours):$struct(internaldate.minutes):$struct(internaldate.seconds)"
	    set date [lc_time_fmt ${date} "%d/%m/%Y&nbsp;%H:%M"]
	    set from [mime::field_decode [ns_imap header $mailid $msg from]]
	    set subject [mime::field_decode [ns_imap header $mailid $msg subject]]
	    set size [mail::msg::pretty_size $struct(size)]

	    binary scan [join [mime::parseaddress ${from}]] a* address
	    array set sender $address

	    tr -class [ad_decode $struct(flags) {} {} b] {
		td { 
		    try {
			span -title [util::coalesce $sender(friendly) $sender(local)] { 
			    t [string range [string tolower $sender(address)] 0 40] 
			    #t $sender(local)
			    #t $sender(local)
			}
		    } catch {*} {
			set comment {
			    binary scan $sender(friendly) a* xxx_value
			    t "error sender XXXXXXX $sender(address) xxx($xxx_value) [string range $sender(friendly) 0 6] [::util::string_to_hex $sender(friendly)]"
			}
			t "error sender"
		    }
		}
		td -style "white-space:nowrap; overflow:hidden;;" {
		    if {[empty_string_p [string trim ${subject}]]} {
			a -href "message-one?m=${m}&id=${UID}&username=${username}" -style "color:#666666;" { t Untitled }
		    } else {
			a -href "message-one?m=${m}&id=${UID}&username=${username}" { 
			    try {
				t ${subject} 
			    } catch {*} {
				#HERE
				set comment {
				    t [regsub -all -- {[^a-zA-Z0-9 \[\]\(\)-\\\&\.\:]} ${subject} ""]
				}
				t "ERROR in subject"
			    }
			}
		    }
		    #br 
		    #t [ns_imap struct ${mailid} ${msg}]
		}
		td {
		    if { [string equal [string tolower $struct(type)] multipart] &&
		         ![string equal [string tolower $struct(subtype)] alternative]} {
			#t $struct(type)/$struct(subtype)
			img -src /graphics/paperclip.gif -width 15 -height 15
		    }
		}
		td { 
		    try {
			t -disableOutputEscaping "${date}"    
		    } catch {*} {
			t "ERROR in date"
		    }
		}
		td -align "right" { t ${size}    }
	    }
	
	}
	}
    }
    ul -id "labelmenu" {
	li {
	    a -href "." {
		t "Inbox"
	    }
	}
	t -disableOutputEscaping <li>[join [mail_folders $mailid $username] <li>]
    }



}



        ns_imap close $mailid
