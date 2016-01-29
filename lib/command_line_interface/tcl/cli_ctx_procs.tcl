namespace eval ::cli::kit {
    namespace export \
		add_param \
        getparam \
		init_context \
        is_registered_p \
        require_registration \
        require_secure_conn \
        is_secure_conn \
        debug_mode_p \
        performance_mode_p \
        production_mode_p
}

proc ::cli::kit::is_registered_p {} {
    return [::util::boolean [ad_conn user_id]]
}

proc ::cli::kit::require_registration {} {
    if { ![::cli::kit::is_registered_p] } {
	ad_redirect_for_registration
	return false
    }
    return true
}

proc ::cli::kit::queryget {key {default_value ""} {vlist ""}} {
    set value [::RP getRequestParam ${key} ${default_value}]
    foreach vcheck $vlist {
	if { ![::cli::kit::vcheck=${vcheck} ${value}] } {
	    error "invalid query/form value for param: $param"
	}
    }
    return $value
}

proc ::cli::kit::value_if {param vlist} {
    set value [::cli::kit::queryget $param]
    foreach vcheck $vlist {
        if { ![::cli::kit::vcheck=${vcheck} ${value}] } {
            error "invalid query/form value for param: $param"
        }
    }
    return $value
}

proc ::cli::kit::vcheck {param vlist {valueVar ""}} {
    if { $valueVar ne {} } {
        upvar $valueVar value
    }
    set value [::cli::kit::queryget $param]
    foreach vcheck $vlist {
        if { ![::cli::kit::vcheck=${vcheck} ${value}] } {
            return 0
        }
    }
    return 1
}

proc ::cli::kit::add_param {
	longname shortname varlist 
	strict_p optional_p default_values 
	vchecklists
} {
	global __data__

    if { $varlist eq {} } {
        set varlist "__arg_$longname $longname"
    }

    if { $default_values ne {} } {
        assert { [llength $varlist] - 1 == [llength $default_values] }
        assert { [llength $varlist] - 1 == [llength $vchecklists] }
    }

	lappend __data__(optdata) \
		[list $longname $shortname $varlist]

	lappend __data__(optdata,config) \
		[list $strict_p $optional_p $default_values $vchecklists]

	# log add_param,longname=$longname
}

proc ::cli::kit::init_context {{complaintsVar ""}} {

    if { $complaintsVar ne {} } {
        upvar $complaintsVar complaints
    }

	global __data__

	# extract param values from ::argv
	if { [catch {
		getopt::init $__data__(optdata)
		getopt::getopt [lrange $::argv 1 end] __data__ 
	} errmsg] } {
		log "errmsg=$errmsg"
		return 0
	}

	# sets default values and checks validation
    set complaints {}
	foreach item $__data__(optdata) itemconf $__data__(optdata,config) {
		lassign $item longname shortname varlist
		lassign $itemconf strict_p optional_p default_values vchecklists

        if { $default_values ne {} } {

            # set __data__(__arg_longname) {}
            set __data__([lindex $varlist 0]) {}

            foreach varname [lrange ${varlist} 1 end] default_value $default_values {
                set_if __data__(${varname}) $default_value
            }

        }

		# checks validation
        foreach varname [lrange ${varlist} 1 end] vchecklist $vchecklists {
            if { [info exists __data__(${varname})] } {
                set matchall_p [pattern matchall ${vchecklist} __data__(${varname})]
                if { !${matchall_p} } {
                    lappend complaints \
                        "param (=$longname) var (=$varname) failed validation check: $vchecklist"
                    continue
                }
            } elseif { !$optional_p } {
                return 0
            }
        }
	}

    if { $complaints ne {} } {
        log "\n\t[join $complaints \n\t]"
        return 0
    }
	return 1
}


# returns true when param exists and sets valueVar, 
# to the corresponding value, otherwise returns false
proc ::cli::kit::getparam {param_name valueVar} {
    upvar $valueVar value
    global __data__

    if { [info exists __data__(${param_name})] } {
        set value $__data__(${param_name})
        return 1
    }
    return 0
}




proc ::cli::kit::vcheck=integer {value} {
    return [string is integer -strict ${value}]
}

proc ::cli::kit::vcheck=naturalnum {value} {
    if { [string is integer -strict ${value}] && ${value} > 0 } {
	return 1
    }
    return 0
}

proc ::cli::kit::vcheck=boolean {value} {
    return [string is boolean -strict ${value}]
}

proc ::cli::kit::vcheck=notnull {value} {
    if { $value ne {} } {
	return 1
    }
    return 0
}


proc ::cli::kit::headerget {args} {
    # TODO: from environment variables
    # ::RP getRequestHeader {*}${args} 
}

