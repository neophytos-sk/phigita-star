ad_page_contract {
	@author Neophytos Demetriou
} {
	{offset:integer "0"}
	{limit:integer "25"}
}

set end [expr ${offset}+${limit}]
set end [expr ${end}<${nmsgs}?${nmsgs}:${end}]

set sort_options { { Date 0date } { "Date Reverse" 1date }
                    { Subject 0subject } { "Subject Reverse" 1subject }
                    { From 0from } { "From Reverse" 1from }
                    { Size 0size } { "Size Reverse" 1size } }

set sort 1date

###############################################################################


# Returns a list with all IMAP folders, performs
# caching of the list for some time
proc mail_folders { mailid } {
    set maildir INBOX. 
      set folders [list]
      set index [string length $maildir]
      foreach { name flags } [ns_imap list $mailid "[ns_imap getparam $mailid mailbox.host]" $maildir*] {
        if { [string match "*noselect*" $flags] } { continue }
        set name [string range $name $index end]
        lappend folders [list $name $name]
      }
    
    set folders [lsort $folders]
    return $folders
}



# Open new connection
set mailid [ns_imap open -mailbox {{localhost}} -user nkd -password 662051]    


# Save authentication data into mail session
ns_imap setparam $mailid user_id [ad_conn user_id]
ns_imap setparam $mailid session_id [ad_conn session_id]

# Retrieve messages in given sorting order
set msgs [ns_imap sort $mailid [string range ${sort} 1 end] [string index ${sort} 0] NOPREFETCH]

tmpl::master -context_bar [ad_context_bar] {

    t [mail_folders $mailid]
    p
    t [ns_imap status $mailid]
    p
    t [ns_imap ping $mailid]
    p
    table {

	    tr {
		td { t "Msg No." }
		td { t Sender   }
		td { t Subject }
		td { t Date    }
		td { t Size    }
	    }

	for { set i ${end} } { ${i} > ${offset} } { incr i -1 } {
	    ns_imap struct ${mailid} ${i} -array struct
	    set date [ns_imap header ${mailid} ${i} date]
	    set sdate [ns_imap parsedate ${date}]
	    if { $sdate != "" } { set date [ns_fmttime $sdate "%a, %m/%d/%y %T"] }
	    set from [mime::field_decode [ns_imap header $mailid ${i} from]]
	    set subject [mime::field_decode [ns_imap header $mailid ${i} subject]]
	    set size [mail::msg::pretty_size $struct(size)]

	    tr {
	 	td { 
		    t ${i} 
		    br
		    t \#[ns_imap uid $mailid ${i}]
		}
		td { div -title ${from} { t ${from} }    }
		td { 
		    a -href "message-one?msg_id=${i}" { t ${subject} } 
		}
		td { t ${date}    }
		td -align "right" { t ${size}    }
	    }

	}

    }


}



        ns_imap close $mailid
