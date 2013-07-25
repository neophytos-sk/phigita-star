package provide dns 2.0

# NOTE: There's a dns package in tcllib.

set dir [file dirname [info script]]
source [file join $dir dns.tcl]

namespace eval ::xo::dns {;}

proc ::xo::dns::resolve {query {type A} {timeout "30000"}} {
    # am_pinit dns -init {::dns::configure -protocol tcp}
    ::dns::configure -protocol tcp -log "error"
    set count_tcl_errors 0
    set count_dns_errors 0
    # set last_good_nameserver [am_getcache last_good_nameserver]
    set last_good_nameserver "8.8.8.8"
    # set fallback_nameservers [lsearch -all -inline -not [am_cacheeval {::dns::nameservers} 900] $last_good_nameserver]
    set fallback_nameservers "195.14.130.220"
    set nameservers [concat $last_good_nameserver $fallback_nameservers]
    foreach nameserver $nameservers {
        if { [catch {set token [::dns::resolve $query -type $type -timeout $timeout -server $nameserver]} errmsg] } {
            if { [incr count_tcl_errors] + $count_dns_errors == 2} {
                error "Out of two tries: TCL Errors=$count_tcl_errors DNS Errors: $count_dns_errors" "" ""
            }
        } else {
	    ::dns::wait $token
	    set status [::dns::status $token]
	    #ns_log notice "dns resolve $query nameserver=$nameserver last_good_nameserver=$last_good_nameserver fallback_nameservers=$fallback_nameservers status=$status [::dns::error $token]"
	    if { $status eq {ok} } {
		#::dns::status $token
		set result [::dns::result $token]
		::dns::cleanup $token
		set output [list]
		foreach record $result {
		    # get the rdata dict element which is last
		    lappend output [lindex $record end]
		}
		if { $nameserver ne $last_good_nameserver } {
		    ## am_setcache -persist last_good_nameserver $nameserver serverwide
		}
		return $output
	    } elseif { [string match "error" $status] || [string match "timeout" $status] } {
            
		set errMsg [::dns::error $token]
		if { $errMsg eq {Name Error - domain does not exist} } {
		    ::dns::cleanup $token               
		    error $errMsg "" ""
		}
		# up to two attempts, we allow
		if { [incr count_dns_errors] + $count_tcl_errors == 2} {
		    ::dns::cleanup $token               
		    error "Out of two tries: TCL Errors=$count_tcl_errors DNS Errors: $count_dns_errors" "" ""
		}
	    } else {
		::dns::cleanup $token
		return
	    }
        }
    }
}
