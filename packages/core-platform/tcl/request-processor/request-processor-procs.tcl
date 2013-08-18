ad_library {

    The Request Processor: the set of routines called upon every
    single HTTP request to an ACS server.

    @author Neophytos Demetriou
}

#######
### TODO: set the correct errno


#####
#
#  PUBLIC API
#
#####

proc rp_returnnotfound { args } {
    global __http_code
    set __http_code 404
    ns_returnnotfound
}

ad_proc rp_returnerror { args } {
    @author Neophytos Demetriou
} {
    ns_returnfile 500 text/html [acs_root_dir]/global/error-pages/error.html
    global errorInfo
    ns_log "Error" $errorInfo
    set setId [::xo::ns::headers]
    ns_log notice "HTTP Headers = [::xo::ns::printset $setId]"
    set formId [::xo::ns::getform]
    ns_log notice "Form Data = [::xo::ns::printset $formId]"
}


ad_proc ad_return { args } {

    Works like the "return" Tcl command, with one difference. Where
    "return" will always return TCL_RETURN, regardless of the -code
    switch this way, by burying it inside a proc, the proc will return
    the code you specify.

    <p>

    Why? Because "return" only sets the "returnCode" attribute of the
    interpreter object, which the function actually interpreting the
    procedure then reads and uses as the return code of the procedure.
    This proc adds just that level of processing to the statement.

    <p>

    When is that useful or necessary? Here:

    <pre>
    set errno [catch {
	return -code error "Boo!"
    } error]
    </pre>

    In this case, <code>errno</code> will always contain 2 (TCL_RETURN).
    If you use ad_return instead, it'll contain what you wanted, namely
    1 (TCL_ERROR).

} {
    eval return $args
}

ad_proc -private rp_registered_proc_info_compare { info1 info2 } {

    A comparison predicate for registered procedures, returning -1, 0,
    or 1 depending the relative sorted order of $info1 and $info2 in the
    procedure list. Items with longer paths come first.

} {
    set info1_path [lindex $info1 1]
    set info2_path [lindex $info2 1]

    set info1_path_length [string length $info1_path]
    set info2_path_length [string length $info2_path]

    if { $info1_path_length < $info2_path_length } {
	return 1
    }
    if { $info1_path_length > $info2_path_length } {
	return -1
    }
    return 0
}

ad_proc -private rp_invoke_filter { conn filter_info why } {

    Invokes the filter described in $argv, writing an error message to
    the browser if it fails (unless <i>kind</i> is <code>trace</code>).

} {
    set startclicks [clock clicks]

    lassign $filter_info filter_index debug_p arg_count proc arg

    #      if { $debug_p } {
    #      ns_log "Notice" "Invoking $why filter $proc"
    #      }
    #rp_debug -debug $debug_p "Invoking $why filter $proc"

    switch $arg_count {
	0 { set errno [catch { set result [$proc] } error] }
	1 { set errno [catch { set result [$proc $why] } error] }
	2 { set errno [catch { set result [$proc $conn $why] } error] }
	default {
	    if { [catch {
		set result [$proc $conn $arg $why]
	    } errmsg] } {
		ns_log error errmsg=$errmsg
		# in case of ABORT: set result "filter_return"
		set errno 1
	    }
	}
    }

    global errorCode
    if { $errno } {
	# Uh-oh - an error occurred.
	global errorInfo

	ns_log error "error in filter $proc for [ns_conn method] [ns_conn url]?[ad_conn query] errno is $errno message is $errorInfo"
	rp_report_error

	set result "filter_return"

    } elseif { [string compare $result "filter_ok"] && [string compare $result "filter_break"] && \
		   [string compare $result "filter_return"] } {
	set error_msg "error in filter $proc for [ns_conn method] [ns_conn url]?[ad_conn query].  Filter returned invalid result \"$result\""

        # report the bad filter_return message
        ns_log error "error $error_msg"
	rp_report_error -message $error_msg
	set result "filter_return"

    } else {

	#ad_call_proc_if_exists ds_add rp [list filter [list $why [ns_conn method] [ns_conn url] $proc $arg] $startclicks [clock clicks] $result]
    }


    if { ${result} eq {filter_return} } {
	rp_finish_serving_page
    }

    return $result
}

