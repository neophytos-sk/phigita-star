package require ip
package require base64

namespace eval preferences {;}

proc preferences::get_default {name} {
    switch ${name} {
	LD {

	    #  return "en_US" ;# hack for sitewide default, add parameter

	    # Language
	    set accept_language [split [string trim [ns_set iget [ns_conn headers] "Accept-Language"]] ","]
	    if { [string equal ${accept_language} ""] } {
		set accept_language el_GR
	    } else {
		#ns_log notice ${accept_language}
		set accept_language [string map {- _} [lindex ${accept_language} 0]]
	    }
	    if { [string equal ${accept_language} el] } {
		set accept_language el_GR
	    }
	    if { [string equal ${accept_language} en_us] } {
		set accept_language en_US
	    }

	    if {![string equal ${accept_language} en_US] && ![string equal ${accept_language} el_GR]} {
		set accept_language el_GR
	    }

	    return ${accept_language}
	}
	NR {
	    # Number of Results
	    return 10 
	}
	TZ {
	    # Timezone
	    return [ClockMgr getLocalTZ]
	}
    }
}

proc preferences::handler {} {

    ad_conn_set LD ""
    ad_conn_set NR ""
    ad_conn_set TZ ""
    ad_conn_set CC ""
    ad_conn_set UL_CC ""
    ad_conn_set UL_HEX_LOC ""
    #ad_conn_set UL_LOC "" ;# upon request conversion of UL_HEX_LOC, see ad_conn UL_LOC
    #ad_conn_set UL_LAT "" ;# upon request, see ad_conn UL_LAT
    #ad_conn_set UL_LNG "" ;# upon_request, see ad_conn UL_LNG
    ad_conn_set UL_REGION ""


    set preferences [split [ad_get_cookie PREF] ":="]
    foreach {name value} ${preferences} {
	switch ${name} {
	    LD { ad_conn_set LD ${value} }
	    NR { ad_conn_set NR ${value} }
	    TZ { ad_conn_set TZ ${value} }
	    CC { ad_conn_set CC ${value} }
	}
    }



    set country_code ""
    set location_id ""
    set latitude ""
    set longitude ""
    set lo "0"
    set hi "0"
    set tm "0"
    set region ""

    set ul_cookie [ad_get_cookie UL]
    if { $ul_cookie ne {} } {
	#ns_log notice "ul_cookie=$ul_cookie"
	set url_location [split [::base64::decode $ul_cookie] "_"]
	# Version 1: lassign $url_location lo hi country_code location_id latitude longitude tm region_code
	# Version 2:
	lassign $url_location lo hi_diff cc_and_loc region_code cookie_version hex_session_id
	set hi [expr {$lo + $hi_diff}]          ;# (integer representation) hi = low + hi_diff
	set country_code [string range $cc_and_loc 0 1]   ;# 2 bytes for country code
	set hex_location_id [string range $cc_and_loc 2 end]
	# set location_id [::util::hex_to_dec $location_id] ;# upon request, see ad_conn UL_LOC
    }


    set version "v8"
    # Version 1: set pa_num [::xo::ip::toInteger [ad_conn peeraddr]]
    # Version 2:
    set pa_num [::xo::net::ip_to_uint32 [ad_conn peeraddr]]

    # Version 1: if { $pa_num > $hi || $pa_num < $lo || ${seconds}-${tm} > $max_age || ${region} eq {} }
    # Version 2:
    if { $pa_num > $hi || $pa_num < $lo || ${version} ne ${cookie_version} } {
        set mydict [::xo::geoip::ip_locate_details [ad_conn peeraddr]]
        set lo [dict get $mydict lo]
        set hi [dict get $mydict hi]
        set country_code [dict get $mydict country_code]
        set city_name [dict get $mydict city_name]
        set region_code [dict get $mydict region_code]
        set location_id [dict get $mydict location_id]
        set hex_location_id 0                        ;# if location_id is the empty string, e.g. for local ip addresses
        #set latitude [dict get $mydict latitude]    ;# upon request, see ad_conn UL_LAT
        #set longitude [dict get $mydict longitude]  ;# upon request, see ad_conn UL_LNG

        if { $country_code ne {} } {

            set hi_diff [expr { $hi - $lo }]
            set hex_location_id [::util::dec_to_hex [::util::coalesce $location_id "0"]]
            set cc_and_loc ${country_code}${hex_location_id}

            set session_id [ad_conn session_id]
            if { ${session_id} eq {} } {
                error "empty session_id"
            }

            if { [catch { set hex_session_id [::util::dec_to_hex ${session_id}] } errmsg] } {
                ns_log notice "preferences-procs.tcl: peeraddr=[ad_conn peeraddr] issecure=[ad_conn issecure] url=[ns_conn url] host=[ad_conn host]"
                error "error converting session_id=$session_id to hex errmsg=$errmsg"
            }


            # Version 1: set ul_cookie_value "${lo}_${hi}_${country_code}${hex_location_id}_${latitude}_${longitude}_${seconds}_${region_code}"
            # Version 2: set ul_cookie_value "${lo}_${hi_diff}_${cc_and_loc}_${region_code}_${version}"
            # Version 3:
            set ul_cookie_value "${lo}_${hi_diff}_${cc_and_loc}_${region_code}_${version}_${hex_session_id}"

            # Version 1: ad_set_cookie -replace t -max_age inf UL [::base64::encode -maxlen 128 -wrapchar "" $ul_cookie_value]
            # Version 2: 
            ad_set_cookie -replace t -max_age inf UL [::base64::encode -maxlen 128 -wrapchar "" $ul_cookie_value]

            # Version 3: 
            # set signed_cookie_value "number_of_ones"
            # ad_set_cookie -replace t -max_age inf UL [::base64::encode -maxlen 128 -wrapchar "" $signed_cookie_value]

            #ns_log notice "peeraddr=[ad_conn peeraddr] UL=$ul_cookie_value"

        }

    }

    #set region [join "${country_code} ${region_code}" {/}]
    ad_conn_set UL_CC $country_code
    ad_conn_set UL_REGION "${country_code}/${region_code}"
    ad_conn_set UL_HEX_LOC $hex_location_id
    #ad_conn_set UL_LAT $latitude
    #ad_conn_set UL_LNG $longitude

    
    if { [ad_conn LD] eq {} } { ad_conn_set LD [preferences::get_default LD] }
    if { [ad_conn NR] eq {} } { ad_conn_set NR [preferences::get_default NR] }
    if { [ad_conn TZ] eq {} } { ad_conn_set TZ [preferences::get_default TZ] }
    if { [ad_conn CC] eq {} && $country_code ne {} } { 
	ad_conn_set CC $country_code
    }

    return filter_ok
}
