# $Id: zz-postload.tcl,v 1.1.1.1 2002/11/22 09:47:33 nkd Exp $
# Name:        00-ad-postload.tcl
# Author:      Jon Salz <jsalz@mit.edu>
# Date:        24 Feb 2000
# Description: Sources library files that need to be loaded after the rest.

if { [::xo::kit::performance_mode_p] } {
    ::templating::compile_and_load_all [acs_root_dir]
}

set tcllib [ns_server -server [ns_info server] tcllib]

ns_log "Notice" "Sourcing files for postload..."
foreach file [glob -nocomplain ${tcllib}/*.tcl.postload] {
    ns_log Notice "postloading $file"
    source "$file"
}


# This should probably be moved to the end of bootstrap.tcl once all files are
# weeded out of the tcl directory.
ns_log "Notice" "Executing initialization code blocks..."
foreach init_item [nsv_get ad_after_server_initialization .] {
    array set init $init_item

    ns_log "Notice" "Executing initialization code block $init(name) in $init(script)"
    if { [llength $init(args)] == 1 } {
	set init(args) [lindex $init(args) 0]
    }
    if { [catch $init(args) error] } {
	global errorInfo
	ns_log "Error" "Error executing initialization code block $init(name) in $init(script): $errorInfo"
    }
}


nsv_unset ad_after_server_initialization .



ns_log notice tclversion=[info tclversion]
ns_log notice patchlevel=[info patchlevel]
ns_log notice loaded=[info loaded]
ns_log notice threads=[ns_info threads]
ns_log notice "ns_proxy pools=[ns_proxy pools]"

