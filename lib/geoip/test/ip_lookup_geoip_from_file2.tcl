source ../../naviserver_compat/tcl/module-naviserver_compat.tcl
#::xo::lib::require critbit_tree
::xo::lib::require geoip

::xo::geoip::init ;# read geoip.blocks database into a critbit tree

set startTime [clock clicks]
set count 0
set result ""
foreach query_ip {
    81.0.74.35
    81.0.74.235
    81.90.21.33
    222.17.168.123
    127.0.0.1
    88.131.106.2
    95.111.52.5
    95.195.83.200
    88.131.106.3
    88.131.106.7
    213.74.106.11
    67.195.112.181
    207.46.194.37
    207.46.195.106
    207.46.204.243
    83.168.62.148
    109.242.154.114
    67.195.112.181
    72.14.199.134
    188.138.16.154
    173.192.238.37
} {
    # The following addresses do not exist in db either:
    # 127.0.0.1
    # 95.111.52.5
    # 109.242.154.114
    # 188.138.16.154 
    set location_id [::xo::geoip::ip_locate $query_ip]
    puts "query_ip=$query_ip location_id= $location_id"
    incr count
}
set endTime [clock clicks]

puts $result
set duration [expr {$endTime - $startTime}]
set average_duration [expr {$duration / $count}]
puts "all $count queries took ${duration} clicks average=${average_duration} clicks"