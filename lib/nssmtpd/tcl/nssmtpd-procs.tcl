# Author: Vlad Seryakov vlad@crystalballinc.com 
# March 2006
# Author: Neophytos Demetriou k2pts@phigita.net
# July 2011




namespace eval smtpd {

   variable version "Smtpd version 2.5"
}

proc smtpd::init {} {

    ns_log notice "initialize smptd module..."


    set path "ns/server/[ns_info server]/module/nssmtpd"
    eval ns_smtpd relay set [ns_config $path relaydomains]
    ns_log notice smtpd::init: Relay Domains: [ns_smtpd relay get]
    eval ns_smtpd local set [ns_config $path localdomains]
    ns_log notice smtpd::init: Local Domains: [ns_smtpd local get]
}

# Decode message header
proc smtpd::decodeHdr { str } {

    set a [string first "=?" $str]
    if { $a >= 0 } {
	set b [string first "?" $str [expr $a+2]]
	if { $b > 0 } {
	    set charset [string range $str [expr { $a + 2}] [expr { ${b} - 1}]]
	    set e [string first "?=" $str $b]
	    if { $e == -1 } { set e end } else { incr e -1 }
	    switch [string index $str [expr $b+1]] {
		Q {
		    set str [ns_smtpd decode qprint [string range $str [expr $b+3] $e]]
		}
		B {
		    set str [ns_smtpd decode base64 [string range $str [expr $b+3] $e]]
		}
	    }
	    set enc [::mime::reversemapencoding $charset]
	    set str [encoding convertfrom $enc $str]
	}
    }
    return $str
}

