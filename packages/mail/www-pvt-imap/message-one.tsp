package require mime

ad_page_contract {
	@author Neophytos Demetriou
} {
    id:integer
    {m:trim ""}
    {debug_p:trim,boolean f}
    {username:trim,notnull "k2pts"}
}

if { -1 == [lsearch "webmaster k2pts" $username] } {
        doc_return 200 text/plain "wrong username"
        return
}



set mailid [ns_imap open -mailbox [format {{127.0.0.1/ssl/novalidate-cert}%s} [join "INBOX ${m}" .]] -user ${username} -password 662051]

ns_imap struct ${mailid} $id -array struct -flags UID
set headers(REPLY-TO) ""
set headers(TO) ""
set headers(CC) ""
set headers(BCC) ""
ns_imap headers ${mailid} ${id} -array headers -flags UID
set body [mail_to_html [mail_decode_body ${username} ${m} ${mailid} ${id} [array get struct]]]

if {$headers(REPLY-TO) eq $headers(TO)} {
    set headers(REPLY-TO) ""
}

#    set headers(TO-ALL) [join [list $headers(TO) $headers(CC)] {;}]

tmpl::master -title "One Message" -context_bar [ad_context_bar "One Message"] {

    
    a -href [export_vars -no_empty -base message-compose {id m username}] {
	t "Reply"
    }
	t " | "    
    a -href [export_vars -no_empty -base message-compose -override [list [list reply_all_p t]] {id m username}] {
	t "Reply to all"
    }
    p
    table -bgcolor "\#efefef" -width "100%" {
	foreach name {SUBJECT DATE FROM REPLY-TO TO CC BCC} pretty_print {Subject Date From Reply-To To CC BCC} style {"font-weight:bold;font-size:120%;" "" "" "" ""} {
	    if {[exists_and_not_null headers(${name})]} {
		try {
		     tr {
			 td -bgcolor "\#aaaaaa" -align right -nowrap "" {
			     span -style "font-size:80%;font-weight:bold;font-variant:small-caps;" {
				 t ${pretty_print}
			     }
			     t -disableOutputEscaping "&nbsp;"
			 }
			 td -width 100% {
			     span -style ${style} {
				 t [mime::field_decode $headers(${name})]
			     }
			 }
		     }
		} catch {*} {
		    t "error $name"
		}
	    }
	}
    }
    p

    div -style "font-family:courier;" {
	try {
	    t -disableOutputEscaping ${body}
	} catch {*} {
	    t "ERROR in message body..."
	}
    }
    p
if { $debug_p } {
    table -bgcolor "#dddddd" {
	foreach key [array names headers] {
	    tr {
		td {
		    t "${key}"
		}
		td {
		    t $headers($key)
		}
	}
	}
    }
}
}

ns_imap close $mailid


