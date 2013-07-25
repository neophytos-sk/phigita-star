#
# logroll.tcl - Rolls the server log on the same basis as the access log.
#
# bart.teeuwisse@7-sisters.com
# Oct 07, 2001
# version 0.1 based on prior work by
# arjun@openforce.net 
# May 17, 2001
# version 0.1 
#
# Note: This script is for rolling the _server_ log not the _access_ log!
#
# Directions
# ----------
# 1. Set the "ServerLog" in the ns/parameters section and the 
# "RollDay", "RollHour", "RollFmt" parameters in the
# ns/server//module/nslog section of your config file.
#
# 2. Place this script a Tcl directory sourced at server startup
#
# Further Work
# ------------
# - Verify the log got rolled, if not send email
# - Check for disk space
# - scp logs to a remote site(s)

# Roll the server log and give it an extension of the current date and time.

proc roll_server_log {serverlog rollfmt} {
    ns_log Notice "logroll.tcl: About to roll server log."
    ns_logroll

    set date [clock format [clock seconds] -format $rollfmt]
    if {[file exists "$serverlog.000"]} {
	file rename "$serverlog.000" "$serverlog.$date"
	ns_log Notice "logroll.tcl: Just rolled server log into $serverlog.$date"
    } else {
	ns_log Warning "logroll.tcl: Just rolled server log but couldn't move it to $serverlog.$date"
    }
}

# Create argument list

set args [list]

# Find out where the log is stored.

lappend args [ns_config "ns/parameters" ServerLog]

# Roll the log when the access log is being rolled.

set rollday [ns_config "ns/server/[ns_info server]/module/nslog" RollDay]
set rollhour [ns_config -int "ns/server/[ns_info server]/module/nslog" RollHour]
set rollminute 0

# Use the same roll format as the access log.

lappend args [ns_config "ns/server/[ns_info server]/module/nslog" RollFmt]

ns_log notice "ns_info name=[ns_info name] ns_info version=[ns_info version]"

if {[ns_info name] eq "NaviServer"} {

    if {$rollday == "*"} {

	# Schedule "roll_server_log" to run at the desired time

	ns_schedule_daily $rollhour $rollminute "roll_server_log $args"
    } else {
    
	# Schedule "roll_server_log" to run only on RollDay days.

	ns_schedule_weekly $rollday $rollhour $rollminute "roll_server_log $args"
    }
}