proc ::cli::kit::get_user {user_id} {
    return [::cli::db::get_cell "" CC_Users!$user_id "user_id"]
}

proc ::cli::kit::extra_url {{stub_url ""}} {
    set index [string length ${stub_url}]
    return [string range [ad_conn extra_url] $index end]
}

proc ::cli::kit::admin_p {{user_id ""} {object_id ""}} {

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


# if { [ns_config ns/server/[ns_info server] production_mode_p 1] } 
if { 0 } {

    proc ::cli::kit::production_mode_p {} {
        return 1
    }

} else {

    proc ::cli::kit::production_mode_p {} {
        return 0
    }

}

# if { [ns_config ns/server/[ns_info server] performance_mode_p 1] }
if { 0 } {
    proc ::cli::kit::performance_mode_p {} {
	return 1
    }
} else {
    proc ::cli::kit::performance_mode_p {} {
	return 0
    }
}

proc ::cli::kit::debug_mode_p {} {
    return [expr { ![::cli::kit::performance_mode_p] }]
}

proc ::cli::kit::is_secure_conn {} {
    set proto [ad_conn protocol]
    if { ${proto} eq {https} } {
        return 1
    }
    return 0
}


namespace eval ::cli::kit {

    if { 0 } {
        array set listening_to_host [list]
        foreach host [ns_config ns/server/[ns_info server] listening_to_host ""] {
            set listening_to_host(${host}) 1
        }
    }

}


if { [::cli::kit::production_mode_p] } {

    proc ::cli::kit::listening_to_host {host} {
        variable listening_to_host
        if { ![info exists listening_to_host(${host})] } {
            return 0
        }
        return 1
    }

    proc ::cli::kit::pvt_home_url {} {
        return "http://my.phigita.net"
    }
    proc ::cli::kit::reload {filename} {
        ns_log notice "::cli::kit::reload filename=$filename is only for debug purposes, i.e. does not work in performance mode"
    }
    proc ::cli::kit::pretend_user {user_id} {
        ns_log notice "::cli::kit::pretend_user $user_id is only for debug purposes, i.e. does not work in performance mode"
    }
    proc ::cli::kit::get_accounts_url {url_args} {
    # ad_conn protocol
        return "https://www.phigita.net/accounts/?return_url=[ns_urlencode [ad_conn protocol]://[ad_host][ns_conn url]$url_args]"
    }
    proc ::cli::kit::get_api_url {} {
        return "https://api.phigita.net/"
    }
    proc ::cli::kit::get_cookie_domain {} {
        return ".phigita.net"
    }

    proc ::cli::kit::require_secure_conn {} {
        if { ![::cli::kit::is_secure_conn] } {
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


} else {

    proc ::cli::kit::listening_to_host {host} {
        return 1
    }

    proc ::cli::kit::pvt_home_url {} {
        return "http://localhost:8090/my"
    }
    proc ::cli::kit::reload {filename} {
        if { [file pathtype $filename] eq {relative} } {
            set filename [acs_root_dir]/${filename}
        }
        namespace eval :: "source $filename"
    }
    proc ::cli::kit::pretend_user {user_id} {
        ad_conn_set user_id $user_id
        ns_log notice "::cli::kit::pretend_user [ad_conn user_id]"
    }
    proc ::cli::kit::get_accounts_url {url_args} {
        return "[ad_conn protocol]://[ad_host][ad_port]/accounts/?return_url=[ns_urlencode [ad_conn protocol]://[ad_host][ad_port][ns_conn url]$url_args]"
    }
    proc ::cli::kit::get_api_url {} {
        return "http://localhost:8090/api/"
    }
    proc ::cli::kit::get_cookie_domain {} {
        return ""
    }
    proc ::cli::kit::require_secure_conn {} {
        return 1
    }

}



proc ::cli::kit::get_screen_name {user_id} {
    if { ${user_id} } {
        return [::cli::db::value -cache "screen_name:${user_id}" -default "" "select screen_name from users where user_id = [ns_dbquotevalue ${user_id}]"]
    }
    return 0
}



# Return a page complaining about the user's input (as opposed to an error in our software, for which ad_return_error is more appropriate)
# TODO: proc ::cli::kit::return_complaint
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

    ::cli::kit::log [::cli::ns::printset [::cli::ns::getform]]
}


proc ::cli::kit::context_bar { args } {

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
	    set name [::cli::db::value -cache "user_full_name:${ctx_uid}" -statement_name get_user_full_name "select first_names || ' ' || last_name from persons where person_id=[ns_dbquotevalue ${ctx_uid}]"]
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