ad_proc -private rp_invoke_proc { conn argv } {

    Invokes a registered procedure.

} {
    set startclicks [clock clicks]

    lassign $argv proc_index debug_p arg_count proc arg

    #      if { $debug_p } {
    #      ns_log "Notice" "Invoking registered procedure $proc"
    #      }
    rp_debug -debug $debug_p "Invoking registered procedure $proc"

    switch $arg_count {
	0 { set errno [catch $proc error] }
	1 { set errno [catch "$proc $arg" error] }
	default {
	    if { [catch {
		$proc [list $conn] $arg
	    } errmsg] } {
		ns_log error errmsg=$errmsg
		# on abort do nothing
		set errno 1
	    }
	}
    }

    global errorCode
    if { $errno } {
	# Uh-oh - an error occurred.
	global errorInfo
	ad_call_proc_if_exists ds_add rp [list registered_proc [list $proc $arg] $startclicks [clock clicks] "error" $errorInfo]
	rp_debug -debug t "error in $proc for [ns_conn method] [ns_conn url]?[ad_conn query] errno is $errno message is $errorInfo"
	rp_report_error
    } else {
	ad_call_proc_if_exists ds_add rp [list registered_proc [list $proc $arg] $startclicks [clock clicks]]
    }

    rp_finish_serving_page
}

ad_proc -private rp_finish_serving_page {} {
    global doc_properties
    if { [info exists doc_properties(body)] } {
        set l [string length $doc_properties(body)]
	doc_return 200 text/html $doc_properties(body)
    }
}

ad_proc -public ad_register_filter {
    { -debug f }
    { -priority 10000 }
    { -critical f } 
    { -description "" }
    kind method path proc { arg "" }
} {

    Registers a filter that gets called during page serving. The filter
    should return one of 

    <ul>
    <li><code>filter_ok</code>, meaning the page serving will continue; 

    <li><code>filter_break</code> meaning the rest of the filters of
    this type will not be called;

    <li><code>filter_return</code> meaning the server will close the
    connection and end the request processing.
    </ul>

    @param kind Specify preauth, postauth or trace.

    @param method Use a method of "*" to register GET, POST, and HEAD
    filters.

    @param priority Priority is an integer; lower numbers indicate
    higher priority.

    @param critical If a filter is critical, page viewing will abort if
    a filter fails.

    @param debug If debug is set to "t", all invocations of the filter
    will be ns_logged.

    @param sitewide specifies that the filter should be applied on a
    sitewide (not subsite-by-subsite basis).

} {
    if { [string equal $method "*"] } {
	# Shortcut to allow registering filter for all methods.
	foreach method { GET POST HEAD } {
					  ad_register_filter -debug $debug -priority $priority -critical $critical $kind $method $path $proc $arg
				      }
	return
    }

    if { [lsearch -exact { GET POST HEAD } $method] == -1 } {
	error "Method passed to ad_register_filter must be one of GET, POST, or HEAD"
    }

    # Append the filter to the list.
    nsv_lappend rp_filters . \
	[list $priority $kind $method $path $proc $arg $debug $critical $description [info script]]
}


#####
#
# NSV arrays used by the request processor:
#
#   - rp_filters($method,$kind), where $method in (GET, POST, HEAD)
#       and kind in (preauth, postauth, trace) A list of $kind filters
#       to be considered for HTTP requests with method $method. The
#       value is of the form
#
#             [list $priority $kind $method $path $proc $args $debug \
    #                 $critical $description $script]
#
#   - rp_registered_procs($method), where $method in (GET, POST, HEAD)
#         A list of registered procs to be considered for HTTP requests with
#         method $method. The value is of the form
#
#             [list $method $path $proc $args $debug $noinherit \
    #                   $description $script]
