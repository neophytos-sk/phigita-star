source ../../naviserver_compat/tcl/module-naviserver_compat.tcl
::xo::lib::require critbit_tree

proc parseUnsignedInt {binary_value} {
    binary scan $binary_value I* val
    set val [expr {$val & 0xFFFFFFFF}] ;# if you want to produce an unsigned value, then you can mask the return value to the desired size
    return $val
}

set blocks_cbt [::cbt::create]
set filename ../data/geoip_blocks.csv
set fp [open $filename]
while { [gets $fp line] >= 0 } {
    lassign [split $line {|}] lo hi_diff location_id
    #puts "adding ip range: lo=[val2ip $lo] hi_diff=$hi_diff location_id=$location_id"
    set data [binary format I $lo]=${hi_diff}_${location_id}
    ::cbt::insert $blocks_cbt $data
    #if { [incr count] > 2000000 } break
}
close $fp

set result ""
foreach query_ip {
    81.0.74.35
    81.0.74.235
    81.90.21.33
    222.17.168.123
} {
    set query_ip_val [ip2val $query_ip]
    set match [::cbt::prefix_match $blocks_cbt [binary format I $query_ip_val]]

    set location_id ""
    set lo_ip ""
    if { $match ne {} } {
        lassign [split $match {=_}] lo_bin hi_diff location_id
	#puts match=$match
	set lo [parseUnsignedInt $lo_bin]
	puts "lo=$lo hi_diff=$hi_diff query_ip_val=$query_ip_val"
	set hi [expr { $lo + $hi_diff }]
	set best_match_ip [val2ip $lo]
	puts "lo=[ip2val $best_match_ip]"
	if { $lo <= $query_ip_val && $query_ip_val <= $hi } {
	    append result "\n Query IP: $query_ip => Match: ($best_match_ip - [val2ip $hi]) location_id=$location_id"
	} else {
	    append result "\n Query IP: $query_ip => found a match ($best_match_ip - [val2ip $hi]) but ip not in the given range"
	}
    } else {
	append result "\n Query IP: $query_ip => no prefix match found"
    }
}


puts $result