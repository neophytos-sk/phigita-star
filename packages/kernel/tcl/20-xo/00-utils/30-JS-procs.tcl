namespace eval ::xo::html {;}
namespace eval ::xo::js {;}

if { [::xo::kit::performance_mode_p] } {

    #    proc ::xo::js::get_prefix {key} {
    #	set path /web/data/js/closure
    #	set prefix ${path}/${key}
    #    }

    proc ::xo::js::get_compiled {key js {compilation_level "ADVANCED_OPTIMIZATIONS"} {externs ""}} {
	append key "-[::xo::kit::is_registered_p]"
	set found_p [nsv_exists JS ${key}]
	if { !${found_p} } {
	    set code [::xo::js::compile ${key} ${js} ${compilation_level} ${externs}]
	    nsv_set JS ${key} $code
	} else {
	    set code [nsv_get JS ${key}]
	}
	return $code
    }

} else {

    proc ::xo::js::get_compiled {key js {compilation_level "ADVANCED_OPTIMIZATIONS"} {externs ""}} {
	append key "-[::xo::kit::is_registered_p]"
	set prefix [::xo::js::get_prefix ${key}]
	set token [ns_sha1 ${js}]
	set infile ${prefix}-source-${token}.js
	set force_p 1
	if { ![file exists $infile] } {
	    set force_p 1
	    ns_log notice "js changed for $key - we need to compile infile=$infile"
	}
	set found_p [nsv_exists JS ${key}]
	if { !${found_p} || ${force_p} } {
	    set code [::xo::js::compile ${key} ${js} ${compilation_level} ${externs}]
	    nsv_set JS ${key} $code
	} else {
	    set code [nsv_get JS ${key}]
	}
	return $code
    }

}

# TODO: (two different servers on different ports, phigita-backup-8000 and phigita-main-8001)
#        consider appending the following to the prefix: -[ns_conn port]
proc ::xo::js::get_prefix {key} {
    set path /web/data/js/closure
    set prefix ${path}/[ns_info hostname]-${key}
}

proc ::xo::html::script {js} {
    global __JS_INLINE__
    append __JS_INLINE ${js}\n
}

proc ::xo::html::add_script {key jsVar} {
    append key "-[::xo::kit::is_registered_p]"

    upvar $jsVar js
    global __JS_INLINE__
    append __JS_INLINE__ ${js}\n

}


ad_proc ::xo::html::add_script3 {
    {-key:required ""}
    {-deps ""}
    {-externs ""}
    {-names ""}
    {-names_map ""}
    {js ""}
} {
    @author Neophytos Demetriou
    @creation_date 2012-07-24

    @param deps List of files that need to be included.

    @param externs List of keys of compiled js code to take into 
                   consideration in order to avoid naming conflicts.

    @param names CSS class names and element IDs to be mapped to 
                 their actual (after renaming in tsp_return_file) names.

    @param names_map Object name in javascript that holds the aliases
} {

    if { $deps ne {} } {
	global __JS_KEY__ __JS_DEPS__
	lappend __JS_KEY__ $key
	lappend __JS_DEPS__ $deps
    }

    if { $names ne {} } {
	global __JS_NAMES__
	lappend __JS_NAMES__ ${names}
    }

    if { $js ne {} } {
	global __JS_INLINE__
	append __JS_INLINE__ ${js}\n
    }

}



proc ::xo::html::get_compiled_script {} {

    set key compiled_js_[::util::ino [ad_conn file]]-[::xo::kit::is_registered_p]
    set found_p [nsv_exists JS $key]
    if { !$found_p } {
	# __JS_DEPS__ is a list of filelist (one for every given key)
	global __JS_KEY__ __JS_DEPS__ __JS_NAMES__ __JS_INLINE__

	append __JS_KEY__ ""
	append __JS_NAMES__ ""
	append __JS_INLINE__ ""

	if { ${__JS_KEY__} ne {} } {
	    set filelist [join $__JS_DEPS__]
	    append js [::xo::js::readfiles $filelist]
	}

	if { ${__JS_NAMES__} ne {} } {
	    append js [::xo::html::cssListToJS "" [join $__JS_NAMES__]]	    
	}
	append js $__JS_INLINE__

	set externs [list]
	set compiled_js [::xo::js::compile ${key} ${js} ADVANCED_OPTIMIZATIONS ${externs}]
	nsv_set JS $key $compiled_js
    } else {
	set compiled_js [nsv_get JS $key]
    }

    return $compiled_js

}



