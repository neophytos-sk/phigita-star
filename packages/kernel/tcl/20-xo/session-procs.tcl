namespace eval ::xo::session {;}

proc ::xo::session::is_valid {param_name param_value {age_in_secs "3600"} {valueVar ""}} {

    if { $valueVar ne {} } {
	upvar $valueVar value
    }

    if { $param_value eq {} } {
	return 0
    }

    # one session variable consists of:
    # s_session_id - ad_conn session_id when variable was signed
    # s_secs - timestamp in seconds
    # s_value - the value we want to communicate (e.g. user_id)
    # s_hash - sha1 signature
    set s_session_id ""
    set s_secs ""
    set s_value   ""
    set s_hash   ""
    lassign [split $param_value {-}] s_session_id s_secs s_value s_hash

    # check expiration
    set now [clock seconds]
    if { ${now} - ${s_secs} > $age_in_secs } {
	return 0
    }

    # generate hash
    set peeraddr [ad_conn peeraddr]
    set secret "t0oMaNySeCrEtS-${peeraddr}-${s_session_id}-${param_name}-${s_secs}-${s_value}"
    set hash [ns_sha1 $secret]

    # validate signature
    if { $hash ne $s_hash } {
	return 0
    }

    # ok, it is valid, return true
    set value $s_value
    return 1

}

proc ::xo::session::get {param_name {default_value ""} {age_in_secs "0"}} {

    set param_value [ns_queryget $param_name]
    if { ![::xo::session::is_valid $param_name $param_value $age_in_secs value] } {
	return $default_value
    }
    # signature is good - return value from session state variable
    return $value
}

proc ::xo::session::signed_value {s_param_name s_value} {
    set s_secs [clock seconds]
    set s_session_id [ad_conn session_id]
    set s_peeraddr [ad_conn peeraddr]
    set secret "t0oMaNySeCrEtS-${s_peeraddr}-${s_session_id}-${s_param_name}-${s_secs}-${s_value}"
    set s_hash [ns_sha1 $secret]
    set param_value "${s_session_id}-${s_secs}-${s_value}-${s_hash}"
    return $param_value
}