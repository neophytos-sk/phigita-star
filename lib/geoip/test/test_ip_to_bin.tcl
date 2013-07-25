source ../../naviserver_compat/tcl/module-naviserver_compat.tcl
::xo::lib::require geoip

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
} {

    puts [::xo::net::iptoc4 $query_ip]

    continue

    set query_ip_val [::xo::net::iptoul $query_ip]
    set val_bin [::util::ultobin $query_ip_val]
    binary scan $val_bin c* c4
    puts "query_ip=$query_ip val=$query_ip_val => c4=$c4"
}