#
#   - rp_system_url_sections($url_section)
#         Indicates that $url_section is a system directory (like
#         SYSTEM) which is exempt from Host header checks and
#         session/security handling.
#
# ad_register_filter and ad_register_procs are used to add elements to
# these NSVs. We use lists rather than arrays for these data
# structures since "array get" and "array set" are rather expensive
# and we want to keep lookups fast.
#
#####

ad_proc -private rp_debug { { -debug t } { -ns_log_level notice } string } {

    Logs a debugging message, including a high-resolution (millisecond)
    timestamp.

} {
    if { [util_memoize {ad_parameter -package_id [ad_acs_kernel_id] DebugP request-processor 0} 60] } {
	global ad_conn
	set clicks [clock clicks]
        ad_call_proc_if_exists ds_add rp [list debug $string $clicks $clicks]
    }
    if {
        [util_memoize {ad_parameter -package_id [ad_acs_kernel_id] LogDebugP request-processor 0} 60] || [string equal $debug t] || [string equal $debug 1]
    } {
	global ad_conn
	if { [info exists ad_conn(start_clicks)] } {
	    set timing " ([expr {([clock clicks -milliseconds] - $ad_conn(start_clicks))/1000.0}] ms)"
	} else {
	    set timing ""
	}
	ns_log $ns_log_level "RP$timing: $string"
    }
}

ad_proc rp_report_error {
    -message
} {

    Writes an error to the connection.

    @param message The message to write (pulled from <code>$errorInfo</code> if none is specified).

} {
    if { ![info exists message] } {
	upvar #0 errorInfo message
    }

    set error_url [ad_conn url]

    if { [llength [info procs ds_collection_enabled_p]] == 1 && [ds_collection_enabled_p] } {
	ds_add conn error $message
    }

    if {![ad_parameter -package_id [ad_acs_kernel_id] "RestrictErrorsToAdminsP" dummy 0] || \
	    [ad_permission_p [ad_conn package_id] admin] } {
	if { [ad_parameter -package_id [ad_acs_kernel_id] "AutomaticErrorReportingP" "rp" 0] } { 
	    set error_info $message
	    set report_url [ad_parameter -package_id [ad_acs_kernel_id] "ErrorReportURL" "rp" ""]
	    if { [empty_string_p $report_url] } {
		ns_log "Automatic Error Reporting Misconfigured.  Please add a field in the acs/rp section of form ErrorReportURL=http://your.errors/here."
	    } else {
		set auto_report 1
		ns_returnerror 200 "</table></table></table></h1></b></i>
               <form method=POST action='$report_url'>
[export_form_vars error_url error_info]
This file has generated an error.  
<input type=submit value='Report this error'>
</form><hr>
<blockquote><pre>[ns_quotehtml $error_info]</pre></blockquote>[ad_footer]"
	    }
	} else {
	    # No automatic report.
	    ns_returnerror 200 "</table></table></table></h1></b></i>
<blockquote><pre>[ns_quotehtml $message]</pre></blockquote>[ad_footer]"
	}
    } else {
	rp_returnerror
    }
    ns_log Error "[ns_conn method] $error_url [ad_conn query] $message"
}


# Returns all the prefixes of a path ordered from most to least specific. "'
proc rp_path_prefixes {path} {
    set path [string trimright $path {/}]
    set parts [lrange [split ${path} "/"] 0 end-1]
    set prefixes [list]
    set prefix ""
    foreach part $parts {
	append prefix "${part}/"
	lappend prefixes ${prefix}
    }
    return [lreverse ${prefixes}]
}

if {0} {
    if { [string index $path 0] ne {/}} {
	set path "/$path"
    }

    for {set i [expr [llength $components] -1]} {$i >= 0} {incr i -1} {
	lappend prefixes "[join [lrange $components 0 $i] "/"]/"
    }
}


# Serves up a file given the abstract path. Raises the following
# exceptions in the obvious cases:

# notfound  (passes back an empty value)
# redirect  (passes back the url to which it wants to redirect)
# directory (passes back the path of the directory)

# -noredirect:boolean
# -nodirectory:boolean
# {-extension_pattern ".*"}

proc rp_serve_abstract_file { root path {precedence ""} {noredirect_p 0}} {
    
    set abs_path "${root}/${path}"

    if { [string index $path end] eq {/} } {
	if { [file isdirectory $abs_path] } {
	    # The path specified was a directory; return its index file.
	    # Directory name with trailing slash. Search for an index.* file.
            set path [file join $path index]
	    set abs_path "${root}/${path}"
	} else {

	    # If there's a trailing slash on the path, the URL must refer to a
	    # directory (which we know doesn't exist, since [file isdirectory $path]
	    # returned 0).
	    # ns_log notice "rp_serve_abstract_file - notfound: $path"
	    return NOTFOUND
	}
    }


    if { [file isfile $abs_path] } {
	set extension [string trimleft [file extension $path] {.}]
	if { -1 == [lsearch {tsp tdp tcl vuh} $extension] } {
	    ad_conn_set file $abs_path
	    rp_serve_concrete_file $abs_path $extension

	    global tcl_url2file tcl_url2path_info
	    set tcl_url2file([ad_conn url]) [ad_conn file]
	    set tcl_url2path_info([ad_conn url]) [ad_conn path_info]
	    return SUCCESS
	}
    }


    # The path provided doesn't correspond directly to a file - we
    # need to glob.   (It could correspond directly to a directory.)

    if { ![file isdirectory [file dirname $abs_path]] } {
	return NOTFOUND
    }

    lassign [rp_concrete_file $root $path $precedence] concrete_file extension

    if { ${concrete_file} eq {} } {
	if { [file isdirectory $abs_path] && !$noredirect_p } {
	    # Directory name with no trailing slash. Redirect to the same
	    # URL but with a trailing slash.
	    
	    set url "[ns_conn url]/"
	    if { [ad_conn query] ne {} } {
		append url "?[ad_conn query]"
	    }
	    
	    return [list REDIRECT $url]
	} else {
	    # Nothing at all found! 404 time.
	    return NOTFOUND
	}
    }

    ad_conn_set file $concrete_file
    rp_serve_concrete_file $concrete_file $extension
    return SUCCESS
}


proc rp_serve_concrete_file {file extension} {
    if { $extension eq {tsp} || ${extension} eq {tdp} || $extension eq {tcl} || $extension eq {vuh} } {

	set handler "rp_handle_${extension}_request"

	if { [catch {
	    ${handler}
	    rp_finish_serving_page
	} errmsg] } { 
	    ns_log notice "handler=$handler"
	    ns_log notice "[info script] rp_serve_concrete_file handler=$handler errmsg=$errmsg"
	    # CAUTION: SERIOUS BUG if uncaught throw reaches this point
	    # FATAL SIGNAL 11 (see handle_tcl_request)
	    set errno 1
	    global errorCode errorInfo
	    return -code $errno -errorcode $errorCode -errorinfo $errorInfo $errmsg
	}
    } else {
	# Some other random kind of file - guess the type and return it.
	ad_returnfile_background 200 [ns_guesstype ${file}] ${file}
    }
}


# Given a path in the filesystem, returns the file that would be
# served, trying all possible extensions. Returns an empty string if
# there's no file "$path.*" in the filesystem (even if the file $path itself does exist).
#    {-extension_pattern ".*"}

# Sub out funky characters in the pathname, so the user can't request
# http://www.phigita.net/*/index (causing a potentially expensive glob
# and bypassing registered procedures)!
#regsub -all {[^0-9a-zA-Z_/:\-\.]} $path {\\&} path_glob

# Grab a list of all available files with extensions.
#set files [glob -nocomplain "$path_glob$extension_pattern"]

#ns_log notice "files=$files"

