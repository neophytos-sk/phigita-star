#source [acs_root_dir]/packages/kernel/tcl/20-templating/30-form-procs.tcl


namespace inscope ::xo::ui {

    Page new -master ::xo::ui::DefaultMaster -title "Mail" -appendFromScript {
	StyleText new -inline_p yes -styleText {
	    .x-form-label-left label {text-align:right;}
	}

	Panel new -autoHeight true -width 700 -header true -border true -headerAsText true -style "'margin-left:auto;margin-right:auto'" -title "'Write your post'" -appendFromScript {
	    
	Form new \
	    -label "Compose message" \
	    -style "padding:5px;margin-left:auto;margin-right:auto;" \
	    -action sendmail \
	    -submitText "Send" \
	    -appendFromScript {

		TextArea new \
		    -label "To" \
		    -name to \
		    -anchor '100%' \
		    -height 46

		TextArea new \
		    -label "Cc" \
		    -name cc \
		    -anchor '100%' \
		    -height 46 \
		    -allowBlank true

		TextArea new \
		    -label "Bcc" \
		    -name bcc \
		    -anchor '100%' \
		    -height 46 \
		    -allowBlank true

		TextField new \
		    -label "Subject" \
		    -name subject \
		    -anchor '100%' \
		    -allowBlank true

		TextArea new \
		    -label "Body" \
		    -name body \
		    -anchor "'100% -53'" \
		    -height 200 \
		    -hideLabel true \
		    -allowBlank true

	    } -proc render {visitor} {

		set id [ns_queryget id]
		if { [string is integer -strict $id] } {
		    set m [ns_queryget m]
		    set username [ns_queryget username]

		    set reply_all_p [::util::coalesce [ns_queryget reply_all_p] f]
		    set mailid [ns_imap open -mailbox [format {{127.0.0.1/ssl/novalidate-cert}%s} [join "INBOX ${m}" .]] -user ${username} -password 662051]
		    ns_imap struct ${mailid} $id -array struct -flags UID
		    array set headers {
			FROM     ""
			REPLY-TO ""
			TO       ""
			CC       ""
			BCC      ""
			SUBJECT  ""
		    }
		    ns_imap headers ${mailid} ${id} -array headers -flags UID
		    set to [::util::coalesce $headers(REPLY-TO) $headers(FROM)]
		    set body [mail_decode_body ${username} "" ${mailid} ${id} [array get struct]]
		    set reply_body "\n\n\n> [string map {"\n" "\n> "} $body]"
		    set subject "[::mime::field_decode $headers(SUBJECT)]"
		    if { [string range [string trim $subject] 0 2] ne {Re:} } {
			set subject "Re: $subject"
		    }
		    set cc ""
		    set bcc ""
		    if { $reply_all_p } {
			append to ", $headers(TO)"
			set cc $headers(CC)
			set bcc $headers(BCC)
		    }

		    my initFromDict [dict create to $to subject $subject cc $cc bcc $bcc body $reply_body]
		    ns_imap close $mailid
		}

		return [next]

	    } -proc action(sendmail) {marshaller} {
		if { [my isValid] } {
		    set mydict [my getDict]
		    set from k2pts@phigita.net
		    set to [dict get $mydict to]
		    set cc [dict get $mydict cc]
		    set bcc [dict get $mydict bcc]
		    set subject [dict get $mydict subject]
		    set body [dict get $mydict body]

		    set reply_to ""
		    set rr ""

		    set mailer "PHIGITA-Mailer-0.2" 
		    set mime_type "text/plain"
		    set hdrs [ns_set new]
		    ns_set put $hdrs X-Mailer $mailer
		    ns_set put $hdrs MIME-Version "1.0"
		    ns_set put $hdrs Content-Type "$mime_type; charset=utf-8"
		    #ns_set put $hdrs Content-Transfer-Encoding "quoted-printable"


		    if { $reply_to != "" } { ns_set update $hdrs Reply-To $reply_to }
		    # Message return receipt
		    if { $rr != "" } { ns_set put $hdrs Disposition-Notification-To $from }

		    if { [catch { ns_sendmail $to \
				      $from \
				      $subject \
				      $body \
				      $hdrs \
				      $bcc} errMsg] } {
			my initFromDict $mydict
			$marshaller go -select "" -action draw
			#error "Unable to send message: $errMsg"
		    }

		    #ns_return 200 text/plain $mydict
		    ad_returnredirect .
		} else {
		    foreach o [my getFields] {
			$o set value [$o getRawValue]
			if { ![$o isValid] } {
			    $o markInvalid "Failed Validation"
			    ns_log notice "failed validation $o [$o info class] [$o getRawValue]"
			}
		    }
		    ns_return 200 text/plain NOT_OK
		    return
		    $marshaller go -select "" -action draw
		}
	    }

    }
    }
}