namespace eval ::templating::js {;}

proc ::templating::js::add_script {key deps {names ""} {tags ""} {externs ""} {js ""}} {

    global __JS__

    set __JS__(${key},tags) ${tags}
    set __JS__(${key},deps) ${deps}
    set __JS__(${key},names) ${names}
    set __JS__(${key},inline) ${js}\n

    if { {public} in ${tags} } {

	if { {defer} in ${tags} } {
	    set group "public_defer"
	} else {
	    set group "public_nodefer"
	}

	# this line says we have this public group
	lappend __JS__(groups) ${group}

	# take given key into consideration for this public group
	lappend __JS__(${group},order) ${key}

    }

    # 1. note that public stuff we used to always load for registered users
    #    so here we handle those cases that can only be viewed
    #    by registered users. It would not work well with same deps
    #    ending up with larger js in total than we have to.
    #
    # 2. so we now serve everything for registered users in one file
    #    this is accomplished by adding each file to their corresponding
    #    private group
    #
    if { {defer} in ${tags} } {
	set private_defer_group "private_defer"
	lappend __JS__(groups) ${private_defer_group}
	lappend __JS__(${private_defer_group},order) ${key}
    } else {
	# everything = private and no defer
	set everything_group "private_nodefer"
	lappend __JS__(groups) ${everything_group}
	lappend __JS__(${everything_group},order) ${key}
    }


    # 1. once everything is said and done, we will
    #    surely have the 'private_nodefer' group
    #    i.e. the everything group
    #
    # 2. if js is tagged with public, we will
    #    surely have 'public_nodefer' group
    #
    # 3. we will at most have four groups, namely
    #    'private_nodefer', 'public_nodefer', 
    #    'private_defer', and 'public_defer'.
    #
    # 4. thinking out loud: if we have more than 
    #    one group, we choose whether to have the
    #    two nodefer groups included in our html page 
    #    whereas the other two groups always end up
    #    in a file to be load via <script src="...">

}


proc ::templating::js::get_compiled_script {rootname rename_mapVar jsVar} {

    upvar $rename_mapVar rename_map
    upvar $jsVar js

    global __JS__

    set js(public) 0
    set js(private) 0

    set js(internal-0) ""
    set js(internal-1) ""
    set js(external-0) [list]
    set js(external-1) [list]
    set js(deferred-0) [list]
    set js(deferred-1) [list]

    set groups [lsort -unique [get_value_if __JS__(groups) [list]]]
    foreach group ${groups} {

	set js(${group},source) ""
	set js(${group},deps) [list]
	set js(${group},names) [list]
	set js(${group},tags) [list]

	set keys $__JS__(${group},order)
	foreach key ${keys} {

	    set deps $__JS__(${key},deps)
	    set names $__JS__(${key},names)
	    set tags $__JS__(${key},tags)
	    set inline $__JS__(${key},inline)

	    foreach dep ${deps} {
		if { ${dep} ni $js(${group},deps) } {
		    set file [file normalize [acs_root_dir]/packages/${dep}]
		    append js(${group},source) [::util::readfile ${file}]
		    lappend js(${group},deps) ${dep}
		}
	    }

	    foreach name ${names} {
		lappend js(${group},names) ${name}
	    }

	    foreach tag ${tags} {
		lappend js(${group},tags) ${tag}
	    }

	    append js(${group},source) ${inline}

	}

	if { $js(${group},names) ne {} } {
	    append js(${group},source) [::templating::css::setCssNameMapping \
					    $js(${group},names) \
					    rename_map]
	}

	set externs [list]
	set compiled_js [::templating::js::compile_js \
			     ${rootname}.${group} \
			     $js(${group},source) \
			     ADVANCED_OPTIMIZATIONS \
			     ${externs}]

	set md5_hex [::util::md5_hex $compiled_js]
	set len [string bytelength $compiled_js]

	set js(${group},compiled_js) $compiled_js
	set js(${group},compiled_js_len) ${len}
	set js(${group},md5_hex) $md5_hex

	set js_src_file ${rootname}.tdp_js_${group}
	set js_min_file ${rootname}.tdp_js_${group}_min
	set js_cdn_name ${md5_hex}.js
	set js_cdn_file [get_js_dir]/${js_cdn_name}
	set js_cdn_url [get_cdn_url "/js/${js_cdn_name}"]

	::util::writefile $js_src_file $js(${group},source)
	::util::writefile $js_min_file $js(${group},compiled_js)
	::util::writefile $js_cdn_file $js(${group},compiled_js)
	exec "/bin/gzip -9 -c ${js_cdn_file} > ${js_cdn_file}.gz"

	set js(${group},public_file) ${md5_hex}.js
	set js(${group},cdn_url) ${js_cdn_url}


	# figure out how to serve it
	set private_p 0
	if { ${group} in {private_nodefer private_defer} } {
	    set private_p 1
	    set js(private) 1 ;# we have at least one private file
	} else {
	    set js(public) 1  ;# we have at least one public file
	}

	if { ${len} < 4096 } {

	    # 1. note that this may include non-deferrable code
	    #    so if you ever consider serving it as external
	    #    then it should be external-0 and external-1
	    #    accordingly (even though it may also include
	    #    deferrable code)
	    #
	    # 2. another option is to reduce the threshold
	    #    and then it would be handled by the else branch
	    #    of this statement
	    #
	    # 3. for private_p=1 code, we need to first check
	    #    that the user is registered
	    #
	    append js(internal-${private_p}) $compiled_js

	} else {

	    if { ${group} in {public_nodefer private_nodefer} } {

		set js(external-${private_p}) $js_cdn_url

	    } else {
		
		set js(deferred-${private_p}) $js_cdn_url 
	    }
	}

    }

}



proc ::templating::js::compile_js {prefix js {compilation_level "ADVANCED_OPTIMIZATIONS"} {externs ""}} {

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
    set JAVA "java"
	set cmd "${JAVA} -jar /opt/closure/compiler.jar --compilation_level ${compilation_level} --create_source_map ${mapfile} --js ${infile} --js_output_file ${outfile} --process_closure_primitives false --define xo.DEBUG=${ENABLE_DEBUG}"
	#ns_log notice "::xo::js::compile (CLOSURE) -> cmd=$cmd"
	set errmsg [exec -- /bin/sh -c "${cmd} 2>&1 || exit 0" 2> /dev/null]
	if { [file exists $outfile] } {
	    set size [file size $outfile]
	    if { $size > 0 } {
		ns_log debug "SUCCESS file $outfile size=[file size $outfile]"
	    } else {
		ns_log error "FAILURE errmsg=$errmsg"
	    }
	} else {
	    ns_log error "file $outfile does not exist... something went wrong while compiling"
	}
    }
    set result ""
    set fp [open $outfile]
    set result [read $fp]
    close $fp
    return "(function(){${result}}).call(this);"
}
