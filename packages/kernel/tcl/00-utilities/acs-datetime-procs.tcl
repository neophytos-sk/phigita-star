# /packages/acs-datetime/tcl/acs-datetime-procs.tcl

ad_library {

    Tcl library for the ACS Date-Time service package

    @author  ron@arsdigita.com
    @creation-date 2000-11-21
    @cvs-id  $Id: acs-datetime-procs.tcl,v 1.1.1.1 2002/11/22 09:47:33 nkd Exp $
}

ad_proc dt_systime {
    {-format "%Y-%m-%d %H:%M:%S"}
    {-gmt f}
} {
    Returns current server time in the standard format "yyyy-mm-dd
    hh:mi:ss".  With the optional -gmt flag it returns the time in
    GMT. 
} {
    return [clock format [clock seconds] -format $format -gmt $gmt]
}
    
ad_proc dt_sysdate {
    {-format "%Y-%m-%d"}
} {
    Returns current server date in the standard format "yyyy-mm-dd"
} {
    return [clock format [clock seconds] -format $format]
}

ad_proc dt_valid_time_p { 
    time 
} {
    Returns 1 if "time" is a valid time specification, 0 otherwise.
} {
    if [catch { clock scan $time }] {
	return 0
    } else {
	return 1
    }
}

ad_proc dt_format {
    {-format "%Y-%m-%d %H:%M:%S"}
    {-gmt f}
    time
} {
    return [clock format [clock scan $time] -format $format -gmt $gmt]
}

ad_proc dt_month_names {} {
    Returns the calendar month names as a Tcl list (January, February, ...)
} {
    set month_names [list]
    
    for {set i 1} {$i <= 12} {incr i} {
	lappend month_names [clock format [clock scan "2000-$i-1"] -format "%B"]
    }

    return $month_names
}

ad_proc dt_month_abbrev {} {
    Returns the calendar month names as a Tcl list (Jan, Feb, ...)
} {
    set month_names [list]
    
    for {set i 1} {$i <= 12} {incr i} {
	lappend month_names [clock format [clock scan "2000-$i-1"] -format "%b"]
    }

    return $month_names
}

ad_proc dt_ansi_to_julian {
    year
    month
    day
    {era ""}
} {
    Returns the ANSI date as Julian or -1 in the case
    of an invalid ANSI date argument (year less than
    4713 BCE, greater than 9999 CE, or equal to 0)
} {
    if [empty_string_p $era] {
        set era CE
    }

    if {$year == 0} {
        set julian_date -1
    } elseif {$year == 1582 && $month == 10 && $day > 4 && $day < 15} {
        # mimic the functionality of Oracle for these non-existent
        # gregorian dates (returns the julian date of the day following
        # 1582-10-04; 1582-10-15)
        set julian_date [dt_ansi_to_julian 1582 10 15 CE]
    } else {
        if {$era == "BCE"} {
            set year [expr -$year + 1]
        }

        if {$month > 2} {
            set year_n $year
            set month_n [expr $month + 1]
        } else {
            set year_n [expr $year - 1]
            set month_n [expr $month + 13]
        }

        set julian_date [expr floor(floor(365.25 * $year_n) + floor(30.6001 * $month_n) + ($day + 1720995))]

        # check for change to the Gregorian Calendar
        set gregorian [expr 15 + 31 * (10 + 12 * 1582)]
        if {$day + 31 * ($month + 12 * $year) >= $gregorian} {
            set julian_date [expr $julian_date + (2 - floor(0.01 * $year_n) + floor(0.25 * floor(0.01 * $year_n)))]
        }
    }

    return [expr int($julian_date)]
}