# Search for files in the order specified in ExtensionPrecedence.
#set precedence [ad_parameter -package_id [ad_acs_kernel_id] "ExtensionPrecedence" "request-processor" "tcl"]
#append precedence ,vuh
### { split [string trim $precedence] "," }

#lsearch -glob $files "*.$extension" != -1 


proc rp_concrete_file {root path {precedence ""}} {

    set abs_path "${root}/${path}"

    # we need to include precedence since we may have both index.tsp and index.vuh
    set key "${path},${precedence}"
    set found_p [nsv_exists __rp_extension ${key}]
    if { $found_p } {
	set extension [nsv_get __rp_extension ${key}]
	#ns_log notice "found __rp_extension(${key})=${extension}"
	return [list ${abs_path}.${extension} ${extension}]
    }

    if { $precedence eq {} } {
	#set precedence "tsp tcl html vuh"
	set precedence "tsp tdp tcl"
    }
    foreach extension $precedence {
	set filename "${abs_path}.${extension}"
	if { [file exists $filename] } {
	    #ns_log notice "set __rp_extension(${key}) .${extension}"
	    nsv_set __rp_extension $key ${extension}
	    return [list $filename $extension]
	}
    }

    # Nada!
    # no need to cache - avoid storing virtual urls, e.g. blog/1234 
    return ""
}

proc throw {errorcode args} {
    return -code error -errorcode ${errorcode} -options [list args $args]
}

proc ad_script_abort {} {
    return -code error -errorcode ABORT
}

proc ad_acs_kernel_id {} {
    return [::xo::db::value -statement_name acs_kernel_id_get -default 0 {
	select package_id from apm_packages
	where package_key = 'core-platform'
    }]
}

ad_proc -public -deprecated ad_acs_admin_id {} {

    Returns the package_id of the control-panel package.
    You probably want ad_acs_kernel_id, that is what has all the
    useful parameters.

} {
    return [::xo::db::value -statement_name acs_admin_id_get -default 0 {
        select package_id from apm_packages
        where package_key = 'control-panel'
    }]
}


# Returns a property about the connection. See the <a
# href="/doc/kernel/request-processor/design.html">request
# processor documentation</a> for a list of allowable values. If -set
# is passed then it sets a property.

proc ad_conn_set {key value} {
    global ad_conn
    set ad_conn(${key}) ${value}
}

#used by rp-filter-procs.tcl
proc ad_conn_reset {} {

    global ad_conn

    if {[info exists ad_conn]} {
	unset ad_conn
    }
    array set ad_conn {
	request ""
	sec_validated ""
	browser_id ""
	session_id ""
	user_id ""
	token ""
	last_issue ""
	deferred_dml ""
	start_clicks ""
	node_id ""
	object_id ""
	object_url ""
	object_type ""
	package_id ""
	package_url ""
	package_key ""
	extra_url ""
	file ""
	host ""
	issecure ""
	system_p 0
	path_info ""
	locale ""
	language ""
	LD ""
	NR ""
	TZ ""
	CC ""
	UL_CC ""
	UL_HEX_LOC ""
	UL_REGION ""
    }

}

proc ad_conn_unset {key} {
    global ad_conn
    unset ad_conn($key)
}

# used by security-procs.tcl
proc ad_conn_connected_p {} {
    global ad_conn
    return [info exists ad_conn(request)]
}

proc ad_conn {key} {
    global ad_conn

    if { [info exists ad_conn(${key})] } {
	return $ad_conn(${key})
    } elseif { ${key} eq {UL_LOC} } {
	set location_id [::util::hex_to_dec $ad_conn(UL_HEX_LOC)]
	set ad_conn(UL_LOC) $location_id
	return $location_id
    } elseif { ${key} eq {UL_LAT} || ${key} eq {UL_LNG} } {
	set mydict [::xo::geoip::ip_locate_details [ad_conn peeraddr]]
	set latitude [dict get $mydict latitude]
	set longitude [dict get $mydict longitude]
	set ad_conn(UL_LAT) $latitude
	set ad_conn(UL_LNG) $longitude
	return $ad_conn(${key})
    } else {
	return [ns_conn ${key}]
    }
}


