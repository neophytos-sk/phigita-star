namespace eval ::templating::config {

    # data_object_type := NSF | DICT
    array set options [list \
			   data_object_type "NSF" \
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