ad_proc dt_julian_to_ansi {
    julian_date
} {
    Returns julian_date formatted as "yyyy-mm-dd"
} {
    # Gregorian calendar correction
    set gregorian 2299161

    if {$julian_date >= $gregorian} {
      set calc [expr floor((($julian_date - 1867216) - 0.25) / 36524.25)]
      set calc [expr $julian_date + 1 + $calc - floor(0.25 * $calc)]
    } else {
      set calc $julian_date
    }

    # get initial calculations to set year, month, day
    set calc [expr $calc + 1524]
    set calc2 [expr floor(6680 + (($calc - 2439870) - 122.1) / 365.25)]
    set calc3 [expr floor($calc2 * 365.25)]
    set calc4 [expr floor(($calc - $calc3) / 30.6001)]

    # set year, month, day
    set year [expr floor($calc2 - 4715)]
    set month [expr floor($calc4 - 1)]
    if {$month > 12} {
      set month [expr $month - 12]
    }
    if {$month > 2 || $year <= 0} {
      set year [expr $year - 1]
    }
    set day [expr floor($calc - $calc3 - floor($calc4 * 30.6001))]

    set year [expr int($year)]
    set month [expr int($month)]
    set day [expr int($day)]

    if {$month < 10} {
      set month 0$month
    }

    if {$day < 10} {
      set day 0$day
    }

    return $year-$month-$day
}

ad_proc dt_ansi_to_pretty {
    {ansi_date ""}
} {
    Converts 1998-09-05 to September 5, 1998.  With no argument it
    returns the current date based on server time.  Works for both
    date and date-time strings.
} {
    if [empty_string_p $ansi_date] {
	set ansi_date [dt_sysdate]
    }

    set date [clock scan $ansi_date]
    set day  [clock format $date -format "%e"]

    return [clock format $date -format "%B [string trim $day], %Y"]
}

ad_proc dt_ansi_to_list {
    {ansi_date ""}
} {
    Parses the given ansi_date string into a list of year, month, day,
    hour, minute, and second. Works for any date than can be parsed
    by clock scan. 
} {
    if [empty_string_p $ansi_date] {
	set ansi_date [dt_systime]
    }

    foreach item [split [clock format [clock scan $ansi_date] -format "%Y %m %d %H %M %S"] " "] { 
	lappend date_info [dt_trim_leading_zeros $item]
    }
    
    return $date_info
}

ad_proc dt_num_days_in_month {
    year
    month
} {
    Returns the numbers of days for the given month/year
} {
    if {$month == 0} {
      set month 01
    } elseif {$month == 12} {
      set year [expr $year + 1]
      set month 01
    } elseif {$month == 13} {
      set year [expr $year + 1]
      set month 02
    } else {
      set month [expr $month + 1]
    }

    return [clock format [clock scan "last day" -base [clock scan $year-$month-01]] -format %d]
}

ad_proc dt_first_day_of_month {
    year
    month
} {
    Returns the weekday number of the first day for the given month/year
} {
    # calendar widgets are expecting integers 1-7, so we must adjust
    return [expr [clock format [clock scan $year-$month-01] -format %w] + 1]
}

ad_proc dt_next_month {
    year
    month
} {
    Returns the ANSI date for the next month
} {
    if {$month == 12} {
      set year [expr $year + 1]
      set month 01
    } else {
      set month [expr $month + 1]
    }

    return [clock format [clock scan $year-$month-01] -format %Y-%m-%d]
}

ad_proc dt_prev_month {
    year
    month
} {
    Returns the ANSI date for the previous month
} {
    if {$month == 1} {
      set year [expr $year - 1]
      set month 12
    } else {
      set month [expr $month - 1]
    }

    return [clock format [clock scan $year-$month-01] -format %Y-%m-%d]
}

ad_proc dt_next_month_name {
    year
    month
} {
    Returns the ANSI date for the next month
} {
    if {$month == 12} {
      set year [expr $year + 1]
      set month 01
    } else {
      set month [expr $month + 1]
    }

    return [clock format [clock scan $year-$month-01] -format %B]
}

