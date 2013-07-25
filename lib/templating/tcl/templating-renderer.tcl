namespace eval ::templating::renderer {;}


proc ::templating::renderer::format_date {value configDict {adp ""}} {
    #set format_string [$node @format "%a %b %d %H:%M:%S %z %Y"]

    if { [dict exists $configDict format] } {
	set format_string [dict get $configDict format]
    } else {
	set format_string "%a, %d %b %Y"
    }
    return [clock format [::xo::dt::scan $value] -format $format_string]
}

proc ::templating::renderer::bold_italic {value configDict {adp ""}} {
    return "<b><i>${value}</b></i>"
}

proc ::templating::renderer::text {value configDict {adp ""}} {
    return $value
}

proc ::templating::renderer::adp {o configDict adp} {
    return [ns_adp_parse $adp $o]
}

proc ::templating::renderer::old_adp {o node} {

    set adp [$node @template ""]
    if { $adp eq {} } {
	set adp [$node text]
    }

    set html [ns_adp_parse -string $adp $o]
    return $html
}

