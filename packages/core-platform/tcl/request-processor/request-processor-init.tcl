ad_library {

    Initialization stuff for the request processing pipeline.

    @author Neophytos Demetriou (k2pts@phigita.net)
    @cvs-id $Id: request-processor-init.tcl,v 1.1.1.1 2002/11/22 09:47:32 nkd Exp $
}

# These procedures are dynamically defined at startup to alleviate
# lock contention. Thanks to davis@arsdigita.com.

proc ad_acs_admin_id_mem {} {
    return [::xo::db::value -statement_name acs_kernel_id_get -default 0 {
	select package_id from apm_packages
	where package_key = 'core-platform'
    }]
}

proc ad_acs_kernel_id_mem {} {
    return [::xo::db::value -statement_name acs_kernel_id_get -default 0 {
        select package_id from apm_packages
        where package_key = 'core-platform'
    }]
}

proc ad_acs_kernel_id {} "
    return [ad_acs_kernel_id_mem]
"

proc ad_acs_admin_id {} "
    return [ad_acs_admin_id_mem]
"


nsv_set rp_properties request_count 0

foreach method {GET HEAD POST} {
#HERE				ns_register_filter preauth $method * rp_filter
#				ns_register_proc $method / rp_handler
			    }

# Unregister any GET/HEAD/POST handlers for /*.tcl (since they
# interfere with the abstract URL system). AOLserver automatically
# registers these in file.tcl if EnableTclPages=On.

ns_unregister_op GET /*.tcl
ns_unregister_op HEAD /*.tcl
ns_unregister_op POST /*.tcl
ns_unregister_op GET /*.adp
ns_unregister_op HEAD /*.adp
ns_unregister_op POST /*.adp


#set listings [ns_config "ns/server/[ns_info server]" "directorylisting" "none"]
#if { [string equal $listings "fancy"] || [string equal $listings "simple"] } {
#    nsv_set rp_directory_listing_p . 1
#} else {
#    nsv_set rp_directory_listing_p . 0
#}

# this initialization must be in a package alphabetically before
# acs-templating, so this adp handler can be overwritten there.
#    adp rp_handle_adp_request

#    adp rp_handle_adp_request
#foreach { type handler } {
#    tsp rp_handle_tsp_request
#    tcl rp_handle_tcl_request
#    vuh rp_handle_tcl_request
#    js rp_handle_js_request
#    css rp_handle_css_request
#} {
#    rp_register_extension_handler $type $handler
#}

ad_after_server_initialization filters_register {
    if {[nsv_exists rp_filters .]} {
	set filters [nsv_get rp_filters .]
    } else {
	set filters [list]
    }
    # This lsort is what makes the priority stuff work. It guarantees
    # that filters are registered in order of priority. AOLServer will
    # then run the filters in the order they were registered.
    set filters [lsort -integer -index 0 $filters]
    nsv_set rp_filters . $filters

    set filter_index 0
    foreach filter_info $filters {
	util_lassign $filter_info priority kind method path \
	    proc arg debug critical description script
	
	# Figure out how to invoke the filter, based on the number of arguments.
	if { [llength [info procs $proc]] == 0 } {
	    # [info procs $proc] returns nothing when the procedure has been
	    # registered by C code (e.g., ns_returnredirect). Assume that neither
	    # "conn" nor "why" is present in this case.
	    set arg_count 1
	} else {
	    set arg_count [llength [info args $proc]]
	}

	if { $debug == "t" } {
	    set debug_p 1
	} else {
	    set debug_p 0
	}

	ns_register_filter $kind $method $path rp_invoke_filter \
	    [list $filter_index $debug_p $arg_count $proc $arg]
	
	incr filter_index
    }
}

ad_after_server_initialization procs_register {
    if {[nsv_exists rp_registered_procs .]} {
	set procs [nsv_get rp_registered_procs .]
    } else {
	set procs [list]
    }

    set proc_index 0
    foreach proc_info $procs {
	util_lassign $proc_info method path proc arg debug noinherit description script

	if { $noinherit == "t" } {
	    set noinherit_switch "-noinherit"
	} else {
	    set noinherit_switch ""
	}

	# Figure out how to invoke the filter, based on the number of arguments.
	if { [llength [info procs $proc]] == 0 } {
	    # [info procs $proc] returns nothing when the procedure has been
	    # registered by C code (e.g., ns_returnredirect). Assume that neither
	    # "conn" nor "why" is present in this case.
	    set arg_count 1
	} else {
	    set arg_count [llength [info args $proc]]
	}

	if { $debug == "t" } {
	    set debug_p 1
	} else {
	    set debug_p 0
	}

	eval ns_register_proc $noinherit_switch \
	    [list $method $path rp_invoke_proc [list $proc_index $debug_p $arg_count $proc $arg]]
    }
}