# Parses bounces
proc smtpd::decodeBounce { id body } {

    set sender_email ""
    set filters { 
        {The following addresses had permanent fatal errors -----[\r\n]+<?([^>\r\n]+)} {}
        {The following addresses had permanent delivery errors -----[\r\n]+<?([^>\r\n]+)} {}
        {The following addresses had delivery errors---[\r\n]+<?([^> \r\n]+)} {}
        {<([^>]+)>:[\r\n]+Sorry, no mailbox here by that name.} {}
        {Your message.+To:[ \t]+([^ \r\n]+)[\r\n]+.+did not reach the following recipient} {}
        {Your message cannot be delivered to the following recipients:.+Recipient address: ([^ \r\n]+)} {}
        {Failed addresses follow:.+<([^>]+)>} {}
        {[\r\n]+([^ \t]+) - no such user here.} {}
        {qmail-send.+permanent error.+<([^>]+)>:} {}
        {Receiver not found: ([^ \r\n\t]+)} {%s@compuserve.com}
        {Failed to deliver to '<([^>]+)>'} {}
        {The following address\(es\) failed:[\r\n\t ]+([^ \t\r\n]+)} {}
        {User<([^>]+)>.+550 Invalid recipient} {}
        {Delivery to the following recipients failed.[\r\n\t ]+([^ \t\r\n]+)} {}
        {<([^>]+)>:[\r\n]+Sorry.+control/locals file, so I don't treat it as local} {}
        {RCPT To:<([^>]+)>.+550} {}
        {550.*<([^>]+)>... User unknown} {}
        {550.*unknown user <([^<]+)>} {}
        {could not be delivered.+The .+ program[^<]+<([^<]+)>} {}
        {The following text was generated during the delivery attempt:------ ([^ ]+) ------} {}
        {The following addresses were not valid[\r\n\t ]+<([^>]+)>} {}
        {These addresses were rejected:[\r\n\t ]+([^ \t\r\n]+)} {}
        {Unexpected recipient failure - 553 5.3.0 <([^>]+)>} {}
        {not able to deliver to the following addresses.[\r\n\t ]+<([^>]+)>} {}
        {cannot be sent to the following addresses.[\r\n\t ]+<([^>]+)>} {}
        {was not delivered to:[\r\n\t ]+([^ \r\n]+)} {}
        {<([^>]+)>  delivery failed; will not continue trying} {}
        {User mailbox exceeds allowed[^:]+: ([^ \n\r\t]+)} {}
        {could not be delivered[^<]+<([^>]+)>:} {}
        {undeliverable[^<]+<([^@]+@[^>]+)>} {}
        {could not be delivered.+Bad name:[ \t]+([^ \r\n\t]+)} {%s@oracle.com}
    }

    foreach { filter data } $filters {
      if { [regexp -nocase $filter $body d sender_email] } { 
        if { $data != "" } { set sender_email [format $data $sender_email] }
        break
      }
    }
    if { $sender_email != "" } {
      foreach rcpt [ns_smtpd getrcpt $id] {
        foreach { user_email user_flags spam_score } $rcpt {}
        ns_log Error smtpd::decodeBounce: $id: $user_email: $sender_email
      }
    }
    return $sender_email
}

# Mailing list/Sender detection
proc smtpd::decodeSender { id } {

    set From [ns_smtpd getfrom $id]
    if { [set Sender [ns_smtpd checkemail [ns_smtpd gethdr $id Sender]]] != "" } {
      return $Sender
    }
    if { [set ReplyTo [ns_smtpd checkemail [ns_smtpd gethdr $id Reply-To]]] != "" && $ReplyTo != $From } {
      return $ReplyTo
    }
    if { [set XSender [ns_smtpd checkemail [ns_smtpd gethdr $id X-Sender]]] != "" } {
      return $XSender
    }
    # Try for old/obsolete mailing lists
    if { [ns_smtpd gethdr $id Mailing-List] != "" ||
         [ns_smtpd gethdr $id List-Help] != "" ||
         [ns_smtpd gethdr $id List-Unsubscribe] != "" ||
         [ns_smtpd gethdr $id Precedence] == "bulk" ||
         [ns_smtpd gethdr $id Precedence] == "list" } {
      if { $ReplyTo != "" } {
        return $ReplyTo
      } else {
        return $From
      }
    }
    return $From
}

proc smtpd::helo { id } {
    ns_log notice "helo $id"
}

proc smtpd::mail { id } {
    ns_log notice "mail $id"
}

proc smtpd::rcpt { id } {

    ns_log notice "smtpd::rcpt $id"

    # Current recipient
    lassign [ns_smtpd getrcpt $id 0] user_email user_flags spam_score
    ns_log notice "user_email=$user_email user_flags=$user_flags spam_score=$spam_score"
    # Non-relayable user, just pass it through
    if { !($user_flags & [ns_smtpd flag RELAY]) } {
	ns_log notice "non-relayable user (email: $user_email - flags: $user_flags), just pass it through"
	ns_smtpd setflag $id 0 VERIFIED
	return
    }


    # White List
    switch -exact -- $user_email {
	k2pts@phigita.net -
	neophytos@phigita.net -
	webmaster@phigita.net {
	    # Check everything for this domain
	    ns_smtpd setflag $id 0 VIRUSCHECK
	    ns_smtpd setflag $id 0 SPAMCHECK
	    return
	}
	default {
	    # User is not allowed to receive any mail
	    ns_smtpd setreply $id "550 ${user_email}... User unknown\r\n"
	    ns_smtpd delrcpt $id 0
	    return
	}
    }

    # Black List
    # Example of checking by recipient
    switch -regexp -- $user_email {
	"joe@domain.com" -
	"joe@localhost" {
	    # User is not allowed to receive any mail
	    ns_smtpd setreply $id "550 ${user_email}... User unknown\r\n"
	    ns_smtpd delrcpt $id 0
	    return
	}
	default {
	    # Check everything for this domain
	    ns_smtpd setflag $id 0 VIRUSCHECK
	    ns_smtpd setflag $id 0 SPAMCHECK
	    return
	}
    }
    # All other emails are allowed
    ns_smtpd setflag $id 0 VERIFIED
}

proc smtpd::data { id } {

    # Global connection flags
    set conn_flags [ns_smtpd getflag $id -1]
    # Sender email
    set sender_email [smtpd::decodeSender $id]
    # Subject from the headers
    set subject [ns_smtpd gethdr $id Subject]
    # Special headers
    set signature [ns_smtpd gethdr $id X-Smtpd-Signature]
    set virus_status [ns_smtpd gethdr $id X-Smtpd-Virus-Status]
    # Message data
    #foreach { body body_offset body_size } [ns_smtpd getbody $id] {}
    lassign [ns_smtpd getbody $id] body body_offset body_size
    
    # Find users who needs verification
    foreach rcpt [ns_smtpd getrcpt $id] {
	#foreach { deliver_email user_flags spam_score } $rcpt {}
	lassign $rcpt deliver_email user_flags spam_score
	# Non-relayable user
	if { !($user_flags & [ns_smtpd flag RELAY]) } { continue }
	# SPAM detected
	if { $user_flags & [ns_smtpd flag GOTSPAM] } { continue }
	# Already delivered user
	if { $user_flags & [ns_smtpd flag DELIVERED] } { continue }
	# Virus detected
	if { $conn_flags & [ns_smtpd flag GOTVIRUS] } { continue }
	# Recipient is okay
	set users($deliver_email) $spam_score
    }

    if { [array size users] > 0 } {
	# Build attachements list
	set attachments ""
	foreach file [ns_smtpd gethdrs $id X-Smtpd-File] {
	    append attachments $file " "
	}
	# Save the message in the database or do other things to the message,
	# i will save in the mailbox just as an example

        set msg_date [clock format [clock seconds] -format "%Y%m%dT%H%M%S"]
	set msg_id ${msg_date}.[ns_time]_[ns_thread id]
	set maildir [::smtpd::maildir]
	set newdir [file join $maildir "new"]
	set filename [file join $newdir $msg_id]

	if { [catch {
	    set fd [open $filename w]
	    #puts $fd "MAIL-FROM: $sender_email"
	    #puts $fd "MAIL-DATE: $msg_date" ;# ns_fmttime ns_time
	    #puts $fd "MAIL-RCPT: [array names users]"
	    #puts $fd "MAIL-SUBJECT: $subject"
	    #if { $attachments ne {} } {
	    #puts $fd "MAIL-ATTACHMENTS: $attachments"
	    #}
	    #puts $fd "MAIL-INFO: body_offset $body_offset body_size $body_size"
	    # puts $fd "" ;# newline
	    puts $fd ${body}
	    close $fd

	    #if {0} {
	    #  ns_smtpd dump $id $filename
	    #}
	} errmsg] } {
	    ns_smtpd setflag $id -1 ABORT
	    ns_log Error smtpd:data: $errmsg
	    ns_smtpd setreply $id "421 Transaction failed (Msg)\r\n"
	}
    }
}

proc smtpd::error { id } {

    ns_log notice "smtpd::error $id"

    set line [ns_smtpd getline $id]
    # sendmail 550 user unknown reply
    if { [regexp -nocase {RCPT TO: <([^@ ]+@[^ ]+)>: 550} $line d user_email] } {
      ns_log notice smtpd::error: $id: Dropping $user_email
    }
}

proc smtpd::maildir {} {
    return "/web/local-data/mail"
}


# make skeleton

file mkdir [::smtpd::maildir]
file mkdir [::smtpd::maildir]/new
file mkdir [::smtpd::maildir]/tmp
file mkdir [::smtpd::maildir]/cur

