namespace eval ::xo {;}
namespace eval ::xo::hostip {;}

proc ::xo::hostip::is_private_p {ip} {
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

proc ::xo::hostip::ip_locate { _ip } {
    set ip [string trim $_ip]

    # Get the country and city (if available) for this /24
    lassign [split $ip .] a b c d

    # First check for illegal values

    if { [::xo::hostip::is_private_p $ip] } {
	return [dict create ip $ip a $a b $b c $c country 0 city 0 countryName "(Private Address)" cityName "(Private Address)" countryCode "" lat "" lng ""]
    }

    # Check it against the database for countries
    # set sql "SELECT * FROM ip4_$a WHERE b=$b AND c=$c LIMIT 1"

    set data [::db::Set new -pool hipdb -from ip4_$a -where [list "b=[ns_dbquotevalue $b]" "c=[ns_dbquotevalue $c]"] -limit 1]
    $data load

    if { [$data emptyset_p] } {

	# Return with an 'unknown' if we can't find the a,b,c records
	return [dict create ip $ip a $a b $b c $c country "" city "" countryName "(Unknown Country?)" cityName "(Unknown City?)" countryCode XX lat "" lng ""]

    } else {

	# Get the country and city from the DB as well. Not done using a
	# LEFT JOIN since it seems to take longer(!) than doing the two
	# SELECT's

	set o [$data head]
	$o set a $a
	set city_data [::db::Set new -pool hipdb -select "name,lat,lng" -from citybycountry -where [list "city=[$o set city]"] -limit 1]
	$city_data load


	if { [$city_data emptyset_p] } {
	    $o set cityName "(Unknown city)"
	    $o set lat ""
	    $o set lng ""
	    $o set b ""
	    $o set c ""
	} else {
	    set city_head [$city_data head]
	    $o set cityName [ns_urldecode [$city_head set name]]
	    $o set lat [$city_head set lat]
	    $o set lng [$city_head set lng]
	}

	set country_data [::db::Set new -pool hipdb -select "name,code" -from countries -where [list "id=[$o set country]"]]
	$country_data load

	if { [$country_data emptyset_p] } {
	    $o set countryName "(Unknown country)"
	    $o set countryCode QQ
	} else {
	    set country_head [$country_data head]
	    $o set countryName [$country_head set name]
	    $o set countryCode [$country_head set code]
	}

	set tmplist ""
	foreach varname [$o info vars] {
	    lappend tmplist [list $varname [$o set $varname]]
	}
	set values [join $tmplist]
	return [dict create {*}${values}]
    }

}
