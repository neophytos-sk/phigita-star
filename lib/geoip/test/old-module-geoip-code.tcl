	# first four bytes int the binary value of our long integer (start_ip_num)
	# fifth byte is the equal sign
	# followed by the record value
	#binary scan $match a4aa* lo_bin _dummy_ rest_match
	#binary scan $match a4a* lo_bin rest_match
	#set lo_bin [lindex $match 0]
	#set rest_match [lindex $match 1]
	#set rest_match [string trimleft {=} $rest_match]
	#puts "=> query_ip=$query_ip match=$match bytelength=[string bytelength $match]"
	#puts "match=$match -> lo_bin=$lo_bin rest_match=$rest_match"
	#return
        #lassign [split $rest_match {_}] hi_diff location_id
        #set lo [::util::parseUnsignedLong $lo_bin]
	#if { [catch {set hi [expr { $lo + $hi_diff }]} errmsg] } {
	#    ns_log notice "lo_bin=$lo_bin lo=$lo hi_diff=$hi_diff match=$match query_ip=$query_ip errmsg=$errmsg"
	#    return
	#}
