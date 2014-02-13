source ../../naviserver_compat/tcl/module-naviserver_compat.tcl
::xo::lib::require critbit_tree

proc parseInt {binary_value} {
    binary scan $binary_value I val
    set val [expr { $val & 0xFFFFFFFF}]
    return $val
}


set addresses {
    81.0.0.0 68
    81.0.64.0 21973
    81.0.72.0 49828
    81.0.74.0 21973
    81.0.74.32 56053
    81.0.74.40 50265
    81.0.74.48 21973
    81.0.74.64 55191
    81.0.74.80 50265
    81.0.74.128 2197
    81.89.4.16 50265
    81.100.74.136 50265
    81.0.74.144 21973
    81.0.74.168 50265
    81.0.74.176 21973
    81.0.74.184 50265
    81.0.74.192 59301
    81.0.74.200 50265
    81.0.74.208 21973
    81.0.74.216 50265
    81.0.74.224 21973
    81.0.74.232 50265
    81.0.74.240 21973
    81.0.75.8 50265
}

puts $addresses

set blocks ""
foreach {ip location_id} $addresses {
    lappend blocks [binary format I [ip2val $ip]]=${location_id}
}

#::xo::cbt::create blocks_cbt
::cbt::create blocks_cbt
puts handle=[::cbt::id blocks_cbt]
set type_of_search "prefix" 
#set type_of_search "exact"
set result ""
foreach query_ip {
    81.0.74.35
    81.0.74.235
    81.90.21.33
    81.0.74.208
} {
    #set blocks_cbt [cbt_convert $blocks]
    ::cbt::extend $blocks_cbt $blocks
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
#::cbt::bytes $blocks_cbt
#::cbt::write_to_file $blocks_cbt "test.out"

puts "== Test DestroyCmd =="
::cbt::destroy $blocks_cbt
puts "handle(after destroy)=[::cbt::id $blocks_cbt]"