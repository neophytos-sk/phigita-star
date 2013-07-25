package provide geoip 0.1

::xo::lib::require critbit_tree

namespace eval ::xo::net {;}
proc ::xo::net::is_private_p {ip} {
    lassign [split $ip .] a b c d
    if { $a eq {} || $b eq {} || $c eq {} || $d eq {} || 
         $a == 10 || 
         ($a == 172  && $b >= 16 && $b <= 31) ||
         ($a == 192  && $b == 168) ||
         $a == 239  ||
         $a == 0    ||
         $a == 127
     } {
        return 1
    }
    return 0
}

# unsigned long to ip
proc ::xo::net::uint32_to_ip {num} {
    return [format "%d.%d.%d.%d" \
		[expr ($num >> 24) & 0xff] \
		[expr ($num >> 16) & 0xff] \
		[expr ($num >> 8)  & 0xff] \
		[expr $num         & 0xff]]
}

# convert ip to four char bytes
proc ::xo::net::iptoc4 {ip} {
    set bytes [split ${ip} {.}]
    return [format "%c%c%c%c" {*}${bytes}]
}

# ip to unsigned long
# expr {$val & 0xFFFFFFFF} - produce an unsigned value, mask to the desired size
proc ::xo::net::ip_to_uint32 {ip} {
    if {[scan $ip "%d.%d.%d.%d" a b c d] == 4} {
        foreach i "$a $b $c $d" {
            if {($i > 255) || ($i < 0)} {
                return ""
            }
        }
	set long [expr { ($a << 24 | $b << 16 | $c << 8 | $d) & 0xFFFFFFFF }]
        #if {$long < 0} {
        #    set long [expr pow(2, 32) + $long]
        #}
        return $long
    } else {
        return ""
    }
}


namespace eval ::util {;}

proc ::util::int_to_c4 {num} {
    return [format "%c%c%c%c" \
		[expr ($num >> 24) & 0xff] \
		[expr ($num >> 16) & 0xff] \
		[expr ($num >> 8)  & 0xff] \
		[expr $num         & 0xff]]
}


proc ::util::uint32_to_bin {val} {
    return [binary format I* $val]
}

# expr {$val & 0xFFFFFFFF} to produce an unsinged value (see "man n binary")
proc ::util::bin_to_uint32 {binary_value} {
    binary scan $binary_value I* val
    set val [expr {$val & 0xFFFFFFFF}]
    return $val
}



namespace eval ::xo::geoip {;}

# read geoip_blocks.cbt_db database into a critbit tree
proc ::xo::geoip::init {} {
    if { [::cbt::id "geoip_blocks.cbt_db"] ne {} } return
    set blocks_cbt [::cbt::create $::cbt::UINT64_KEYS "geoip_blocks.cbt_db"]
    set dir [file join [acs_root_dir] lib geoip]
    ::cbt::read_from_file $blocks_cbt [file join $dir data/geoip_blocks.cbt_db]
}

proc ::xo::geoip::ip_locate {query_ip {loVar ""} {hiVar ""}} {

    if { $loVar ne {} } { upvar $loVar lo }
    if { $hiVar ne {} } { upvar $hiVar hi }

    set blocks_cbt [::cbt::id geoip_blocks.cbt_db]
    if { $blocks_cbt eq {} } {
	error "no critbit tree named geoip.blocks -> check ::xo::geoip::init"
    }

    set query_ip_val [::xo::net::ip_to_uint32 $query_ip]
    #set match [::cbt::prefix_match $blocks_cbt [::util::uint32_to_bin $query_ip_val]]
    set match [::cbt::segment_match $blocks_cbt [::util::uint32_to_bin $query_ip_val]]
    set location_id ""
    if { $match ne {} } {
	lassign $match lo_bin hi_bin location_id
	#puts match=$match
	#return
	set lo [::util::bin_to_uint32 $lo_bin]
	set hi [::util::bin_to_uint32 $hi_bin]
	#puts "[::xo::net::uint32_to_ip $lo]-[::xo::net::uint32_to_ip $hi] location_id=$location_id"
	#return

	#ns_log notice "lo=$lo [::xo::net::uint32_to_ip $lo]-[::xo::net::uint32_to_ip $hi]"
        if { $lo <= $query_ip_val && $query_ip_val <= $hi } {
	    # prefix match found and valid
            return $location_id
        } else {
	    ## HERE - TODO (see segment_match in critbit.c):
	    ns_log notice "segment found but ip out of range: ip=$query_ip segment=[::xo::net::uint32_to_ip $lo]-[::xo::net::uint32_to_ip $hi] location_id=$location_id"
	    # prefix match found but query_ip out of range
            return
        }
    }
    # no prefix match found
    return
}
   


if {0} {
    unsigned long
    _GeoIP_addr_to_num(const char *addr)
    {
        unsigned int    c, octet, t;
        unsigned long   ipnum;
        int             i = 3;

        octet = ipnum = 0;
        while ((c = *addr++)) {
	    if (c == '.') {
		if (octet > 255)
		return 0;
		ipnum <<= 8;
		ipnum += octet;
		i--;
		octet = 0;
	    } else {
		t = octet;
		octet <<= 3;
		octet += t;
		octet += t;
		c -= '0';
		if (c > 9)
		return 0;
		octet += c;
	    }
        }
        if ((octet > 255) || (i != 0))
	return 0;
        ipnum <<= 8;
        return ipnum + octet;
    }
}