#ad_proc -private rp_register_extension_handler { extension args } {
#
#    Registers a proc used to handle requests for files with a particular
#    extension.
#
#} {
#    if { [llength $args] == 0 } {
#	error "Must specify a procedure name"
#    }
#    ns_log "Notice" "Registering [join $args " "] to handle files with extension $extension"
#    nsv_set rp_extension_handlers ".$extension" $args
#}



# rp_handle_tsp_request
# @author Neophytos Demetriou
# Handles a request for a .tsp file.
proc rp_handle_tsp_request {} {
    tsp_returnfile [ad_conn file]
    return filter_return
}


proc rp_handle_tdp_request {} {
    ::xo::tdp::returnfile [ad_conn file]
    return filter_return
}




proc tsp_returnfile {filename} {

    require_html_procs

    if { [catch {
	global __HEAD__
	set __HEAD__ ""
	set docId [dom createDocument html]
	set root [${docId} documentElement]
	${root} appendFromScript "::xo::ns::source ${filename}"


	foreach domNode [${root} selectNodes {//*[@class or @id]}] {
	    if { [$domNode hasAttribute class] } {
		$domNode setAttribute class [::xo::html::cssList [$domNode getAttribute class]]
	    }
	    if { [$domNode hasAttribute id] } {
		$domNode setAttribute id [::xo::html::cssList [$domNode getAttribute id ""]]
	    }
	}

	if { ${__HEAD__} ne {} } {
	    ${__HEAD__} appendFromScript {
		style { t [::xo::html::get_compiled_style] }
	    }
	    global __JS_INLINE__ __JS_KEY__
	    append __JS_INLINE__ ""
	    append __JS_KEY__ ""
	    if { $__JS_INLINE__ ne {} || $__JS_KEY__ ne {} } {
		${__HEAD__} appendFromScript {
		    script { nt [::xo::html::get_compiled_script] }
		}
	    }
	}

	ns_return 200 text/html [${docId} asHTML -doctypeDeclaration 1]
    } errmsg options] } {
	global errorCode
	global errorInfo
	if { ${errorCode} eq {FINISH} } {
	    ns_return 200 text/html [${docId} asHTML -doctypeDeclaration 1]
	} elseif { ${errorCode} eq {REDIRECT} } {
	    set args [dict get $options args]
	    lassign $args redirect_url
	    ad_returnredirect ${redirect_url}
	} elseif { ${errorCode} eq {ABORT} } {
	    # do nothing
	} else {
	    rp_returnerror
	}
    }

    ${docId} delete

    return
}


# Handles a request for a .tcl file.
# Sets up the stack of datasource frames, in case the page is templated.
proc rp_handle_tcl_request {} {
    if { [catch {::xo::ns::source [ad_conn file]} errmsg] } {

	global errorCode
	if { $errorCode eq {ABORT} } {
	    unset errorCode
	    return
	} else {
	    ns_log notice "[info script] rp_handle_tcl_request errmsg=$errmsg"
	    rp_returnerror
	}
    }
    return
}

proc rp_handle_vuh_request {} {
    rp_handle_tcl_request
}
#interp alias {} rp_handle_vuh_request {} rp_handle_tcl_request

if { [apm_first_time_loading_p] } {
    # Initialize nsv_sets

    nsv_array set rp_filters [list]
    nsv_array set rp_registered_procs [list]
    #nsv_array set rp_extension_handlers [list]

    # The following stuff is in a -procs.tcl file rather than a -init.tcl file
    # since we want it done really really early in the startup process. Don't
    # try this at home!

    foreach method { GET POST HEAD } {
				      nsv_set rp_registered_procs $method [list]
				  }
}


# -------------------------------------------------------------------------
# procs for hostname-based subsites
# -------------------------------------------------------------------------

ad_proc ad_host {} {
    Returns the hostname as it was typed in the browser,
    provided forcehostp is set to 0.
} {
    set host_and_port [ns_set iget [ns_conn headers] Host]
    if { [regexp {^([^:]+)} $host_and_port match host] } {
	return $host
    } else {
	return "unknown host"
    }
}

ad_proc ad_port {} {
    Returns the port as it was typed in the browser,
    provided forcehostp is set to 0.
} {
    set host_and_port [ns_set iget [ns_conn headers] Host]
    if { [regexp {^([^:]+):([0-9]+)} $host_and_port match host port] } {
	return ":$port"
    } else {
	return ""
    }
}

ad_proc root_of_host {host} {
    Maps a hostname to the corresponding sub-directory.
} {
    # The main hostname is mounted at /.
    if { [string equal $host [ns_config ns/server/[ns_info server]/module/nssock Hostname]] } {
        return ""
    }
    # Other hostnames map to subsites.
    set found_p [nsv_exists rp_lookup $host]
    if { !$found_p } {
	set node_id [rp_lookup_node_from_host $host]
	if { $node_id ne {} } {
	    nsv_set rp_lookup $host $node_id
	}
    } else {
	set node_id [nsv_get rp_lookup $host]
    }

    if { $node_id ne {} } {
        set url [site_node::get_url -node_id $node_id]

	return [string range $url 0 [expr [string length $url]-2]]
    } else {
	# Hack to provide a useful default
	return ""
    }
}

ad_proc -private rp_lookup_node_from_host { host } {
    # -cache "rp_lookup:${host}" -statement_name node_id 
    return [::xo::db::value -default "" "select node_id from host_node_map where host = [ns_dbquotevalue $host]"]
}



#########
#
#    Tell the request processor to return some other page.
#
#    The path can either be relative to the current directory (e.g. "some-template") 
#    or absolute from the server root (e.g. "/packages/my-package/www/some-template"). 
#    When there is no extension then the request processor will choose the 
#    matching file according to the extension preferences.
#
#    Parameters will stay the same as in the initial request.
#
#    @param path path to the file to serve
#

proc rp_internal_redirect { path } {

    # protect from circular redirects
    global __rp_internal_redirect_recursion_counter
    if { ![info exists __rp_internal_redirect_recursion_counter] } {
        set __rp_internal_redirect_recursion_counter 0
    } elseif { $__rp_internal_redirect_recursion_counter > 10 } {
        error "rp_internal_redirect: Recursion limit exceeded."
    } else {
        incr __rp_internal_redirect_recursion_counter
    }


    # save the current file setting
    set saved_file [ad_conn file]

    rp_serve_abstract_file [acs_root_dir] [string trimleft ${path} {/}]

    # restore the file setting. we need to do this because
    # rp_serve_abstract_file sets it to the path we internally
    # redirected to, and rp_handler will cache the file setting
    # internally in the tcl_url2file variable when PerformanceModeP is
    # switched on. This way it caches the location that was originally
    # requested, not the path that we redirected to.
    ad_conn_set file $saved_file
}


# This proc adds a query variable to AOLserver's internal ns_getform
# form, so that it'll be picked up by ad_page_contract and other procs 
# that look at the query variables or form supplied. This is useful
# when you do an rp_internal_redirect to a new page, and you want to
# feed that page with certain query variables.
# @author Lars Pind (lars@pinds.com)
# @creation-date August 20, 2002
# @return the form ns_set, in case you're interested. Mostly you'll
# probably want to discard the result.
proc rp_form_put { name value } {
     set form [::xo::ns::getform]
     ns_set put $form $name $value
     return $form
}


#if { [ns_info name] eq "NaviServer" || [ns_info version] eq {4.99} }
# this is written for NaviServer 4.99.1 or newer

rename rp_invoke_filter rp_invoke_filter_conn
proc   rp_invoke_filter { why filter_info} { rp_invoke_filter_conn _ $filter_info $why}
  
rename rp_invoke_proc   rp_invoke_proc_conn
proc   rp_invoke_proc   { argv }            { rp_invoke_proc_conn _ $argv }

#}
