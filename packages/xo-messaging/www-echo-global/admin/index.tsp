set echo_data [::db::Set new -pool echodb \
		   -select [list * "(current_timestamp - last_update) as interval_ago"] \
		   -type "::sms::Message" \
		   -where [list "complete_p='t'"] \
		   -order "last_update desc" \
		   -limit 100]
$echo_data load

tmpl::master {

    form -action sms-send {
	t "To: "
	input -type text -name msisdn -value "+35799408270"
	br
	t "Message: "
	br
	textarea -name content
	br
	input -type submit -value "Send"
    }
    ul {
	foreach o [$echo_data set result] {
	    $o mixin add ::sms::Message
	    li {
		t "From: [$o set originating_msisdn] - [$o set interval_ago] ago"
		div {
		    t -disableOutputEscaping [decorate -str [$o get_content] -allow_heading_p false]
		}
	    }
	}
    }

}