ad_proc dt_prev_month_name {
    year
    month
} {
    Returns the ANSI date for the previous month
} {
    if {$month == 1} {
      set year [expr $year - 1]
      set month 12
    } else {
      set month [expr $month - 1]
    }

    return [clock format [clock scan $year-$month-01] -format %B]
}

ad_proc -public dt_widget_datetime { 
    {-show_date 1}
    {-date_time_sep "&nbsp;"}
    {-use_am_pm 0}
    {-default none}
    {name}
    {granularity days}
} {

    Returns an HTML form fragment for collecting date-time
    information with names "$name.year", "$name.month", "$name.day",
    "$name.hours", "$name.minutes", "$name.seconds", and "$name.ampm".
    These will be numeric ("ampm" is 0 for am, 1 for pm) 

    Default specifies what should be set as the current time in the
    form. Valid defaults are "none", "now", or any valid date string
    that can be converted with clock scan.

    Granularity can be "months" "days" "hours" "halves" "quarters"
    "fives" "minutes" or "seconds".

    Use -show_date 0 for a time entry widget (no dates).

    All HTML widgets will be output *unless* show_date is 0; they will
    be hidden if not needed to satisfy the current granularity
    level. Values default to 1 for MM/DD and 0 for HH/MI/SS/AM if not 
    found in the input string or if below the granularity threshold.
} {
    set to_precision [dt_precision $granularity]

    set show_day     [expr $to_precision < 1441]
    set show_hours   [expr $to_precision < 61]
    set show_minutes [expr $to_precision < 60]
    set show_seconds [expr $to_precision < 1]

    if {$to_precision == 0} { 
	set to_precision 1 
    }

    switch $default {
	none    { set value [dt_systime] }
	now     { set value [dt_systime] }
	default { set value [dt_format $default] }
    }

    set parsed_date [dt_ansi_to_list $value]
    set year        [lindex $parsed_date 0]
    set month       [lindex $parsed_date 1]
    set day         [lindex $parsed_date 2]
    set hours       [lindex $parsed_date 3]
    set minutes     [lindex $parsed_date 4]
    set seconds     [lindex $parsed_date 5]

    # Kludge to get minutes rounded.  Should make general-purpose for
    # the other values too...

    if {$to_precision < 60} {
        set minutes [expr [dt_round_to_precision $minutes $to_precision] % 60]
    }

    if {$default == "none"} {
        set year    ""
        set month   ""
        set day     ""
        set hours   ""
        set minutes ""
        set seconds ""
    }

    if {$show_date} {
        append input [dt_widget_month_names "$name.month" $month]
        append input [dt_widget_maybe_range $show_day "$name.day" 1 31 $day 1 0 1]
        append input "<input name=\"$name.year\" size=5 maxlength=4 value=\"$year\"> $date_time_sep "
    }

    if {$use_am_pm} {
        if { $hours > 12 } {
            append input [dt_widget_maybe_range \
		    $show_hours "$name.hours" 1 12 [expr {$hours - 12}] 1 0]
        } elseif {$hours == 0} {
            append input [dt_widget_maybe_range \
		    $show_hours "$name.hours" 1 12 12 1 0]
        } else {
            append input [dt_widget_maybe_range \
		    $show_hours "$name.hours" 1 12 $hours 1 0]
        }
    } else {
        append input [dt_widget_maybe_range \
		$show_hours "$name.hours" 0 23 $hours 1 0]
    }

    if {$show_minutes} { 
	append input ":" 
    }

    append input [dt_widget_maybe_range \
	    $show_minutes "$name.minutes" 0 59 $minutes $to_precision 1]

    if {$show_seconds} { 
	append input ":" 
    }

    append input [dt_widget_maybe_range \
	    $show_seconds "$name.seconds" 0 59 $seconds 1 1]

    if {$use_am_pm} {
        if {$hours < 12 || ! $show_hours} {
            set am_selected " selected"
            set pm_selected ""
        } else {
            set am_selected ""
            set pm_selected " selected"
        }

        append input "
        <select name=\"${name}.ampm\">
        <option value=0${am_selected}>AM
        <option value=1${pm_selected}>PM
        </select>"
    } else {
        append input [dt_export_value "${name}.ampm" "AM"]
    }

    return $input
}

