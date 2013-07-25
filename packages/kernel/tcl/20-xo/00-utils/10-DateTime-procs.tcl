
namespace eval ::xo::dt {;}

proc ::xo::dt::today {} {
    return [clock format [clock seconds] -format "%Y-%m-%d"]
}


proc ::xo::dt::date_compare {date1 date2 {format "%Y-%N-%d"}} {
    set d1 [clock scan $date1 -format ${format}]
    set d2 [clock scan $date2 -format ${format}]

    if { ${d1} < ${d2} } {
	return -1
    } elseif { ${d1} > ${d2} } {
	return 1
    } else {
	return 0
    }
}

proc ::xo::dt::max_date {date1 date2 {format "%Y-%N-%d"}} {

    if { 1 == [::xo::dt::date_compare ${date1} ${date2} ${format}] } {
	return $date1
    } else {
	return $date2
    }
    
}

proc ::xo::dt::min_date {date1 date2 {format "%Y-%N-%d"}} {

    if { 1 == [::xo::dt::date_compare ${date1} ${date2} ${format}] } {
	return $date2
    } else {
	return $date1
    }
    
}


proc ::xo::dt::range_overlap {r1_start_date r1_end_date r2_start_date r2_end_date} {
    set r1s_r2s_cmp [::xo::dt::date_compare $r1_start_date $r2_start_date]
    set r2e_r1e_cmp [::xo::dt::date_compare $r2_end_date $r1_end_date]

    if { -1 == $r1e_r2s_cmp } {
	# no overlap and r1 earlier than r2
	return -1
    } elseif  { -1 == $r2e_r1s_cmp } {
	# no overlap and r1 later than r2
	return 1
    } else {
	# with overlap
	return 0
    }
}

