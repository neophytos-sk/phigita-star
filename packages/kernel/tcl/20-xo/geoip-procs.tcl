
namespace eval ::xo {;}
namespace eval ::xo::geoip {;}

proc ::xo::geoip::is_private_p {ip} {
    lassign [split $ip .] a b c d
    if { $a eq {} || $b eq {} || $c eq {} || $d eq {} || 
	 $a == 10 || 
	 ($a == 172  && $b >= 16 && $b <= 31) ||
	 ($a == 192  && $b == 168) ||
	 $a == 239  ||
	 $a == 0    ||
	 $a == 127
     } {
	return true
    }
    return false

}

proc ::xo::geoip::ip_locate_details { _ip } {
    set ip [string trim $_ip]

    # Get the country and city (if available) for this /24
    lassign [split $ip .] a b c d

    # First check for illegal values

    if { [::xo::geoip::is_private_p $ip] } {
	return [dict create ip $ip lo "" hi "" location_id "" city_name "" country_code "" latitude "" longitude "" region_code "" area_code "" postal_code "" metro_code ""]
    }


    set location_id [::xo::geoip::ip_locate $ip start_ip_num end_ip_num]
    if { $location_id eq {} } {

	# Return with an 'unknown' if we can't find the a,b,c records
	return [dict create ip $ip lo "" hi "" location_id "" city_name "" country_code "" latitude "" longitude "" region_code "" area_code "" postal_code "" metro_code ""]

    } else {

	# Get the country and city from the DB as well. Not done using a
	# LEFT JOIN since it seems to take longer(!) than doing the two
	# SELECT's

	#set o [$data head]
	#$o set a $a
	#set location_id [$o set location_id]

	# -pool geoipdb
	set loc_data [::db::Set new -from locations -where [list "id=$location_id"] -limit 1]
	$loc_data load


	if { [$loc_data emptyset_p] } {
	    return [dict create ip $ip lo "" hi "" location_id "" city_name "" country_code "" latitude "" longitude "" region_code "" area_code "" postal_code "" metro_code ""]
	} else {

	    set loc_head [$loc_data head]
	    $loc_head instvar city country latitude longitude area_code postal_code metro_code region
	    return [dict create ip $ip lo $start_ip_num hi $end_ip_num location_id $location_id city_name $city country_code $country latitude $latitude longitude $longitude region_code $region area_code $area_code postal_code $postal_code metro_code $metro_code]

	    #####
	    if {0} {
		$o set city_name [ns_urldecode [$loc_head set city]]
		$o set country_code [$loc_head set country]
		$o set latitude [$loc_head set latitude]
		$o set longitude [$loc_head set longitude]
		$o set lo [$o set start_ip_num]
		$o set hi [$o set end_ip_num]
		$o set area_code [$loc_head set area_code]
		$o set postal_code [$loc_head set postal_code]
		$o set metro_code [$loc_head set metro_code]
		$o set region_code [$loc_head set region]


		set tmplist ""
		foreach varname [$o info vars] {
		    lappend tmplist [list $varname [$o set $varname]]
		}
		set values [join $tmplist]
		return [dict create {*}${values}]
	    }
	    #####

	}
    }

}

