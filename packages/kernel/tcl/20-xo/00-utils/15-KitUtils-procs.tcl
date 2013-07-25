namespace eval ::xo::kit {;}

proc ::xo::kit::is_registered_p {} {
    return [::util::boolean [ad_conn user_id]]
}

proc ::xo::kit::require_registration {} {
    if { ![::xo::kit::is_registered_p] } {
	ad_redirect_for_registration
	return false
    }
    return true
}

proc ::xo::kit::queryget {key {default_value ""} {vlist ""}} {
    set value [::RP getRequestParam ${key} ${default_value}]
    foreach vcheck $vlist {
	if { ![::xo::kit::vcheck=${vcheck} ${value}] } {
	    error "invalid query/form value for param: $param"
	}
    }
    return $value
}

proc ::xo::kit::value_if {param vlist} {
    set value [::xo::kit::queryget $param]
    foreach vcheck $vlist {
	if { ![::xo::kit::vcheck=${vcheck} ${value}] } {
	    error "invalid query/form value for param: $param"
	}
    }
    return $value
}

proc ::xo::kit::vcheck {param vlist {valueVar ""}} {
    if { $valueVar ne {} } {
	upvar $valueVar value
    }
    set value [::xo::kit::queryget $param]
    foreach vcheck $vlist {
	if { ![::xo::kit::vcheck=${vcheck} ${value}] } {
	    return 0
	}
    }
    return 1
}

proc ::xo::kit::getparam {param valueVar} {
    upvar $valueVar value
    return [::RP getparam $param value]
}




proc ::xo::kit::vcheck=integer {value} {
    return [string is integer -strict ${value}]
}

proc ::xo::kit::vcheck=naturalnum {value} {
    if { [string is integer -strict ${value}] && ${value} > 0 } {
	return 1
    }
    return 0
}

proc ::xo::kit::vcheck=boolean {value} {
    return [string is boolean -strict ${value}]
}

proc ::xo::kit::vcheck=notnull {value} {
    if { $value ne {} } {
	return 1
    }
    return 0
}


proc ::xo::kit::headerget {args} {
    ::RP getRequestHeader {*}${args}
}

proc ::xo::kit::get_user {user_id} {
    return [::xo::db::get_cell "" CC_Users!$user_id "user_id"]
}

proc ::xo::kit::extra_url {{stub_url ""}} {
    set index [string length ${stub_url}]
    return [string range [ad_conn extra_url] $index end]
}

proc ::xo::kit::admin_p {{user_id ""} {object_id ""}} {

    if { $user_id eq {} } {
	set user_id [ad_conn user_id]
    }
    if { $object_id eq {} } {
	set object_id [ad_conn package_id]
    }

    set admin_p 0
    if { 0 != ${user_id} } {
	set privilege admin
	set admin_p [permission::permission_p -party_id $user_id -object_id $object_id -privilege $privilege]
    }
    return ${admin_p}
}


proc ::xo::kit::reverse_proxy_mode_p {} "return [ns_config -bool ns/parameters ReverseProxyMode 1]"

if { [ns_config ns/server/[ns_info server] production_mode_p 1] } {
    proc ::xo::kit::production_mode_p {} {
	return 1
    }
} else {
    proc ::xo::kit::production_mode_p {} {
	return 0
    }
}

if { [ns_config ns/server/[ns_info server] performance_mode_p 1] } {
    proc ::xo::kit::performance_mode_p {} {
	return 1
    }
} else {
    proc ::xo::kit::performance_mode_p {} {
	return 0
    }
}

proc ::xo::kit::debug_mode_p {} {
    return [expr { ![::xo::kit::performance_mode_p] }]
}

proc ::xo::kit::is_secure_conn {} {
    set proto [ad_conn protocol]
    if { ${proto} eq {https} } {
	return 1
    }
    return 0
}

