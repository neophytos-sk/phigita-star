namespace eval ::dt {
    namespace ensemble create -subcommands {resolve}
}
proc ::dt::resolve {base_dt other_dt} {

    set result_dt ""

    if { $other_dt ne {} } {

        lassign [split $other_dt {T}] other_dt_date other_dt_time

        if { ${other_dt_time} ne {0000} } {
            # up to 15mins difference in time it is considered to be
            # fine to take into account servers at different timezones
            #
            # abs is to account for news sources that set a time in the
            # future be it due to timezone difference or deliberately
            #
            set base_timeval [clock scan $base_dt -format "%Y%m%dT%H%M"]
            set other_timeval [clock scan $other_dt -format "%Y%m%dT%H%M"]
            if { $base_timeval - $other_timeval > 900 } {
                set result_dt $other_dt
            } else {
                # use computed date for sorting
                set result_dt $base_dt
            }
        } else {
            # if other_dt.time eq {0000}
            lassign [split $base_dt {T}] base_dt_date base_dt_time
            if { ${other_dt_date} < ${base_dt_date} } {
                set result_dt $other_dt
            } else {
                # use computed date for sorting
                set result_dt $base_dt
            }
        }
    } else {
        # use computed date for sorting
        set result_dt $base_dt
    }

    return $result_dt

}

proc ::dt::timestamp_to_age {timeval {short_form_p 1}} {

    set now [clock seconds]
    set secs [expr { $now - $timeval }]

    set secs_in_year [expr { 86400 * 365 }]
    set secs_in_month [expr { 86400 * 30 }]
    set secs_in_week [expr { 86400 * 7 }]
    set secs_in_day "86400"
    set secs_in_hour "3600"
    set secs_in_minutes "60"

    set age ""
    foreach {secs_in_unit short_form singular_form plural_form} {
        31536000 y year years
        2592000 mo month months
        604800 w week weeks
        86400 d day days
        3600 h hour hours
        60 m min mins
    } {
        if { $secs > $secs_in_unit } {
            if { $age ne {} } {
                append age " "
            }
            set num [expr { int ($secs / $secs_in_unit) }]
            if { $short_form_p } {
                append age ${num}
                append age $short_form
            } else {
                append age ${num} " "
                if { $num == 1 } {
                    append age $singular_form
                } else {
                    append age $plural_form
                }
            }
            set secs [expr { $secs - ($num * $secs_in_unit) }]
        }
    }

    if { $age eq {} } {
        set age "0m"
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



