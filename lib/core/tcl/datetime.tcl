namespace eval ::dt {;}

proc ::dt::timestamp_to_age {timeval} {

    set now [clock seconds]
    set secs [expr { $now - $timeval }]

    set secs_in_year [expr { 86400 * 365 }]
    set secs_in_month [expr { 86400 * 30 }]
    set secs_in_week [expr { 86400 * 7 }]
    set secs_in_day "86400"
    set secs_in_hour "3600"
    set secs_in_minutes "60"

    set age ""
    foreach {secs_in_unit singular_form plural_form} {
        31536000 year years
        2592000 month months
        604800 week weeks
        86400 day days
        3600 hour hours
        60 min mins
    } {
        if { $secs > $secs_in_unit } {
            if { $age ne {} } {
                append age " "
            }
            set num [expr { int ($secs / $secs_in_unit) }]
            append age ${num} " "
            if { $num == 1 } {
                append age $singular_form
            } else {
                append age $plural_form
            }
            set timeval [expr { $secs / $num }]
        }
    }

    return $age
}

proc ::dt::age_to_timestamp {age timeval} {

    set sign "-"
    if { [lindex ${timeval} end] eq {ago} } {
	set age  [lrange ${age} 0 end-1]
	set sign "-"
    }

    set secs 0
    foreach {num precision} ${age} {
	switch -exact ${precision} {
	    sec -
	    secs -
	    second -
	    seconds  { incr secs ${num} }
	    min -
	    mins -
	    minute -
	    minutes  { incr secs [expr { ${num} * 60 }] }
	    hour -
	    hours  { incr secs [expr { ${num} * 3600 }] }
	    day -
	    days  { incr secs [expr { ${num} * 86400 }] }
	    week - 
	    weeks  { incr secs [expr { ${num} * 86400 * 7 }] }
	    month -
	    months  { incr secs [expr { ${num} * 86400 * 30 }] }
	    year -
	    years  { incr secs [expr { ${num} * 86400 * 365 }] }
	}
    }

    incr timeval "${sign}${secs}"
    set timestamp [clock format ${timeval} -format "%Y%m%dT%H%M"]

    return ${timestamp}
}



