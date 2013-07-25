ns_log notice "is_sms_p=[ns_config ns/server/[ns_info server] is_sms_p 0]"
if { [ns_config ns/server/[ns_info server] is_sms_p 0] } {

    ::xotcl::THREAD create SMS {

	proc verifyDeviceIfMatches {device_guid device_token} {
	    set conn [DB_Connection new]
	    $conn do "update xo.xo__echo__device set is_verified_p='t' where [::xo::db::qualifier device_guid = $device_guid] AND [::xo::db::qualifier device_token = $device_token]"
	    $conn destroy
	}

	proc getUserIfVerified {device_guid} {
	    set data [::db::Set new -type ::echo::Device -where [list [::xo::db::qualifier device_guid = $device_guid] is_verified_p]]
	    $data load
	    if { ![$data emptyset_p] } {
		return [[$data head] set device_user]
	    }
	    return
	}

	proc maybeVerificationCode {content} {
	    set len [string length $content]
	    if { ${len}>=4 && ${len} <= 8 } {
		if { [regexp -- {^[adgjmptw]{4,8}$} [string trim [string tolower $content]]] } {
		    return true
		}
	    }
	    return false
	}

	proc storeMessage { group_name msg_id } {

	    set message [smsq_retrieve_ascii $group_name $msg_id]

	    ns_log notice "SMS (msg_id=$msg_id): $message"

	    array set mymsg $message

	    set seconds [expr {[clock scan "$mymsg(smsc_year)-$mymsg(smsc_month)-$mymsg(smsc_day) $mymsg(smsc_hour):$mymsg(smsc_min):$mymsg(smsc_sec)" -gmt true]-$mymsg(smsc_tz)*10}]
	    set smsc_timestamp [clock format $seconds -format "%Y-%m-%d %H:%M:%S" -gmt false]

	    set o [::sms::Message new -mixin ::db::Object -pool echodb -pathexp [list]]
	    $o set content $mymsg(message)
	    $o set smsc_timestamp $smsc_timestamp
	    $o set originating_msisdn $mymsg(originating_msisdn)
	    $o set terminating_msisdn $mymsg(terminating_msisdn)
	    $o set message_ref $mymsg(message_ref)
	    $o set message_max_parts $mymsg(message_max_parts)
	    $o set message_part_number $mymsg(message_part_number)
	    $o save_message

	    set user_id [getUserIfVerified $mymsg(originating_msisdn)]

	    set content ""
	    set is_complete_p false
	    if { [$o set message_max_parts] > 1 } {

		set data [::db::Set new \
			      -pool echodb \
			      -type ::sms::Message \
			      -where [list complete_p [::xo::db::qualifier message_ref eq $mymsg(message_ref)] [::xo::db::qualifier originating_msisdn eq $mymsg(originating_msisdn)]] \
			      -limit 1]
		$data load


		if { ![$data emptyset_p] } {
		    set co [$data head]
		    $co mixin ::sms::Message
		    set content [$co get_content]
		    set is_complete_p true
		}
	    } else {
		set content $mymsg(message)
		set is_complete_p true
	    }

	    if { $user_id ne {} && [::util::boolean $is_complete_p] } {
		set peeraddr 127.0.0.1

		set msg [::echo::Message new -mixin ::db::Object]

		$msg set device "sms"
		$msg set content $content
		$msg set creation_user $user_id
		$msg set creation_ip $peeraddr
		$msg set modifying_user $user_id
		$msg set modifying_ip $peeraddr

		$msg beginTransaction
		$msg rdb.self-id		
		$msg rdb.self-insert
		$msg set pathexp [list "User ${user_id}"]
		$msg rdb.self-insert
		$msg endTransaction
		$msg destroy

	    } else {
		if { [maybeVerificationCode $mymsg(message)] } {
		    verifyDeviceIfMatches $mymsg(originating_msisdn) [string trim [string tolower $mymsg(message)]]
		}
	    }

	    $o destroy
	}

	proc sweepIncomingQueue {} {

	    ns_log notice "sweepIncomingQueue: started..."

	    set group_name "incoming"

	    # wait for activity within the specified group for the specified timeout period

	    while { [smsq_wait_for_group_activity $group_name] } {

		#   Adjusts the counter indicating to the underlying qcluster layer whether
		#   this server will process messages for this group.  The qcluster layer
		#   may reassign any pending/future messages for the specified group to
		#   another server.

		smsq_set_group_process_flag $group_name 1

		#   Retrieve a message within the given group,
		#   returning the message id.  Returns an empty string if no message
		#   found.

		set msg_id [smsq_get_next_group_msg $group_name]
		while { $msg_id ne {} } {

		    storeMessage $group_name $msg_id

		    # Set the status of the given message id.  If status is "complete", the
		    # message is removed from the given group queue.

		    smsq_set_msg_status $group_name $msg_id "complete"

		    set msg_id [smsq_get_next_group_msg $group_name]

		}

		smsq_set_group_process_flag $group_name 0

	    }

	}

    } -persistent 1 


    namespace eval ::sms {;}

    proc ::sms::initialize {} {
	ns_log notice "Initialize GSM modem..."
	set link_id "GSM1"
	set in_group "incoming"
	set out_group "outgoing"
	set status online ;# online OR offline
	set device "/dev/ttyS0"
	set device_timeout_secs "90"
	set service_centre "+35799700000"
	set sim_pin "1234"
	set poll_time_secs "30"
	set post_send_delay_usecs "0"
	set use_pdu_p "1" ;# protocol description unit mode
	set max_retries "3"
	set msisdn "+35799408270"


	set src_msisdn +35797643810
	set group_name outgoing
	#set msisdn +35799408270
	#set msisdn +35799431866 ;# alex

	#set message "this is a test, hello world $msisdn blah blah"
	#set msgId [smsq_submit_ascii -src $src_msisdn $group_name $msisdn $message]


	generic_gsm_init \
	    $link_id \
	    $in_group \
	    $out_group \
	    $status \
	    $device \
	    $device_timeout_secs \
	    $service_centre \
	    $sim_pin \
	    $poll_time_secs \
	    $post_send_delay_usecs \
	    $use_pdu_p \
	    $max_retries \
	    $src_msisdn

    }

    ns_schedule_proc -once 0 ::sms::initialize
    ns_schedule_proc -once 0 ::SMS do -async sweepIncomingQueue
}
