
ns_log notice "start_request_monitor_p= [ns_config ns/server/[ns_info server] start_request_monitor_p 1] "
if { [ns_config ns/server/[ns_info server] start_request_monitor_p 1] } {

    # we register the following filters only during startup, since
    # existing connection threads are not aware of the throttle object.
    if {[ns_server connections]==0} {
	# 
	# Register the filter progs for url statistics.
	# The methods to be called have the name of the filter type.
	#
	ns_register_filter trace GET * throttle 
	ns_register_filter trace POST * throttle

	#ns_register_filter postauth GET * throttle 
	#ns_register_filter postauth POST * throttle 
	ad_register_filter -priority 1000 postauth GET * throttle
	ad_register_filter -priority 1000 postauth POST * throttle
    }

    # check if we are running under oacs; if not, provide 
    # minimal compatibility code
    if {[info commands ad_conn] eq ""} {
	# otherwise provide alias for ad_conn and dummy for ad_get_user_id
	interp alias {} ad_conn {} ns_conn
	### this is probably not sufficient to do something useful...
    }


}