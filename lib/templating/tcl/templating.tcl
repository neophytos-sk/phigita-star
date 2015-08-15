
# -----------------------------------------------------------------------------------

proc tdom_getElementById {node target} {
    return [$node selectNodes [subst -nocommands -nobackslashes {//*[@id='${target}']}]]
}

proc tdom_getElementByOtherId {node target} {
    return [$node selectNodes [subst -nocommands -nobackslashes {//*[@other_id='${target}']}]]
}

proc tdom_attributesDict {node} {

    set mydict [dict create]
    foreach att [$node attributes] {
        dict append mydict $att [$node getAttribute $att ""]
    }
    return $mydict
}

proc tdom_innerHTML {node} {
    set html ""
    foreach child [$node childNodes] {
        append html [$child asHTML]
    }
    return $html
}

proc ns_quotehtml {str} {
# TODO
    return $str
}

namespace eval ::templating {;}

proc ::templating::compile_and_load_all {dir} {
    set files [file __find $dir *.tdp]
    foreach filename $files {
        if { [catch {compile_and_load $filename} errMsg] } {
            log notice "failed to ::templating::compile_and_load $filename errMsg=$errMsg"
        }
    }
}

proc ::templating::compile_and_load {filename} {
    ::xo::tdp::compile_and_load $filename
    set ino [::util::ino $filename]
    set tcl_cmd_name "::www_${ino}"
    ::xo::tdp::set_cmd ${filename} ${tcl_cmd_name}
}

proc ::templating::get_and_check_param {id name strict_p optional_p default vlist proclist} {

    # get param value
    set exists_p [::xo::kit::getparam ${id} value]

    # check whether optional and set default value
    if { !${exists_p} } {

	if { !${optional_p} } { 
	    return 0
	}

	set value ${default}

    }

    # validation checks
    if { ${strict_p} || ${value} ne {} } {
	foreach vcheck ${vlist} {
	    if { ![::templating::validation::check=${vcheck} value] } {
		return 0
	    }
	}
    }

    # apply transformations
    foreach procname ${proclist} {
	set value [${procname} ${value}]
    }

    # save the value
    set ::__data__(${name}) ${value}

    return 1

}



# ---------------------------------------------------------------------------------------------

namespace eval ::xo::tdp {
    variable widget_count 0
    array set __tdp_cmd_name [list]
}

proc ::xo::tdp::set_cmd {filename tcl_cmd_name} {
    variable __tdp_cmd_name 
    set __tdp_cmd_name(${filename}) ${tcl_cmd_name}
}

proc ::xo::tdp::get_cmd {filename} {
    variable __tdp_cmd_name 
    return $__tdp_cmd_name(${filename})
}


if { [::xo::kit::production_mode_p] } {

    proc ::xo::tdp::returnfile {filename} {
    # if you reached this point, cmd should exist
    # otherwise it is ok to try to exec first
    # and then raise an error if it does not
        variable __tdp_cmd_name
        set cmd $__tdp_cmd_name(${filename})
        ${cmd}
    }

} else {

    proc ::xo::tdp::return_html {tcl_cmd_name} {

        if { [catch {set html [${tcl_cmd_name}]} errMsg] } {
            log "Error in C compiled page: errMsg=$errMsg"
            rp_returnerror
            return
        }

    }

    proc ::xo::tdp::returnfile {filename} {
        ::xo::tdp::compile_and_load $filename
        set ino [::util::ino $filename]
        set tdp_cmd_name "::www_${ino}"

        set start [clock milliseconds]
        #set html [${cmd}]
        ${tdp_cmd_name}
        set finish [clock milliseconds]
        set duration [expr { $finish - $start }]
        log "processing took $duration milliseconds"

        #ns_return 200 text/html ${html}

    }
}

proc ::xo::tdp::process {filename} {
    ::xo::tdp::compile_and_load $filename
    set ino [::util::ino $filename]
    set tdp_cmd_name "::www_${ino}"

    set start [clock milliseconds]
    set html [${tdp_cmd_name}]
    set finish [clock milliseconds]
    set duration [expr { $finish - $start }]
    log "processing took $duration milliseconds"

    return $html
}



proc ::xo::tdp::init_globals {} {

    global __JS__

    if { [array exists __JS__] } {
	array unset __JS__
    }
    if { [array exists __EL__] } {
	array unset __EL__
    }
    if { [array exists __KEEP__] } {
	array unset __KEEP__
    }
    if { [array exists __EXCLUDE__] } {
	array unset __EXCLUDE__
    }

    array set __JS__ [list]

    set ::__CSS_ID__ 0
    array set ::__CSS_EL__ [list]
    array set ::__CSS_KEEP__ [list]
    array set ::__CSS_EXCLUDE__ [list]

}



proc ::xo::tdp::compareNodes {node1 node2} {
    return [$node1 precedes $node2]
}

# include takes precedence over master and other tags
proc ::xo::tdp::initial_rewrite_compare {node1 node2} {
    log notice "node1=[$node1 attributes] node2=[$node2 attributes]"

    set type1 [$node1 @type ""]
    set type2 [$node2 @type ""]

    if { ${type1} eq {include} && ${type2} ne {include} } {
	return -1
    } elseif { ${type1} ne {include} && ${type2} eq {include} } {
	return 1
    } else {
	return [$node1 precedes $node2]
    }
}



    proc ::xo::tdp::thisdir {} "return [list [file dirname [info script]]]"
    proc ::xo::tdp::latest_mtime {inputfile} {

	global __compile_cache__

	# latest mtime for the files in the templating package
	set filelist [file __find [thisdir] *]

	# add the source file
	lappend filelist $inputfile

	# add file dependencies
	set depfile [::critcl::ext::get_build_rootname $inputfile].tdp_dep
	if { [file readable $depfile] } {
	    foreach filename [::util::readfile $depfile] {
		lappend filelist $filename
	    }
	}

	set mtime 0
	foreach filename $filelist {
	    if { [file __newer_than_mtime $filename $mtime] } {
		set mtime [file mtime $filename]
	    }
	}

	return $mtime
    }

proc ::xo::tdp::as_xml {xml} {
    return "see test-xslt.tcl"
}

proc ::xo::tdp::compile_and_load {filename} {

    require_template_procs

    set rootname [::critcl::ext::get_build_rootname $filename]
    set specfile ${rootname}.tdp_spec
    set xmlfile ${rootname}.tdp_xml
    set htmlfile ${rootname}.tdp_html
    set sharedlib [::critcl::ext::get_sharedlib $filename]
    set ininame [::critcl::ext::get_ininame $filename]


    set latest_mtime [latest_mtime $filename]
    if { [::xo::kit::performance_mode_p] && [file exists $sharedlib] } {
	if { [file __newer_than_mtime $sharedlib $latest_mtime] } {
	    log notice "--->>> load $sharedlib $ininame"
	    load $sharedlib $ininame
	    return 
	}
    }

    if { [file exists ${specfile}] } {
	file delete -force -- ${rootname}.tdp_spec
	file delete -force -- ${rootname}.tdp_spec_inc
	file delete -force -- ${rootname}.tdp_spec_ini
	file delete -force -- ${rootname}.tdp_spec_final
	#file delete -force -- ${rootname}.tdp_xml
	file delete -force -- ${rootname}.tdp_dep
	file delete -force -- ${rootname}.tdp_html

	file delete -force -- ${rootname}.tdp_private_defer-map.js
	file delete -force -- ${rootname}.tdp_private_nodefer-map.js
	file delete -force -- ${rootname}.tdp_public_defer-map.js
	file delete -force -- ${rootname}.tdp_public_nodefer-map.js

	# private_defer-source-*.js
	# private_nodefer-source-*.js
	# public_defer-source-*.js
	# public_nodefer-source-*.js
	# private_defer-compiled-*.js
	# private_nodefer-compiled-*.js
	# public_defer-compiled-*.js
	# public_nodefer-compiled-*.js

	file delete -force -- ${rootname}.tdp_js_private_defer
	file delete -force -- ${rootname}.tdp_js_private_defer_min
	file delete -force -- ${rootname}.tdp_js_private_nodefer
	file delete -force -- ${rootname}.tdp_js_private_nodefer_min
	file delete -force -- ${rootname}.tdp_js_public_defer
	file delete -force -- ${rootname}.tdp_js_public_defer_min
	file delete -force -- ${rootname}.tdp_js_public_nodefer
	file delete -force -- ${rootname}.tdp_js_public_nodefer_min

	file delete -force -- ${rootname}.tdp_css
	file delete -force -- ${rootname}.tdp_css_keep
	file delete -force -- ${rootname}.tdp_css_map
	file delete -force -- ${rootname}.tdp_css_min
	file delete -force -- ${rootname}.tdp_css_min_final
	file delete -force -- ${rootname}.tdp_css_min_dropped
	file delete -force -- ${rootname}.tdp_c
	file delete -force -- ${rootname}.c
	file delete -force -- ${rootname}.o


	set c_ext ".c"
	set sharedlibext [info sharedlibext]
	foreach x [glob -nocomplain ${rootname}.*.*.*${c_ext}] {
	    file delete -force -- $x
	}
	foreach x [glob -nocomplain ${rootname}.*.*.*${sharedlibext}] {
	    file delete -force -- $x
	}
    }

    #  To get a list of just the packages in the current interpreter, 
    # specify an empty string for the interp argument.
    # it does not seem to be used
    #
    # error message: "cannot be unloaded under a trusted interpreter"
    #
    # if { [list $sharedlib $ininame] in [info loaded ""] } {
    # log notice "--->>> (already loaded) unload $sharedlib"
    # unload $sharedlib
    # }



    ::xo::tdp::init_globals


    set doc [source_tdom $filename ::templating::lang "html"]

	::util::writefile $specfile [$doc asHTML]

	::xo::tdp::compile_doc $doc $filename

    ::util::writefile $xmlfile [::xo::tdp::as_xml $doc]

    ::util::writefile $htmlfile [$doc asHTML]

    $doc delete
    
    # we also explicitly set load=0 while calling cbuild

    # latest mtime may have changed because of the deps
    # get those names again, taking the new deps into consideration
    set sharedlib [::critcl::ext::get_sharedlib $filename]
    set ininame [::critcl::ext::get_ininame $filename]

    log notice "--- (after compile) --->>> load $sharedlib $ininame"
    load $sharedlib $ininame
}

proc ::xo::tdp::next_other_id {} {
    variable widget_count

    return [::templating::css::obfuscate [incr widget_count]]
}

proc ::xo::tdp::compile_doc {templateDoc filename} {

    set rootname [::critcl::ext::get_build_rootname $filename]

    array set codearr [list \
        build_rootname $rootname \
        file $filename \
        defs "" \
        global_strings "" \
        global_strings_len 0 \
        macros ""]

    set ::__CSS_FILE__ [list]

    set start [clock milliseconds]


    #set xpath_all_widgets {//master|//include|//contract|//val|//guard|//js|//css|//tcl|//widget}
    set xpath_all_widgets {//widget}

    # get widgets from dom tree
    set widgets [$templateDoc selectNodes $xpath_all_widgets]

    # get some dependencies here, 
    # e.g. from master and include nodes, 
    # before we delete any widget
    set deps [list]
    foreach widget $widgets {
        set deps [concat ${deps} [::xo::tdp::compile_helper codearr $widget "deps"]]
    }


    set include_widgets [$templateDoc selectNodes {//include}]
    foreach widget $include_widgets {

        if { [catch {
            ::xo::tdp::compile_helper codearr $widget "initial_rewrite"
        } errmsg options] } {
            log "--->>>" \n\n errmsg=$errmsg widget=[$widget nodeName]
        }
        if { [$widget @__todelete "0"] } {
            $widget delete
        }
    }

    ::util::writefile ${rootname}.tdp_spec_inc [$templateDoc asHTML]

    # initial rewrite
    #set sorted_widgets [lsort -command initial_rewrite_compare $widgets]
    set widgets [$templateDoc selectNodes $xpath_all_widgets]
    foreach widget $widgets {
        if { [catch {
            ::xo::tdp::compile_helper codearr $widget "initial_rewrite"
        } errmsg options] } {
            log "--->>>" \n\n errmsg=$errmsg \n\n widget=[$widget nodeName]
        }

        if { [$widget @__todelete "0"] } {
            $widget delete
        }
    }

    ::util::writefile ${rootname}.tdp_spec_ini [$templateDoc asHTML]

    # we have deleted some, 
    # and initial_rewrite introduced some,
    # get the widgets again
    set widgets [$templateDoc selectNodes {//widget}]


    # get any new dependencies
    # e.g. css with '-src' attribute inside master file
    foreach widget $widgets {
        set deps [concat ${deps} [::xo::tdp::compile_helper codearr $widget "deps"]]
    }

    ::util::writefile ${rootname}.tdp_dep [lsort -unique ${deps}]


    # final rewrite
    foreach widget $widgets {
        if { [catch {::xo::tdp::compile_helper codearr $widget "final_rewrite"} errmsg] } {
            log "--->>>" \n\n errmsg=$errmsg \n\n widget=[$widget nodeName]
        }

        if { ![$widget @__todelete "0"] } {
            $widget setAttribute other_id [next_other_id]
        }

        # Do not delete widget here. Other widgets may depend on it.

    }

    ::util::writefile ${rootname}.tdp_spec_final [$templateDoc asXML -indent 2]

    # Delete and catch errors by nested widgets (may have been deleted already)
    foreach widget $widgets {
        if { [$widget @__todelete "0"] } {
            $widget delete
        }
    }


    if {0} {

        # -------------------------- compile css -----------------------------------
        
        set css_min [::templating::css::compile_css codearr $templateDoc $filename rename_map seen]

        # -------------------------- compile js ------------------------------------

        set rootname [::critcl::ext::get_build_rootname $filename]
        ::templating::js::get_compiled_script ${rootname} rename_map js

        # ---------------- rename classes in the template doc ----------------------
        #
        # 1. using rename_map to do the renaming
        # 2. updates seen var that is used in the next stage for more optimizations
        #

        ::templating::css::rename_doc_classes $templateDoc rename_map seen


        # ---------------- further css optimizations -------------------------------
        #
        # css_min_final needs '__CSS_KEEP__' that keeps values set by setCssMappping
        # setCssMapping is called by get_compiled_script

        if { $css_min ne {} } {
            set css_min_final [::templating::css::optimize_css codearr $templateDoc $filename $css_min seen]
            set css_min_final_len [string bytelength $css_min_final]

            set css_md5_hex [::util::md5_hex $css_min_final]
            set css_public_file ${css_md5_hex}.css
            set cdn_css_min_file [get_css_dir]/${css_public_file}
            ::util::writefile $cdn_css_min_file $css_min_final

            exec -- /bin/sh -c "/bin/gzip -9 -c ${cdn_css_min_file} > ${cdn_css_min_file}.gz"

            set css_min_final_url [get_cdn_url "/css/${css_public_file}"]
        }

    } else {
        log notice "--->>> DISABLED CSS/JS COMPILATION TO EASE DEVELOPMENT"
        set css_min ""
        array set js [list private false public false]
    }

    # set preload ""
    # set images [$templateDoc selectNodes {//img}]


    # set preload "setTimeout(function(){if (document.images) (new Image()).src='http://www.phigita.net/graphics/logo-v2.png';},1);"
    # script -type text/javascript { nt $preload }


    set head [lindex [$templateDoc selectNodes {//head}] 0]
    set body [lindex [$templateDoc selectNodes {//body}] 0]
    if { $head ne {} } {
        $head appendFromScript {

            if { $css_min ne {} } {
                if { [xo::kit::debug_mode_p] || ${css_min_final_len} < 8192 } {
                    style -type text/css { nt ${css_min_final} }
                } else {
                    link -rel "stylesheet" -type "text/css" -href $css_min_final_url
                }
            }

            # javascript: start

            if { $js(public) } {

                val -id registered_p -other_id [next_other_id] { ::xo::kit::is_registered_p }
                ::templating::lang::tpl -if "not @{val.registered_p}" {

                ## we have some js code for the public

                    if { $js(internal-0) ne {} } {
                        script -type text/javascript { nt $js(internal-0) }
                    }

                    ## there can only be only one external url for the public
                    ## but the code seems to be cleaner written in this way

                    foreach url $js(external-0) {
                        script -src $url
                    }

                    ## there can only be one deferred url for the public
                    ## but the code seems to be cleaner written in this way
                    foreach url $js(deferred-0) {

                        set deferred_js [subst -nocommands -nobackslashes {function _xo_0(){var e=document.createElement('script');e.src='${url}';document.body.appendChild(e);};}]

                        append deferred_js {window.addEventListener?window.addEventListener("load",_xo_0,0):(window.attachEvent?window.attachEvent("onload",_xo_0):window.onload=_xo_0);}

                        script -type text/javascript { nt $deferred_js }


                    }

                }

            }

            if { $js(private) } {

            ## we have some js code for registered users

                val -id registered_p -other_id [next_other_id] { ::xo::kit::is_registered_p }
                ::templating::lang::tpl -if "@{val.registered_p}" {

                    if { $js(internal-1) ne {} } {
                        script -type text/javascript { nt $js(internal-1) }
                    }

                    ## there can only be only one external url for registered users
                    ## but the code seems to be cleaner written in this way

                    foreach url $js(external-1) {
                        script -src $url
                    }

                    ## there can only be one deferred url for the registered users
                    ## but the code seems to be cleaner written in this way
                    foreach url $js(deferred-1) {

                        set deferred_js [subst -nocommands -nobackslashes {function _xo_1(){var e=document.createElement('script');e.src='${url}';document.body.appendChild(e);};}]

                        append deferred_js {window.addEventListener?window.addEventListener("load",_xo_1,0):(window.attachEvent?window.attachEvent("onload",_xo_1):window.onload=_xo_1);}

                        script -type text/javascript { nt $deferred_js }

                    }

                }
            }

            # javascript: end


        }
    }

    set finish [clock milliseconds]
    set duration [expr { $finish - $start }]
    log "compiled tdp file ($filename) in ${duration}ms"

    ::xo::tdp::compile_doc_in_c codearr $templateDoc $filename
}

proc ::xo::tdp::compile_doc_in_c {codearrVar templateDoc filename} {

    upvar $codearrVar codearr

    set ino [::util::ino $filename]
    set ino_hex [format "%x" $ino]
    set tcl_cmd_name "::www_${ino}"
    set c_cmd_name "www_${ino}_Cmd"

    append codearr(macros) "\n" "#define ASSOC_DATA_KEY_go \"${ino_hex}_go\""  ;# global_objects
    append codearr(macros) "\n" "#define ASSOC_DATA_KEY_ds \"${ino_hex}_ds\""  ;# dstring

    set c_code [compile_to_c codearr $templateDoc $c_cmd_name $tcl_cmd_name]

    set rootname [::critcl::ext::get_build_rootname $filename]
    set c_file ${rootname}.tdp_c
    ::util::writefile $c_file $c_code

    set init_code [subst -nocommands -nobackslashes {

        // init_text
        DBG(fprintf(stderr,"templating initializing... $tcl_cmd_name\n"));

        tdp_RegisterExitHandlers(ip); // interp
        tdp_InitModule(ip);

    }]

    array set conf [list]
    set conf(debug_mode_p) [::xo::kit::debug_mode_p]

    set conf(clibraries) "-L/opt/naviserver/lib -lnsd"
    set conf(includedirs) [list "/opt/naviserver/include" [file join [acs_root_dir] "lib/templating/c"]]
    set conf(cinit) $init_code
    set conf(ccode) $c_code

    #set load 0
    #set pretend_load 1
    #lassign [::critcl::cbuild ${filename} ${load} "" "" ${pretend_load} ${base}] libfile ininame
    lassign [::critcl::ext::cbuild_module ${filename} conf] libfile ininame

    set dir [file dirname ${rootname}]
    set tailname [file tail ${rootname}]
    set tarfile ${rootname}.tar.bz2
    set filelist [lsearch -all -inline -not \
		      [glob -directory ${dir} -type f -tails ${tailname}.*] \
		      [file tail ${tarfile}]]

    exec -- /bin/sh -c "/bin/tar --directory ${dir} -cjf ${tarfile} ${filelist}"

}

proc exists_indexed_script {codearrVar script {refVar ""}} {
    upvar $codearrVar codearr

    if { $refVar ne {} } {
	upvar $refVar ref
    }


    set md5_hex [::util::md5_hex ${script}]
    set ref [value_if codearr(script,${md5_hex}) ""]

    if { $ref ne {} } {
	return 1
    } else {
	return 0
    }

}

proc add_indexed_script {codearrVar other_id script} {
    upvar $codearrVar codearr

    set global_name OBJECT_SCRIPT_${other_id}
    set md5_hex [::util::md5_hex ${script}]
    set codearr(script,${md5_hex}) ${other_id}
    add_global_string codearr $global_name ${script}
}

proc exists_global_string {codearrVar global_name} {
    upvar $codearrVar codearr

    if { [info exists codearr(macro,${global_name})] } {
	return 1
    }

    return 0
}

proc add_global_string {codearrVar global_name global_string} {
    upvar $codearrVar codearr

    if { [info exists codearr(macro,${global_name})] } return

    incr codearr(global_strings_len)
    set current_index [expr { $codearr(global_strings_len) - 1 }]
    append codearr(macros) "\n" "#define ${global_name} $current_index"
    lappend codearr(global_strings) $global_string
    set codearr(macro,${global_name}) 1

}


proc exists_singleton_datastore {codearrVar global_name} {
    upvar $codearrVar codearr
    if { [info exists codearr(${global_name},singleton)] && $codearr(${global_name},singleton) } {
	return true
    }
    return false
}

proc ::xo::tdp::compile_to_c_helper {codearrVar templateDoc} {

    upvar $codearrVar codearr

    set htmlDoc $templateDoc

    set codearr(index) 1
    set widgets [$htmlDoc selectNodes {//widget}]
    #set widgets [lsort -command compareNodes $widgets]
    foreach widget $widgets {
	if { [$widget @skip "0"] } continue
	set cmdName [$widget @type]

	#log notice "type=$cmdName id=[$widget @id ""]"

	set pn [$widget parentNode]
	$pn insertBeforeFromScript {
	    t "\xff"
	    nt [::templating::tag::${cmdName}::to_c codearr ${widget}]
	    t "\xff"
	} $widget

	incr codearr(index) 2

	# Do not delete widget here. Other widgets may depend on it.
	
    }


    # Delete and catch errors by nested widgets (may have been deleted already)
    foreach widget $widgets {
	catch {$widget delete}
    }

    # check if noroot has been set via a pragma / directive
    # if set it skips the doctype declaration and the html tag
    # this is useful for rss pages

    set noroot [value_if codearr(pragma.noroot) "0"]
    set doctype [value_if codearr(pragma.doctype) ""]

    if { ${noroot} } {
	set root [$htmlDoc documentElement]
	set code ""
	append code ${doctype} "\n"
	foreach node [$root childNodes] {
	    append code [$node asHTML]
	}
    } else {
	if { ${doctype} eq {} } {
	    set code [$htmlDoc asHTML -doctypeDeclaration 1]
	} else {
	    set code ""
	    append code ${doctype} "\n"
	    append code [$htmlDoc asHTML]
	}
    }


    return $code

}

proc ::xo::tdp::compile_to_c {codearrVar templateDoc c_cmd_name tcl_cmd_name} {

    upvar $codearrVar codearr

    # compile to intermediate format
    set intermediate_code [compile_to_c_helper codearr $templateDoc]
    set parts [split $intermediate_code "\xff"]
    set num_of_parts [expr { 1 + [llength $parts] }]
    set NULL \"\\0\"
    set index 0
    foreach {markup code} ${parts} {

	if { $markup ne {} } {
	    set bytes  [::util::cstringquote_escape_newlines ${markup} length]
	    append result "\n\n" "Tcl_DStringAppend(dsPtr,${bytes},${length});"
	} else {
	    # used to be: "\n\n" "html\[${index}\] = ${NULL};"
	}
	incr index

	# used to be: "\n\n" "html\[${index}\] = ${NULL};"
	if { $code ne {} } {
	    set retvalvar "retval_${index}"
	    append result "\n" "DBG(fprintf(stderr,\"executing index=${index} code=${code}\\n\"));"
	    append result "\n" "int ${retvalvar} = ${code};"
	    append result "\n" "if (TDP_ERROR == ${retvalvar}) {"
	    append result "\n" "\t" "DSTRING_FREE(dsPtr);"
	    append result "\n" "\t" "DBG(fprintf(stderr,\"error in index=${index}\\n\"));"
	    append result "\n" "\t" "return TCL_ERROR;"
	    append result "\n" "} else if (TDP_ABORT == ${retvalvar}) {"
	    append result "\n" "\t" "Tcl_ResetResult(interp);"
	    append result "\n" "\t" "DSTRING_FREE(dsPtr);"
	    append result "\n" "\t" "DBG(fprintf(stderr,\"abort in index=${index}\\n\"));"
	    append result "\n" "\t" "return tdp_ReturnBlank();"
	    append result "\n" "}"
	}
	incr index

	set markup ""
	set code ""

    }

    add_global_string codearr OBJECT_NSF_VAR_SET ::nsf::var::set

    set c_global_strings [join [map x $codearr(global_strings) {::util::cstringquote_escape_newlines $x}] ",\n\t\t"]

    set c_global_strings_len_arr [join [map x $codearr(global_strings) {string bytelength $x}] {,}]



    set mime_type [value_if codearr(pragma.mime_type) "text/html"]

    set c_cmd_code [subst -nocommands -nobackslashes {

        ${result}

        int len = Tcl_DStringLength(dsPtr);
        const char *data = Tcl_DStringValue(dsPtr);
        DBG(fprintf(stderr,"page size/length=%d\n",len));

        #ifdef __USE_NS__
        const int status = 200;
        const char type[] = "${mime_type}";
        Ns_Conn *conn = Ns_GetConn();
        int result = Ns_ConnReturnCharData(conn, status,data,len,type);
        return tdp_Result(interp,result);
        #else
        Tcl_DStringResult(interp,dsPtr);
        return TCL_OK;
        #endif



    }]

    if { [value_if codearr(pragma.debug) "0"] } {
	append codearr(macros) "\n" "#define DEBUG"
    }

    if { [value_if codearr(pragma.reuse_dstring) "0"] } {
	append codearr(macros) "\n" "#define REUSE_DSTRING"
    }

    set data_object_type [::templating::config::get_option "data_object_type"]
    if { $data_object_type eq {NSF} } {
	append codearr(macros) "\n" "#define USE_NSF"
    }	

    return [subst -nocommands -nobackslashes {

        $codearr(macros)

        #include "tdp.h"

        static const char *const global_strings[] = { 
            $c_global_strings 
        };

        static const int global_string_len[] = {
            $c_global_strings_len_arr
        };

        static void
        tdp_cleanup(Tcl_Interp *interp) {
            DBG(fprintf(stderr,"--->>> tdp_cleanup\n"));

            Tcl_Obj **global_objects = 
            (Tcl_Obj **) Tcl_GetAssocData(interp, ASSOC_DATA_KEY_go, NULL);

            if (!global_objects) {
                DBG(fprintf(stderr,"--->>> tdp_cleanup: no global_objects to clean file=$codearr(file)\n"));
                return;
            }

            int i;
            for(i = 0; i < $codearr(global_strings_len); i++) 
            {
                Tcl_DecrRefCount(global_objects[i]);
            }

            Tcl_Free((char *) global_objects);
            Tcl_DeleteAssocData(interp,ASSOC_DATA_KEY_go);

            #ifdef REUSE_DSTRING
            Tcl_Obj *dsPtr = (Tcl_DString *) Tcl_GetAssocData(interp, ASSOC_DATA_KEY_ds, NULL);
            if (!dsPtr) {
                DBG(fprintf(stderr,"--->>> tdp_cleanup: no dstring to clean file=$codearr(file)\n"));
                return;
            }
            Tcl_DStringFree(dsPtr);
            Tcl_Free((char *) dsPtr);
            Tcl_DeleteAssocData(interp,ASSOC_DATA_KEY_ds);
            #endif

        }


        // ----------------------------------- widgets ----------------------------------------

        $codearr(defs)

        // ----------------------------------- www_{ino}_Cmd ----------------------------------


        static int
        ${c_cmd_name} (ClientData  clientData, Tcl_Interp *interp, int objc, Tcl_Obj * const objv[] ) {

            Tcl_Obj **global_objects = 
            (Tcl_Obj **) Tcl_GetAssocData(interp, ASSOC_DATA_KEY_go, NULL);

            #ifdef REUSE_DSTRING

            Tcl_DString *dsPtr = 
            (Tcl_DString *) Tcl_GetAssocData(interp, ASSOC_DATA_KEY_ds, NULL);

            DBG(fprintf(stderr,"dstring length after GetAssocData = %d\n",Tcl_DStringLength(dsPtr)));

            Tcl_DStringSetLength(dsPtr,0);

            #else

            Tcl_DString ds;
            Tcl_DString *dsPtr = &ds;
            Tcl_DStringInit(dsPtr);
            // EXPERIMENTAL - allocate a large initial buffer
            // Tcl_DStringSetLength(dsPtr,3*8192);
            // Tcl_DStringSetLength(dsPtr,0);

            #endif

            ${c_cmd_code}
        }


        static void 
        tdp_InitModule(Tcl_Interp *interp) {
            Tcl_Obj **global_objects = (Tcl_Obj **) Tcl_Alloc($codearr(global_strings_len) * sizeof(Tcl_Obj *));

            int i;
            for(i = 0; i < $codearr(global_strings_len); i++) 
            {
                global_objects[i] = Tcl_NewStringObj(global_strings[i],global_string_len[i]);
                Tcl_IncrRefCount(global_objects[i]);
            }

            Tcl_SetAssocData(interp, ASSOC_DATA_KEY_go, NULL, global_objects);

            #ifdef REUSE_DSTRING
            Tcl_DString *dsPtr = (Tcl_DString *) Tcl_Alloc(sizeof(Tcl_DString));
            Tcl_DStringInit(dsPtr);
            Tcl_SetAssocData(interp, ASSOC_DATA_KEY_ds, NULL, dsPtr);
            #endif

            Tcl_CreateObjCommand(interp, "${tcl_cmd_name}", $c_cmd_name, NULL, NULL);
        }



    }]
}


proc ::xo::tdp::compile_helper {codearrVar node procName} {

    upvar $codearrVar codearr

    if { ${procName} ni {deps initial_rewrite final_rewrite} } {
        error "compile_helper: procName must be 'deps' or 'initial_rewrite' or 'final_rewrite'"
    }

    set cmdName [$node @type]
    set cmd "::templating::tag::${cmdName}::${procName}"

    set result ""
    if { [info procs ${cmd}] ne {} } {
        if { [catch {
            set result [$cmd codearr $node]
        } errmsg options] } {

            array set options_arr $options

            set errorinfo $options_arr(-errorinfo)

            log error "\n--->>> cmd=$cmd \nnode=[$node nodeName] \nattributes=[$node attributes] \n\n \nerrmsg=$errmsg \n$errorinfo\n\n"

            error "cmd=$cmd node=[$node nodeName] attributes=[$node attributes]" $errorinfo

        }
    }
    return $result
}



proc ::xo::tdp::excludeClassesFromRenaming {selectors} {
    ::templating::css::keepCss ${selectors}
    foreach selector ${selectors} {
        set ::__CSS_EXCLUDE__(${selector}) 1
    }
}



