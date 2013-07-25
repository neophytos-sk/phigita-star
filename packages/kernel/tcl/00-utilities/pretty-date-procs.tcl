namespace eval ::util {;}
ad_proc -public ::util::age_pretty {
    -timestamp_ansi:required
    -sysdate_ansi:required
    {-hours_limit 12}
    {-days_limit 3}
    {-mode_2_fmt "%X, %A"}
    {-mode_3_fmt "%X, %d %b %Y"}
    {-locale ""}
    {-tz ""}
} {
    Formats past time intervals in one of three different modes depending on age.  The first mode is "1 hour 3 minutes" and is NOT currently internationalized.  The second mode is e.g. "14:10, Thursday" and is internationalized.  The th
ird mode is "14:10, 01 Mar 2001" and is internationalized.  Both the locale and the exact format string for modes 2 and 3 can be overridden by parameters.  (Once mode 1 is i18nd, the following sentence will be true:'In mode 1, only the
locale can be overridden.'  Until then, move along.  These aren't the timestamps you're looking for.)

    @param timestamp_ansi The older timestamp in full ANSI: YYYY-MM-DD HH24:MI:SS
    @param sysdate_ansi The newer timestamp.

    @param hours_limit The upper limit, in hours, for mode 1.
    @param days_limit The upper limit, in days, for mode 2.
    @param mode_2_fmt A formatting string, as per <a href="/api-doc/proc-view?proc=lc_time_fmt">lc_time_fmt</a>, for mode 2
    @param mode_3_fmt A formatting string, as per <a href="/api-doc/proc-view?proc=lc_time_fmt">lc_time_fmt</a>, for mode 3
    @param locale If present, overrides the default locale
    @return Interval between timestamp and sysdate, as localized text string.
} {

###ns_log notice "timestamp_ansi=$timestamp_ansi"

lassign [split $timestamp_ansi ".+"] timestamp_ansi __microseconds_and_tz__

#HERE 
set age_seconds [expr { [clock scan $sysdate_ansi] - [clock scan $timestamp_ansi] }]

###ns_log notice "age_seconds=$age_seconds"

if { $age_seconds < 30 } {
    # Handle with normal processing below -- otherwise this would require another string to localize
    set age_seconds 60
}

if { $age_seconds < [expr $hours_limit * 60 * 60] } {
    set hours [expr abs($age_seconds / 3600)]
    set minutes [expr round(($age_seconds% 3600)/60.0)]
    if {[expr $hours < 24]} {
	switch $hours {
	    0 { set result "" }
	    1 { set result "One hour " }
	    default { set result "$hours hours "}
	}
	switch $minutes {
	    0 {}
	    1 { append result "$minutes minute " }
	    default { append result "$minutes minutes " }
	}
    } else {
	set days [expr abs($hours / 24)]
	switch $days {
	    1 { set result "One day " }
	    default { set result "$days days "}
	}
    }

    append result "ago"
} elseif { $age_seconds < [expr { $days_limit * 60 * 60 * 24 }] } {
    set result [lc_time_fmt $timestamp_ansi $mode_2_fmt $locale]
} else {
    set result [lc_time_fmt $timestamp_ansi $mode_3_fmt $locale]
}
return $result
}


ad_proc -public ::util::clock_to_ansi {
    seconds
} {
    Convert a time in the Tcl internal clock seeconds format to ANSI format, usable by lc_time_fmt.

    @author Lars Pind (lars@pinds.com)
    @return ANSI (YYYY-MM-DD HH24:MI:SS) formatted date.
    @see lc_time_fmt
} {
    return [clock format $seconds -format "%Y-%m-%d %H:%M:%S"]
}




ad_proc -public ::util::pretty_relative_time {
    -timestamp_ansi:required
    -sysdate_ansi:required
    {-hours_limit 12}
    {-days_limit 3}
    {-mode_2_fmt "%X, %A"}
    {-mode_3_fmt "%X, %d %b %Y"}
    {-locale ""}
    {-tz ""}
} {
    Formats past time intervals in one of three different modes depending on age.  The first mode is "1 hour 3 minutes" and is NOT currently internationalized.  The second mode is e.g. "14:10, Thursday" and is internationalized.  The th
ird mode is "14:10, 01 Mar 2001" and is internationalized.  Both the locale and the exact format string for modes 2 and 3 can be overridden by parameters.  (Once mode 1 is i18nd, the following sentence will be true:'In mode 1, only the
locale can be overridden.'  Until then, move along.  These aren't the timestamps you're looking for.)

    @param timestamp_ansi The older timestamp in full ANSI: YYYY-MM-DD HH24:MI:SS
    @param sysdate_ansi The newer timestamp.

    @param hours_limit The upper limit, in hours, for mode 1.
    @param days_limit The upper limit, in days, for mode 2.
    @param mode_2_fmt A formatting string, as per <a href="/api-doc/proc-view?proc=lc_time_fmt">lc_time_fmt</a>, for mode 2
    @param mode_3_fmt A formatting string, as per <a href="/api-doc/proc-view?proc=lc_time_fmt">lc_time_fmt</a>, for mode 3
    @param locale If present, overrides the default locale
    @return Interval between timestamp and sysdate, as localized text string.
} {

if { $tz eq {} } {
    set tz :[ClockMgr getLocalTZ]
}

set seconds [expr { [clock scan $timestamp_ansi -timezone ${tz}] - [clock scan $sysdate_ansi] }]

if { $seconds < 0 } {
    return [::util::age_pretty -sysdate_ansi $sysdate_ansi -timestamp_ansi $timestamp_ansi -mode_2_fmt $mode_2_fmt -mode_3_fmt $mode_3_fmt]
}

if { $seconds < 30 } {
    # Handle with normal processing below -- otherwise this would require another string to localize
    set seconds 60
}

if { $seconds < [expr $hours_limit * 60 * 60] } {
    set hours [expr abs($seconds / 3600)]
    set minutes [expr round(($seconds% 3600)/60.0)]
    if {[expr $hours < 24]} {
	switch $hours {
	    0 { set result "" }
	    1 { set result "One hour " }
	    default { set result "$hours hours "}
	}
	switch $minutes {
	    0 {}
	    1 { append result "$minutes minute " }
	    default { append result "$minutes minutes " }
	}
    } else {
	set days [expr abs($hours / 24)]
	switch $days {
	    1 { set result "One day " }
	    default { set result "$days days "}
	}
    }

    append result "to go"
} elseif { $seconds < [expr { $days_limit * 60 * 60 * 24 }] } {
    set result [lc_time_fmt $timestamp_ansi $mode_2_fmt $locale]
} else {
    set result [lc_time_fmt $timestamp_ansi $mode_3_fmt $locale]
}
return $result
}
