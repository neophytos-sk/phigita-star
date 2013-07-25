set mailid [ns_imap open -mailbox {{localhost}} -user nkd -password 662051]

set id 48

tmpl::master {
    
    pre {
	try {
	    #t [ns_imap text ${mailid} $id -flags UID]
	    p
	    t [ns_imap struct $mailid $id -flags UID]
	    p
	    t [ns_imap headers ${mailid} ${id} -flags UID]
	    p
	} catch {*} {}
    }
}


ns_imap close $mailid
