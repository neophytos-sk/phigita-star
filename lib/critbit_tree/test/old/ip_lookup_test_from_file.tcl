source ../../naviserver_compat/tcl/module-naviserver_compat.tcl
::xo::lib::require critbit_tree

proc parseInt {binary_value} {
    binary scan $binary_value I val
    set val [expr { $val & 0xFFFFFFFF}]
    return $val
}


set blocks_cbt [::cbt::create]
::cbt::read_from_file $blocks_cbt "test.out"


set type_of_search "prefix" 
#set type_of_search "exact"
set result ""
foreach query_ip {
    81.0.74.35
    81.0.74.235
    81.90.21.33
    81.0.74.208
} {

    if { $type_of_search eq {prefix} } {
	set match [cbt::prefix_match $blocks_cbt [binary format I [ip2val $query_ip]]]
    } elseif { $type_of_search eq {exact} } {
	set match [cbt::exact_match $blocks_cbt [binary format I [ip2val $query_ip]]]
    } else {
	error "unknown type of search requested"
    }

    set location_id ""
    set lo_ip ""
    if { $match ne {} } {
        lassign [split $match =] lo_ip location_id
	set best_match_ip [val2ip [parseInt $lo_ip]]
	append result "\n Query IP: $query_ip => Match: lower_bound_IP=$best_match_ip location_id=$location_id"
    } else {
	append result "\n Query IP: $query_ip => no ${type_of_search} match found"
    }
}


puts $result

puts to_string=[::cbt::to_string $blocks_cbt]
puts =================
::cbt::bytes $blocks_cbt
::cbt::write_to_file $blocks_cbt "test.out"