proc ::xo::js::compile {key js {compilation_level "ADVANCED_OPTIMIZATIONS"} {externs ""}} {

    set prefix [::xo::js::get_prefix ${key}]
    set token [ns_sha1 ${js}]
    set infile ${prefix}-source-${token}.js
    set outfile ${prefix}-compiled-${token}.js
    set mapfile ${prefix}-map.js
    
    if { [::xo::kit::performance_mode_p] } {
	set ENABLE_DEBUG "false"
    } else {
	set ENABLE_DEBUG "true"
    }

    if { ![file exists $infile] } {
	foreach filename [glob -nocomplain ${prefix}-*] {
	    file delete -force -- $filename
	}
	set fp [open ${infile} w]
	puts $fp ${js}
	close $fp
    }
    if { ![file exists $outfile] } {

	set extra ""
	foreach extern_file $externs {
	    append extra " --externs ${extern_file} " 
	}

	#	set JAVA /usr/bin/java
	set JAVA /opt/jdk/bin/java
	set cmd "${JAVA} -jar /opt/closure/compiler.jar --compilation_level ${compilation_level} --create_source_map ${mapfile} --js ${infile} --js_output_file ${outfile} --process_closure_primitives false --define DEBUG=${ENABLE_DEBUG}"
	ns_log notice "::xo::js::compile (CLOSURE) -> cmd=$cmd"
	set errmsg [exec -- /bin/sh -c "${cmd} 2>&1 || exit 0" 2> /dev/null]
	if { [file exists $outfile] } {
	    set size [file size $outfile]
	    if { $size > 0 } {
		ns_log notice "SUCCESS file $outfile size=[file size $outfile]"
	    } else {
		ns_log notice "FAILURE errmsg=$errmsg"
		#return 
	    }
	} else {
	    ns_log notice "file $outfile does not exist... something went wrong while compiling"
	    #return
	}
    }
    set result ""
    set fp [open $outfile]
    set result [read $fp]
    close $fp
    return "(function(){\"use strict\";${result}}).call(this);"
}

proc ::xo::js::readfiles {filelist} {
  set js ""
  array set seen [list]
  foreach filename ${filelist} {
    if { ![info exists seen($filename)] } {
      append js [::util::readfile [file join [acs_root_dir]/packages/ $filename]]
      set seen($filename) 1
    }
  }
  return $js
}

    proc ::xo::js::compile_and_publish {key filelist {externs ""}} {
	set compilation_level "ADVANCED_OPTIMIZATIONS"
	set js [::xo::js::readfiles $filelist]
	set compiled_js [::xo::js::compile ${key} ${js} ${compilation_level} ${externs}]
	::util::writefile [file join /web/data/js/package/ ${key}.js] $compiled_js
    }

if { [::xo::kit::performance_mode_p] } {

    proc ::xo::js::include_compiled {key filelist {externs ""} {compilation_level "ADVANCED_OPTIMIZATIONS"}} {
	# append key "-[::xo::kit::is_registered_p]"
	return [ns_cache_eval util_memoize JS:${key} {
	    set js [::xo::js::readfiles $filelist]
	    return [::xo::js::compile ${key} ${js} ${compilation_level} ${externs}]
	}]
    }


} else {
    proc ::xo::js::include_compiled {key filelist {externs ""} {compilation_level "ADVANCED_OPTIMIZATIONS"}} {
	set js [::xo::js::readfiles $filelist]
	if { [info exists ::__NO_COMPILE__] } {
	    return ${js}
	} else {
	    return [::xo::js::compile ${key} ${js} ${compilation_level} ${externs}]
	}
    }
}

proc ::xo::js::include {key filename} {
    return [ns_cache_eval util_memoize JS:FILE:${key} {
	set js [::util::readfile ${filename}]
	return $js
    }]
}