ad_proc dt_widget_month_names { 
    name 
    {default ""}
} {
    Returns a select widget for months of the year. 
} {
    set month_names [dt_month_names]
    set default     [expr $default-1]
    set input       "<option value=_undef>---------"

    for {set i 0} {$i < 12} {incr i} {
	append input "<option [expr {$i == $default ? "selected" : ""}] value=[expr $i+1]>[lindex $month_names $i]\n"
    }
    
    return "<select name=\"$name\">\n $input \n </select>\n"
}

ad_proc dt_widget_numeric_range { 
    name 
    begin 
    end 
    {default ""} 
    {interval 1} 
    {with_leading_zeros 0}
} {
    Returns an HTML select widget for a numeric range
} {
    if $with_leading_zeros {
	set format "%02d"
    } else {
	set format "%d"
    }

    if ![empty_string_p $default] {
	set default [dt_trim_leading_zeros $default]
    }

    set input "<option value=_undef>--\n"

    for { set i $begin } { $i <= $end } { incr i $interval} {
	append input "[expr {$i == $default ? "<option selected>" : "<option>"}][format $format $i]\n"
    }

    return "<select name=\"$name\">\n$input</select>"
}

ad_proc dt_widget_maybe_range {
    {-hide t}
    {-hidden_value "00"}
    {-default ""}
    {-format "%02d"}
    ask_for_value 
    name 
    start
    end
    default_value 
    {interval 1} 
    {with_leading_zeros 0} 
    {hidden_value "00"}
} {
    Returns form numeric range, or hidden_value if ask_for_value is false.
} {
    if !$ask_for_value {
        # Note that this flattens to hidden_value for hidden fields
        if $with_leading_zeros {
            return [dt_export_value $name $hidden_value]
        } else {
            return [dt_export_value $name [dt_trim_leading_zeros $hidden_value]]
        }
    }

    return [dt_widget_numeric_range \
	    "$name" $start $end $default_value $interval $with_leading_zeros]
}

ad_proc dt_interval_check { start end } {

    Checks the values of start and end to see if they form a valid
    time interval.  Returns:

    > 0  if end > start
      0  if end = start
    < 0  if end < start

    Input variables can be any strings that can be converted to times
    using clock scan.
} {
    return [expr [clock scan $end]-[clock scan $start]]
}

ad_proc -private dt_trim_leading_zeros { 
    string 
} {
    Returns a string w/ leading zeros trimmed.
    Used to get around TCL interpreter problems w/ thinking leading
    zeros are octal. We could just use validate_integer, but it runs
    one extra regexp that we don't need to run. 
} {
    set string [string trimleft $string 0]

    if [empty_string_p $string] {
        return "0"
    }

    return $string
}

ad_proc -private dt_export_value { 
    name 
    value 
} {
    Makes a hidden form item w/ given name and value
} {
    return "<input name=\"$name\" type=hidden value=\"$value\">"
}

ad_proc -private dt_round_to_precision { 
    number 
    precision 
} {

    Rounds the given number to the given precision,
    i.e. <tt>calendar_round_to_precision 44 5</tt> will round to the
    nearest 5 and return 45, while <tt>calendar_round_to_precision
    32.678 .1</tt> will round to 32.7.

} {
    return [expr $precision * round(double($number)/$precision)]
}

ad_proc -private dt_precision {
    granularity
} {
    Returns the precision in minutes corresponding to a named
    granularity 
} {
    switch -exact $granularity {
	months   { set precision 40000}
	days     { set precision 1440}
	hours    { set precision 60}
	halves   { set precision 30}
	quarters { set precision 15}
	fives    { set precision 5}
	minutes  { set precision 1}
	seconds  { set precision 0}
	default  { set precision 15}
    }

    return $precision
}

