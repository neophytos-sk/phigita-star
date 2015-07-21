package require core

package require geoip

::xo::geoip::init


# phigita.net
# google.com
# google.com.cy
set addresses {
    213.7.230.145
    195.14.151.20
    173.194.40.20
}

foreach query_ip $addresses {
    set location_id [::xo::geoip::ip_locate $query_ip lo high]
    if { ${location_id} ne {} } {
        puts "location_id=$location_id lo=$lo high=$high"
    } else {
        puts "location for ip=\"$query_ip\" not found"
    }
}
