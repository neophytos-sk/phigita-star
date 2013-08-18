proc acs_root_dir {} {
    return "/web/servers/service-phigita/"
}

namespace eval ::xo::kit {;}

if { [ns_config ns/server/[ns_info server] performance_mode_p 1] } {
    proc ::xo::kit::performance_mode_p {} { return 1 }
    proc ::xo::kit::debug_mode_p {} { return 0 }
} else {
    proc ::xo::kit::performance_mode_p {} { return 0 }
    proc ::xo::kit::debug_mode_p {} { return 1 }
}


if { [ns_config ns/server/[ns_info server] production_mode_p 1] } {
    proc ::xo::kit::production_mode_p {} {
	return 1
    }
} else {
    proc ::xo::kit::production_mode_p {} {
	return 0
    }
}


namespace eval ::xo::lib {
    variable __LOADED__MODULE__
    array set __LOADED_MODULE__ [list]
}


if { [::xo::kit::production_mode_p] } {
    proc ::xo::lib::require {module_name} {
	variable __LOADED_MODULE__
	if { ![info exists __LOADED_MODULE__(${module_name})] } {
	    source [file join [acs_root_dir] lib ${module_name} pkgIndex.tcl]
	    set __LOADED_MODULE__(${module_name}) [clock seconds]
	}
	package require ${module_name}
    }
} else {
    proc ::xo::lib::require {module_name} {
	ns_log notice "(debug mode) loading module ${module_name}..."	
	source [file join [acs_root_dir] lib ${module_name} pkgIndex.tcl]
	package require ${module_name}
    }
}

proc ::xo::lib::forget {module_name} {
    variable __LOADED_MODULE__
    if { [info exists __LOADED_MODULE__(${module_name})] } {
	unset __LOADED_MODULE__(${module_name})
    }
    package forget ${module_name}
}