if { [::xo::kit::production_mode_p] } {
    proc ::xo::kit::pvt_home_url {} {
	return "http://my.phigita.net"
    }
    proc ::xo::kit::reload {filename} {
	ns_log notice "::xo::kit::reload filename=$filename is only for debug purposes, i.e. does not work in performance mode"
    }
    proc ::xo::kit::pretend_user {user_id} {
	ns_log notice "::xo::kit::pretend_user $user_id is only for debug purposes, i.e. does not work in performance mode"
    }
    proc ::xo::kit::get_accounts_url {url_args} {
	# ad_conn protocol
	return "https://www.phigita.net/accounts/?return_url=[ns_urlencode [ad_conn protocol]://[ad_host][ns_conn url]$url_args]"
    }
    proc ::xo::kit::get_api_url {} {
	return "https://api.phigita.net/"
    }
    proc ::xo::kit::get_cookie_domain {} {
	return ".phigita.net"
    }

    proc ::xo::kit::require_secure_conn {} {
	if { ![::xo::kit::is_secure_conn] } {
	    set secure_url "https://"

	    set host [ns_set iget [ns_conn headers] Host]
	    append secure_url $host

	    set url [ns_conn url]
	    if { $url ne {} } {
		append secure_url ${url}
	    }

	    set query [ns_conn query]
	    if { $query ne {} } {
		append secure_url "?${query}"
	    }

	    # return false triggers an abort in guard tags of the new templating system
	    uplevel "ns_returnredirect ${secure_url}; return false"

	    return false
	}
	return true
    }

    proc ::xo::kit::log {args} {}

} else {
    proc ::xo::kit::pvt_home_url {} {
	return "http://localhost:8090/my"
    }
    proc ::xo::kit::reload {filename} {
	if { [file pathtype $filename] eq {relative} } {
	    set filename [acs_root_dir]/${filename}
	}
	namespace eval :: "source $filename"
    }
    proc ::xo::kit::pretend_user {user_id} {
	ad_conn_set user_id $user_id
	ns_log notice "::xo::kit::pretend_user [ad_conn user_id]"
    }
    proc ::xo::kit::get_accounts_url {url_args} {
	return "[ad_conn protocol]://[ad_host][ad_port]/accounts/?return_url=[ns_urlencode [ad_conn protocol]://[ad_host][ad_port][ns_conn url]$url_args]"
    }
    proc ::xo::kit::get_api_url {} {
	return "http://localhost:8090/api/"
    }
    proc ::xo::kit::get_cookie_domain {} {
	return ""
    }
    proc ::xo::kit::require_secure_conn {} {
	return 1
    }

    proc ::xo::kit::log {args} {

	set level [info level]
	lassign [info level [expr { $level - 1 }]] proc_name 
	ns_log notice "(${proc_name})" {*}${args}
	
    }

}



proc ::xo::kit::get_screen_name {user_id} {
    if { ${user_id} } {
	return [::xo::db::value -cache "screen_name:${user_id}" -default "" "select screen_name from users where user_id = [ns_dbquotevalue ${user_id}]"]
    }
    return 0
}



# Return a page complaining about the user's input (as opposed to an error in our software, for which ad_return_error is more appropriate)
# TODO: proc ::xo::kit::return_complaint
proc ad_return_complaint {exception_count exception_text} {
    # there was an error in the user input 
    if { $exception_count == 1 } {
	set problem_string "a problem"
	set please_correct "it"
    } else {
	set problem_string "some problems"
	set please_correct "them"
    }
	    
    doc_return 200 text/html "[ad_header_with_extra_stuff "Problem with Your Input" "" ""]
    
<h2>Problem with Your Input</h2>

to <a href=/>[ad_system_name]</a>

<hr>

We had $problem_string processing your entry:
	
<ul> 
	
$exception_text
	
</ul>
	
Please back up using your browser, correct $please_correct, and
resubmit your entry.
	
<p>
	
Thank you.
	
[ad_footer]
";					#"emacs
    # raise abortion flag, e.g., for templating
    global request_aborted
    set request_aborted [list 200 "Problem with Your Input"]

    ::xo::kit::log [::xo::ns::printset [::xo::ns::getform]]
}


proc ::xo::kit::context_bar { args } {

    set context [list]

    set url "/"
    set href "/"

    array set node [nsv_get site_nodes ${url}]
    lappend context [list http://www.phigita.net${url} $node(instance_name)]

    set package_url [ad_conn package_url]
    set root_of_host [ad_conn root_of_host]
    if { $root_of_host ne {} } {
	set package_url [regsub -- "^$root_of_host" $package_url {}]
        array set node [nsv_get site_nodes ${root_of_host}/]
	lappend context [list http://[ad_host] $node(instance_name)]
    }

    set package_url_parts [split [string trim ${package_url} {/}] {/}]
    foreach label ${package_url_parts} {
	append url ${label}/
	array set node [nsv_get site_nodes ${root_of_host}${url}]
	if { ${label} eq {user-homepage} } {
	    append href [lindex [ns_conn urlv] 0]/
	    set ctx_uid [ad_conn ctx_uid]
	    set name [::xo::db::value -cache "user_full_name:${ctx_uid}" -statement_name get_user_full_name "select first_names || ' ' || last_name from persons where person_id=[ns_dbquotevalue ${ctx_uid}]"]
	} else {
	    append href ${label}/
	    set name $node(instance_name)
	}
	lappend context [list ${href} ${name}]
    }

    set context [concat ${context} ${args}]


    set out [list]

    set llength_args [llength ${args}]
    set llength_context [llength ${context}]
    set llength_context_minus_one [expr { ${llength_context} - 1 }]

    for { set i 0 } { $i < ${llength_context} } { incr i } {

	set element [lindex ${context} $i]

	if { $i == ${llength_context_minus_one} } {

	    if { ${llength_args} == 0} {
		lappend out "<li class=\"active\">[lindex $element 1]</li>"
	    } else {
		lappend out "<li class=\"active\">${element}</li>"
	    }

	} else {

	    lappend out "<li><a href=\"[lindex ${element} 0]\">[lindex ${element} 1]</a><span class=\"divider\">&gt;</span></li>"

	}

    }

    return "<ul class=\"breadcrumb\">[join $out ""]</ul>"

}
