
Class ::xo::RequestHandler

::xo::RequestHandler instproc init_form {{charset ""}} {

    my instvar __ns_form __ns_formfiles

    if {![ns_conn isconnected]} {
	return
    }

    if {$charset ne {}} {
        ns_urlcharset $charset
    }

    if {![info exists __ns_form]} {
	set setId [ns_conn form]
	if { $setId ne {} } {
	    array set __ns_form [ns_set array $setId]
	} else {
	    array set __ns_form [list]
	}
    }

}

::xo::RequestHandler instproc init_headers {} {

    my instvar __ns_headers

    if {![ns_conn isconnected]} {
	return
    }

    if {![info exists __headers]} {
	array set __ns_headers [ns_set array [ns_conn headers]]
    } else {
	array set __ns_headers [list]
    }

}

::xo::RequestHandler instproc getparam {key valueVar} {
    upvar $valueVar value

    my init_form
    my instvar __ns_form
    set exists_p [info exists __ns_form(${key})]
    if { ${exists_p} } {
	set value $__ns_form(${key})
    }
    return ${exists_p}
}

::xo::RequestHandler instproc getRequestParam {key {value ""}} {
    my init_form
    my instvar __ns_form
    if {[info exists __ns_form(${key})]} {
	return $__ns_form(${key})
    }
    return $value
}
::xo::RequestHandler instproc getRequestHeader {key {value ""}} {
    my init_headers
    my instvar __ns_headers
    if {[info exists __ns_headers(${key})]} {
	return $__ns_headers(${key})
    }
    return $value
}

::xo::RequestHandler instproc respond {} {
    global __http_code
    if { [info exists __http_code] } { 
	unset __http_code
    }

    # static files
    if { [::xo::kit::performance_mode_p] } {
	global tcl_url2file tcl_url2path_info
	set url [ad_conn url]
	if { [info exists tcl_url2file(${url})] } {

	    set file $tcl_url2file(${url})
	    set path_info $tcl_url2path_info(${url})
	    ad_conn_set file $file
	    ad_conn_set path_info $path_info
	    set extension [string trimleft [file extension $file] {.}]

	    # e.g. books/robots.txt
	    # e.g. graphics/theme/azure/bullet.gif
	    if { [catch {rp_serve_concrete_file $file $extension} errmsg] } {
		global errorCode
		if { $errorCode eq {NONE} } {
		    return
		}
		ns_log error "error in rp_handler: errorCode=$errorCode -->> errmsg=$errmsg <<--"
		error "error in rp_handler caught: errmsg=$errmsg"
	    }
	    return
	}
    }

    ns_log notice "peeraddr=[ad_conn peeraddr] user_id=[ad_conn user_id] url=[ns_conn url] session_id=[ad_conn session_id] host=[ad_conn host]"




    set root [acs_root_dir]
    set package_key [ad_conn package_key]

    set paths [list]
    lappend paths "www[ad_conn url]"    
    if { $package_key ne {} } {
	lappend paths "packages/${package_key}/[ad_conn pageroot]/[ad_conn extra_url]"
    }

    # check cache for vuh
    # the key is composed from all parts except the last element, usually an integer denoting the id of a post,object,etc
    # we still need to address the case where the last element is a script or an input - we do this by checking whether it is an int or not
    set last_element [lindex [ad_conn urlv] end]
    set last_is_int [string is integer -strict $last_element]
    set code "${last_is_int}[expr { [string length $last_element] >= 48 }]"
    set key "${package_key},[lrange [ad_conn urlv] 0 end-1],${code}"
    ## HERE - HERE - FIX
    ## a url like /blog/like-this-thing-here/ causes last_element to be empty
    ## ns_log notice "__rp_vuh($key) last_element=$last_element"
    set found_p [nsv_exists __rp_vuh $key]
    if { $found_p } {
	set candidate [nsv_get __rp_vuh $key]
	lassign $candidate index prefix
	set status ""
	set trymsg ""
	set path [lindex $paths $index]
	#ns_log notice "found __rp_vuh(${key})=${candidate} path=$path"
	ad_conn_set path_info [string range $path [string length $prefix] end]
	lassign [rp_serve_abstract_file $root $prefix "vuh"] status trymsg
	if { ${status} eq {SUCCESS} } {
	    return
	} else {
	    ns_log notice "something wrong with your code"
	}
    }

    # serve dynamic page
    foreach {path} $paths {
	set status ""
	set trymsg ""
	lassign [rp_serve_abstract_file $root $path] status trymsg

	if { ${status} eq {SUCCESS} } {
	    #set tcl_url2file([ad_conn url]) [ad_conn file]
	    #set tcl_url2path_info([ad_conn url]) [ad_conn path_info]
	    return
	} elseif { ${status} eq {NOTFOUND} } {
	    continue
	} elseif { ${status} eq {REDIRECT} } {
	    set url $trymsg
	    ad_returnredirect $url
	    return
	} elseif { ${status} eq {ABORT} } {
	    return
	}
	
    }


    # serve vuh page
    set count 0
    foreach path $paths {
	foreach prefix [rp_path_prefixes $path] {
	    #ns_log notice "prefix=$prefix"

	    ad_conn_set path_info [string range $path [string length $prefix] end]
	    set status ""
	    set trymsg ""
	    lassign [rp_serve_abstract_file $root $prefix "vuh" "1"] status trymsg

	    if { ${status} eq {SUCCESS} } {

		global __http_code
		if { [info exists __http_code] } {
		    if { $__http_code eq {404} }  {
			# do not cache if not found
			return
		    }
		}

		#global __no_cache
		#if { [info exists __no_cache] } {
		#    if { $__no_cache eq {1} } {
		#	return 
		#    }
		#}
		if { $prefix ne {packages/account-manager/www/} && $last_is_int } {
		    nsv_set __rp_vuh $key [list $count $prefix]
		}

		return

	    } elseif { ${status} eq {NOTFOUND} } {
		# do nothing - skip to next path
	    } elseif { ${status} eq {REDIRECT} } {
		set url $trymsg
		ad_returnredirect $url
		return
	    } elseif { ${status} eq {ABORT} } {
		# do nothing
		return
	    }
	}
	incr count
    }
    
    rp_returnnotfound

}

proc ::defaultRequestHandler {args} {
    ::xo::RequestHandler ::RP
    if { [catch {::RP respond} errmsg] } {
	ns_log notice "error in rp-handler, errmsg=$errmsg"
	rp_returnerror
    }

    #::RP destroy
    #ns_set cleanup
    return
}


::xo::RequestHandler ::RP

foreach method {GET HEAD POST} {
    ns_register_proc $method / ::defaultRequestHandler
}
