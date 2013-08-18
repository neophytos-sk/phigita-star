namespace eval ::xo {;}

Object create ::xo::defaultRequestFilter

::xo::defaultRequestFilter proc preauth {args} {

    #####
    #
    # Initialize the environment: reset ad_conn, and populate it with
    # a few things.
    #
    #####
    ad_conn_reset
    ad_conn_set request [nsv_incr rp_properties request_count]
    ad_conn_set user_id 0
    ad_conn_set start_clicks [clock clicks -milliseconds]

    ad_conn_set protocol [::xo::ns::conn::protocol]
    ad_conn_set issecure [::xo::kit::is_secure_conn]



    # This is a hack to turn off perm checking --jcd
    #   Has to match corresponding hack at rp_handler...
    set url [ns_conn url]

    #if {[regexp {^/(graphics|global|stylesheets)/} $url]} {
    #    return "filter_ok"
    #}


    # -------------------------------------------------------------------------
    # Start of patch "hostname-based subsites"
    # -------------------------------------------------------------------------
    # 1. determine the root of the host and the requested URL
    set root [root_of_host [ad_host]]
    set url [ns_conn url]
    # 2. handle special case: if the root is a prefix of the URL, 
    #                         remove this prefix from the URL, and redirect.
    #ns_log notice "request-processor, root=$root"
    if { ${root} ne {} } {
	set len [string length ${root}]
	set url_prefix [string range $url 0 [expr {$len - 1}]]
	if { ${root} eq ${url_prefix} } {
	    set url [string range $url $len end]
	    set query [ns_conn query]
	    if { $query ne {} } {
		append url ?${query}
	    }
	    if {[ad_secure_conn_p]} {
		# it's a secure connection.
		#ad_returnredirect https://[ad_host][ad_port]${url}
		ad_returnredirect https://[ad_host]${url}
		return "filter_return"
	    } else {
		#ad_returnredirect http://[ad_host][ad_port]${url}
		ad_returnredirect http://[ad_host]${url}
		return "filter_return"
	    }
	}
    }
    ad_conn_set root_of_host $root

    # Normal case: Prepend the root to the URL.
    # 3. set the intended URL

    ad_conn_set ctx_uid 0
    if {[string range $url 0 1] eq {/~}} {
	if { [ad_conn urlc]==1 && [string index $url end] ne {/} } {
	    ad_returnredirect ${url}/
	}

        set context_username [string trimleft [lindex [ad_conn urlv] 0] ~]
	set ctx_uid [::xo::db::value -cache "user_id_from_username:${context_username}" -statement_name get_user_id_from_text -default 0 "select user_id from users where screen_name = [ns_dbquotevalue ${context_username}]"]

	if {${ctx_uid} == 0} {
	    preferences::handler
	    ad_conn_set locale [ad_conn LD]
	    ad_conn_set language [lindex [split [ad_conn LD] "_"] 0]
	    rp_returnnotfound
	    return filter_ok
	}

	ad_conn_set context_username ${context_username}
        ad_conn_set ctx_uid ${ctx_uid}
	rp_form_put ctx_uid ${ctx_uid}
        ad_conn_set urlv [concat "user-homepage"  [lrange [ad_conn urlv] 1 end]]
        ad_conn_set url  ${root}/[join [ad_conn urlv] /]
        if { [string index $url end] eq {/} } {
            ad_conn_set url [ad_conn url]/
        }
        set url [ad_conn url]
    } else {
        ad_conn_set url ${root}$url
    }


    # 4. set urlv and urlc for consistency
    set urlv [lrange [split $root /] 1 end]
    ad_conn_set urlc [expr {[ad_conn urlc]+[llength $urlv]}]
    ad_conn_set urlv [concat $urlv [ad_conn urlv]]
    # -------------------------------------------------------------------------
    # End of patch "hostname-based subsites"
    # -------------------------------------------------------------------------

    # Force the URL to look like [ns_conn location], if desired...
    set acs_kernel_id [util_memoize ad_acs_kernel_id]

    set host [::xo::ns::conn::host]
    if { ${host} eq {phigita.net} } {
	set query [ns_getform]
	if { ${query} ne {} } {
	    set url_vars [export_entire_form_as_url_vars]
	    if { ![empty_string_p ${url_vars}] } {
		set query "?${url_vars}"
	    } else {
		set query ""
	    }
	}
	ns_returnmoved "http://www.phigita.net[ns_conn url]$query"
	return filter_return
    } elseif { ![::xo::kit::listening_to_host ${host}] } {
	# only allowed hosts passed this point
	ns_log notice "--->>> not listening to host ${host}"
	return "filter_return"
    }
    ad_conn_set host ${host}


    #rp_debug -ns_log_level debug -debug t "rp_filter: setting up request: [ns_conn method] [ns_conn url] [ad_conn query]"

    if [catch { array set node [site_node__get_from_url [ad_conn url]] } errmsg] {
        # log and do nothing
        #rp_debug -debug t 
	ns_log notice "error within rp_filter [ns_conn method] [ns_conn url] [ad_conn query].  $errmsg"
    } else {


	if { [::xo::kit::production_mode_p] && $node(host) ne {} && $node(host) ne ${host} } {

	    set redirect_url http://$node(host)/[string range [ns_conn url] [string length $node(url)] end]
	    if { [ns_conn query] ne {} } {
		append redirect_url ?[ns_conn query]
	    }

	    ns_log notice "redirect: $redirect_url"
	    #ns_returnredirect $redirect_url

	    #ns_returnmoved $redirect_url
	    ns_returnredirect $redirect_url
	    return "filter_return"
	}
	
	if { $node(url) eq "[ad_conn url]/" } {
	    #ad_returnredirect [ns_conn url]/
	    ns_returnmoved [ns_conn url]/
            #rp_debug "rp_filter: returnredirect node=$node(url) url=[ns_conn url] "
            #rp_debug "rp_filter: return filter_return"
	    return "filter_return"
	}

	ad_conn_set node_id $node(node_id)
	ad_conn_set object_id $node(object_id)
	ad_conn_set object_url $node(url)
	ad_conn_set object_type $node(object_type)
	ad_conn_set package_id $node(object_id)
	ad_conn_set package_type_id $node(package_type_id)
	ad_conn_set package_key $node(package_key)
	ad_conn_set package_url $node(url)
	ad_conn_set instance_name $node(instance_name)
	ad_conn_set extra_url [string range [ad_conn url] [string length $node(url)] end]
	ad_conn_set pageroot $node(pageroot)
	ad_conn_set subsite_id $node(subsite_id)
    }

    #####
    #
    # See if any libraries have changed. This may look expensive, but all it
    # does is check an NSV.
    #
    #####

    if { ![::xo::kit::performance_mode_p] } {
	# We wrap this in a catch, because we don't want an error here to 
	# cause the request to fail.
	if { [catch { apm_load_any_changed_libraries } error] } {
	    global errorInfo
	    ns_log "Error" $errorInfo
	}
    }


    ad_conn_set peeraddr [::xo::ns::conn::peeraddr]

    #####
    #
    # Read in and/or generate security cookies.
    #
    #####

    # sec_handler (defined in security-procs.tcl) sets the ad_conn
    # session-level variables such as user_id, session_id, etc. we can
    # call sec_handler at this point because the previous return
    # statements are all error-throwing cases or redirects.

    sec_handler

    set user_id [ad_conn user_id]
    ad_conn_set screen_name [::xo::kit::get_screen_name $user_id]

    #####
    #
    # Read in and/or generate preference cookies.
    #
    #####
    preferences::handler

    #####
    #
    # Internationalization
    #
    #####

    # Set locale and language of the request. We need ad_conn user_id to be set at this point
    
    ad_conn_set locale [ad_conn LD]
    ad_conn_set language [lindex [split [ad_conn LD] "_"] 0]


    #####
    #
    # Make sure the user is authorized to make this request. 
    #
    #####
    if { [ad_conn object_id] ne {} } {
	if { [catch {
	    if {[string match "admin/*" [ad_conn extra_url]]} {
		#security::require_secure_conn
		permission::require_permission -object_id [ad_conn object_id] -privilege admin
	    } else {
		permission::require_permission -object_id [ad_conn object_id] -privilege read
	    }
	} errmsg] } {
	    rp_finish_serving_page
	    return "filter_return"
	}
    }

    ns_log notice "peeraddr=[ad_conn peeraddr] user_id=[ad_conn user_id] url=[ns_conn url] session_id=[ad_conn session_id] host=[ad_conn host]"


    return "filter_ok"
}


foreach http_method {HEAD GET POST} {
    ns_register_filter preauth $http_method * ::xo::defaultRequestFilter
}
