ns_log notice "is_ping_p= [ns_config ns/server/[ns_info server] is_ping_p 0]"

# Default interval is 1 minute.
if { [ns_config ns/server/[ns_info server] is_ping_p 0] } {
    ad_schedule_proc -thread t 60 ::blogger::ping
}