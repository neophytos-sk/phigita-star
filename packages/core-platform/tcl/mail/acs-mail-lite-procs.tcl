ad_library {

    Provides a simple API for reliably sending email.

    @author Eric Lorenzo (eric@openforce.net)
    @date 22 March 2002
    @version $Id: acs-mail-lite-procs.tcl,v 1.1.1.1 2002/11/22 09:47:32 nkd Exp $

}

namespace eval acs_mail_lite {

    ad_proc -public send {
        {-to_addr:required}
        {-from_addr:required}
        {-subject ""}
        {-body:required}
        {-extraheaders ""}
        {-bcc ""}
    } {
        Reliably send an email message.
    } {
        if {![empty_string_p $extraheaders]} {
            set eh_list [util_ns_set_to_list -set $extraheaders]
        } else {
            set eh_list ""
        }

        db_dml create_queue_entry {
            insert into acs_mail_lite_queue 
            (message_id, to_addr, from_addr, subject, body, extra_headers, bcc)
            values
            (nextval('acs_mail_lite_id_seq'), :to_addr, :from_addr, :subject, :body, :eh_list, :bcc)
	}
    }

    ad_proc -private sweeper {} {
        Send messages in the acs_mail_lite_queue table.
    } {

	set sql {
            select message_id,
                   to_addr,
                   from_addr,
                   subject,
                   body,
                   extra_headers,
                   bcc
            from acs_mail_lite_queue
	}

	::xo::db::withhandle db {

	    set messages [list]
	    set row [ns_db select $db $sql]
	    while { [ns_db getrow $db $row] } {
		set message_id [ns_set get $row message_id]
		set to_addr [ns_set get $row to_addr]
		set from_addr [ns_set get $row from_addr]
		set subject [ns_set get $row subject]
		set body [ns_set get $row body]
		set extra_headers [ns_set get $row extra_headers]
		set bcc [ns_set get $row bcc]

		lappend messages [list $message_id $to_addr $from_addr $subject $body $extra_headers $bcc]
	    }

	    foreach msg $messages {
		lassign $msg message_id to_addr from_addr subject body extra_headers bcc
		set eh [util_list_to_ns_set $extra_headers]

		set mime_type "text/plain"
		#		ns_set put $eh Date "$sent_date [acs_messaging_timezone_offset]"
		ns_set put $eh MIME-Version "1.0"
		ns_set put $eh Content-Type "$mime_type; charset=iso-8859-7"
		ns_set put $eh Content-Transfer-Encoding "8bit"

		if { [catch {
		    # SOS: g11n: iso8859-7
		    set string [base64::encode [encoding convertto iso8859-7 $subject]]
		    set result ""
		    foreach item $string {
			append result "=?iso-8859-7?B?${item}?="
		    }
		    set subject $result
		    set body [encoding convertto iso8859-7 $body]
		    
		    ns_sendmail $to_addr $from_addr $subject $body $eh $bcc
		    ns_db dml $db "delete from acs_mail_lite_queue where message_id = [ns_dbquotevalue ${message_id}]"
		} errmsg]} {
		    ns_log Error "failed to send mail: $errmsg"
		}
	    }
	}
    }





}
