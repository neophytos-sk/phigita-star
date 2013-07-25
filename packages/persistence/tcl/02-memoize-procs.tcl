namespace eval ::memoize {
    variable cache_mutex [ns_mutex create ossweb:cache]
}

# Generic caching mechanism, global throughout the whole server.
# Examples:
#   cache set john "111"
#   set id [cache get john]
#   cache flush john
proc ::memoize::cache { command key args } {

    variable cache_mutex
    
    switch -exact $command {

	exists {
	    set rc 0
	    ns_mutex lock $cache_mutex
	    catch { 
		if { [nsv_exists __ossweb_cache $key] } {
		    set timeout [nsv_get __ossweb_cache_timeout $key]
		    if { $timeout == -1 || $timeout > [ns_time] } { set rc 1 }
		}
	    }
	    ns_mutex unlock $cache_mutex
	    return $rc
	}
	
	get {
	    set value [lindex $args 0]
	    ns_mutex lock $cache_mutex
	    catch {
		if { [nsv_exists __ossweb_cache $key] } {
		    set timeout [nsv_get __ossweb_cache_timeout $key]
		    if { $timeout == -1 || $timeout > [ns_time] } {
			set value [nsv_get __ossweb_cache $key]
		    }
		}
	    }
	    ns_mutex unlock $cache_mutex
	    return $value
	}

	incr {
	    ns_mutex lock $cache_mutex
	    catch {
		if { ![nsv_exists __ossweb_cache $key] } {
		    nsv_set __ossweb_cache $key 0
		    nsv_set __ossweb_cache_timeout $key -1
		}
		set value [nsv_incr __ossweb_cache $key]
	    }
	    ns_mutex unlock $cache_mutex
	    return $value
	}
	
	set {
	    if { [set timeout [lindex $args 1]] != -1 } {
		set timeout [expr [ns_time] + [util::nvl $timeout 86400]]
	    }
	    ns_mutex lock $cache_mutex
	    catch {
		nsv_set __ossweb_cache_timeout $key $timeout
		nsv_set __ossweb_cache $key [lindex $args 0]
	    }
	    ns_mutex unlock $cache_mutex
	}

	append {
	    if { [set timeout [lindex $args 1]] != -1 } {
		set timeout [expr [ns_time] + [util::nvl $timeout 86400]]
	    }
	    ns_mutex lock $cache_mutex
	    catch {
		nsv_set __ossweb_cache_timeout $key $timeout
		nsv_append __ossweb_cache $key [lindex $args 0]
	    }
	    ns_mutex unlock $cache_mutex
	}

	lappend {
	    if { [set timeout [lindex $args 1]] != -1 } {
		set timeout [expr [ns_time] + [util::nvl $timeout 86400]]
	    }
	    ns_mutex lock $cache_mutex
	    catch {
		nsv_set __ossweb_cache_timeout $key $timeout
		nsv_lappend __ossweb_cache $key [lindex $args 0]
	    }
	    ns_mutex unlock $cache_mutex
	}
	
	unset {
	    ns_mutex lock $cache_mutex
	    catch {
		if { [nsv_exists __ossweb_cache $key] } {
		    nsv_unset __ossweb_cache $key
		    nsv_unset __ossweb_cache_timeout $key
		}
	    }
	    ns_mutex unlock $cache_mutex
	}

	flush {
	    ns_mutex lock $cache_mutex
	    catch {
		foreach name [nsv_array names __ossweb_cache $key] {
		    catch { nsv_unset __ossweb_cache $name }
		    catch { nsv_unset __ossweb_cache_timeout $name }
		}
	    }
	    ns_mutex unlock $cache_mutex
	}
	
	names {
	    set result [list]
	    foreach name [nsv_array names __ossweb_cache $key] {
		lappend result $name
	    }
	    return $result
	}
	
	values {
	    set result [list]
	    foreach name [nsv_array names __ossweb_cache $key] {
		lappend result $name [nsv_get __ossweb_cache $name]
	    }
	    return $result
	}
	
	cleanup {
	    # Remove all expired entries from the cache
	    set time [ns_time]
	    ns_mutex lock $cache_mutex
	    catch {
		foreach { name timeout } [nsv_array get __ossweb_cache_timeout $key] {
		    if { $timeout > 0 && $timeout <= $time } {
			catch { nsv_unset __ossweb_cache $name }
			catch { nsv_unset __ossweb_cache_timeout $name }
		    }
		}
	    }
	    ns_mutex unlock $cache_mutex
	}
	
	default {
	    error "cache: Invalid command: $command"
	}
    }
}

proc ::memoize::session_cleanup {} {
    ::memoize::cache cleanup *
}


ad_schedule_proc 90 ::memoize::session_cleanup
