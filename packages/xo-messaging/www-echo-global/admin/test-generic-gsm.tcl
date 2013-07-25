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
set use_pdu_p "0" ;# protocol description unit mode
set max_retries "3"
set msisdn "+35799408270"


set src_msisdn +35797643810
set group_name outgoing
#set msisdn +35799408270
#set msisdn +35799431866 ;# alex

#set message "this is a test, hello world $msisdn blah blah"
#set msgId [smsq_submit_ascii -src $src_msisdn $group_name $msisdn $message]

ns_return 200 text/plain [subst {
    [generic_gsm_init \
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
	 $src_msisdn]

    ok


    Msg ID: $msgId
    queue_info: [smsq_get_queue_info]
    Retrieve Ascii: [smsq_retrieve_ascii $group_name $msgId]



}]
