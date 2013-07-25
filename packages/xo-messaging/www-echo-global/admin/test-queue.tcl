set result ""
foreach {cluster groups} [smsq_get_queue_info] {
	foreach {group queue_messages} $groups break
	foreach msg_id $queue_messages {
	    array set mymsg [smsq_retrieve_ascii $group $msg_id]


	    set line ""
	    foreach name [array names mymsg] {
		lappend line "${name} = $mymsg($name)"
	    }
	    lappend result [join $line ","]

	    set comment {
		foreach encodingName [encoding names] {
		    lappend result $encodingName=[encoding convertfrom $encodingName [encoding convertto ascii $mymsg(message)]]
		}
	    }
	}
}
doc_return 200 text/plain [join $result \n]


#	set line [convert.string.to.hex $mymsg(message)]
#	    lappend result [list names=[array names mymsg] $mymsg(message) originating_msisdn=$mymsg(originating_msisdn) terminating_msisdn=$mymsg(terminating_msisdn)]
# --[encoding convertfrom gsm0338 $mymsg(message)]--$line
#lappend result [list group=$group msg_id=$msg_id [encoding convertfrom gsm0338 $mymsg(message)]]