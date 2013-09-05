namespace eval ::templating::config {

    # data_object_type := NSF | DICT
    array set options [list \
			   data_object_type "DICT" \
			   default_cdn_host "static.phigita.net"]

}

proc ::templating::config::get_option {name} {
    variable options
    return $options(${name})
}

proc ::templating::config::set_option {name value} {
    variable options
    set options(${name}) ${value}
}


proc ::templating::config::dict_get_cmd {} {
    set data_object_type [get_option data_object_type]
    if { ${data_object_type} eq "DICT" } {
	return "dict get"
    } elseif { ${data_object_type} eq "NSF" } {
	return "::nsf::var::set"
    } else {
	error "unknown data_object_type in templating config (must be NSF or DICT)"
    }
}
