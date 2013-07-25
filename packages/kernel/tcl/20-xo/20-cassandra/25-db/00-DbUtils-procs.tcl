namespace eval ::xo::db {;}

proc ::xo::db::tcl_date {timestamp tz_var} {
    upvar $tz_var tz
    set tz 00
    # Oracle style format like 2008-08-25 (no TZ)
    if {![regexp {^([0-9]+-[0-9]+-[0-9]+)$} $timestamp _ timestamp]} {
	# PostgreSQL type ANSI format
	if {![regexp {^([^.]+)[.][0-9]*([+-][0-9]*)$} $timestamp _ timestamp tz]} {
	    regexp {^([^.]+)([+-][0-9]*)$} $timestamp _ timestamp tz
	}
    }
    return $timestamp
}