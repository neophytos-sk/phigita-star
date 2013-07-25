source ../../naviserver_compat/tcl/module-naviserver_compat.tcl
::xo::lib::require critbit_tree

proc parseUnsignedInt {binary_value} {
    binary scan $binary_value I* val
    set val [expr {$val & 0xFFFFFFFF}] ;# if you want to produce an unsigned value, then you can mask the return value to the desired size
    return $val
}


proc ip_locate {blocks_cbt query_ip {msgVar ""}} {

    if { $msgVar ne {} } {
	upvar $msgVar msg
    }

    set query_ip_val [ip2val $query_ip]
    set match [::cbt::prefix_match $blocks_cbt [binary format I $query_ip_val]]
    set location_id ""
    set lo_ip ""
    if { $match ne {} } {
        lassign [split $match {=_}] lo_bin hi_diff location_id
	#puts match=$match
	set lo [parseUnsignedInt $lo_bin]
	#puts "lo=$lo hi_diff=$hi_diff query_ip_val=$query_ip_val"
	set hi [expr { $lo + $hi_diff }]
	set best_match_ip [val2ip $lo]
	#puts "lo=[ip2val $best_match_ip]"
	if { $lo <= $query_ip_val && $query_ip_val <= $hi } {
	    set msg "Query IP: $query_ip => Match: ${best_match_ip} - [val2ip $hi] => location_id=$location_id"
	    return $location_id
	} else {
	    set msg "Query IP: $query_ip => found a match ( ${best_match_ip} - [val2ip $hi] ) but ip not in the given range"
	    return
	}
    } else {
	set msg "Query IP: $query_ip => no prefix match found"
	return
    }

    return $location_id
}


set startTime [clock clicks -milliseconds]
set blocks_cbt [::cbt::create $::cbt::UINT64_KEYS "../data/geoip_blocks.cbt_db"]
set endTime [clock clicks -milliseconds]
puts "loading geoip_blocks.cbt_db took [expr { $endTime - $startTime }]ms"

set startTime [clock clicks]
set result ""
foreach query_ip {
    81.0.74.35
    81.0.74.235
    81.90.21.33
    222.17.168.123
    127.0.0.1
} {


    set location_id [ip_locate $blocks_cbt $query_ip message]
    puts "location_id=$location_id ($message)"

}
set endTime [clock clicks]

puts $result

puts "all of the queries took [expr {$endTime - $startTime}] clock clicks"