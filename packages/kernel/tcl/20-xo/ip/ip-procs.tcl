namespace eval ::xo {;}
namespace eval ::xo::ip {;}


proc ::xo::ip::Normalize4 {ip} {
    set octets [split $ip .]
    if {[llength $octets] > 4} {
        return -code error "invalid ip address \"$ip\""
    } elseif {[llength $octets] < 4} {
        set octets [lrange [concat $octets 0 0 0] 0 3]
    }
    foreach oct $octets {
        if {$oct < 0 || $oct > 255} {
            return -code error "invalid ip address"
        }
    }
    return [binary format c4 $octets]
}


proc ::xo::ip::toInteger {ip} { 
    binary scan [::xo::ip::Normalize4 $ip] Iu out
    return $out
}

# Convert an IPv4 address in dotted quad notation into a hexadecimal 
# representation. BE CAREFUL - no validation checks are performed
proc ::xo::ip::to_hex {ip} {
    set octets [split $ip {.}]
    binary scan [binary format c4 $octets] H8 x
    return ${x}
}


proc ::xo::ip::from_hex {ip_hex} {
    if { $ip_hex eq {} } return
    return [val2ip [expr "0x$ip_hex"]]


}


proc ip2val {str} {
    set rc 0
    foreach v [lrange [split $str .] 0 3] {
	if {[catch {
	    set v [expr {($v & 0xff)}]
	}]} {
	        set v 0
	}
	set rc [expr {($rc << 8) + $v}]
    }
    return $rc
}

proc val2ip {v} {
    return [format %d.%d.%d.%d \
		[expr {(($v >> 24) & 0xff)}] \
		[expr {(($v >> 16) & 0xff)}] \
		[expr {(($v >>  8) & 0xff)}] \
		[expr  {($v & 0xff)}] \
		]
}
