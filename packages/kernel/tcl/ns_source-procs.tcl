


namespace eval ::xo::ns {;}

if { [ns_config ns/server/[ns_info server] performance_mode_p 1] } {

    ns_cache_create xo_source_cache [expr {1024*1024}]
    proc ::xo::ns::source {source_file {encoding utf-8}} {

	set script [ns_cache_eval -expires 3600 -- xo_source_cache $source_file {
	    if {![catch {open $source_file r} fid]} {
		if {![catch {fconfigure $fid -encoding $encoding} msg]} {
		    set script [read $fid]
		    catch {close $fid}
		} else {
		    # make sure channel gets closed
		    catch {close $fid}
		    return -code error "unknown encoding \"$encoding\""
		}
	    } else {
		# return error message similar to source cmd
		return -code error "couldn't read file \"$source_file\": no such file or directory"
	    }
	    # not sure if this has to be catched as well to propagate the error code to the caller
	    # to imitate the original source cmds behaviour.
	    return $script
	}]
	
	uplevel 1 $script
    }


    proc ::xo::ns::once {relative_path} {
	::RP instvar __ONCE__
	if { ![info exists __ONCE__($relative_path)] } {
	    ::xo::ns::source [acs_root_dir]/$relative_path
	    set __ONCE__($relative_path) ""
	}
    }

} else {

    proc ::xo::ns::source {source_file {encoding utf-8}} {
	set start_ms [clock milliseconds]
	uplevel 1 ::source $source_file
	set end_ms [clock milliseconds]
	ns_log notice "::xo::ns::source $source_file [expr {$end_ms - $start_ms}]"
    }

    proc ::xo::ns::once {relative_path} {
	::RP instvar __ONCE__
	if { ![info exists __ONCE__($relative_path)] } {
	    ns_log notice "source only once $relative_path"
	    ::xo::ns::source [acs_root_dir]/$relative_path
	    set __ONCE__($relative_path) ""
	}
    }

}



Class Applet
Applet instproc perform {filename} {
    ::xo::ns::source $filename
}

proc ::xo::ns::include {source_file args} {
    set o [Applet new -volatile {*}${args}]
    return [$o perform $source_file]  
}

