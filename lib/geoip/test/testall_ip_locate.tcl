source ../../naviserver_compat/tcl/module-naviserver_compat.tcl

#::xo::lib::require critbit_tree
::xo::lib::require geoip

::xo::geoip::init ;# read geoip.blocks database into a critbit tree

set blocks_cbt [::cbt::id geoip.blocks]



set startTime [clock clicks]
foreach entry [::cbt::to_string $blocks_cbt] {
    binary scan $entry a4 query_ip_bin
    set query_ip_val [::util::parseUnsignedLong $query_ip_bin]
    set query_ip [::xo::net::ultoip $query_ip_val]
    set location_id [::xo::geoip::ip_locate $query_ip]
    #puts "location_id= $location_id"
    if { [incr count] % 100000 == 0 } { puts $count }
}
set endTime [clock clicks]

puts "all of the queries took [expr {$endTime - $startTime}] clock clicks"