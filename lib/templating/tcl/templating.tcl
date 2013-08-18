
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


namespace eval ::templating {;}

proc ::templating::compile_and_load_all {dir} {
    set files [::util::findFiles $dir *.tdp]
    foreach filename $files {
	if { [catch {compile_and_load $filename} errMsg] } {
	    ns_log notice "failed to ::templating::compile_and_load $filename errMsg=$errMsg"
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
	    ::xo::kit::log "Error in C compiled page: errMsg=$errMsg"
	    rp_returnerror
	    return
	}
	ns_return 200 text/html ${html}
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
	ns_log notice "rendering took $duration milliseconds"
	
	#ns_return 200 text/html ${html}

    }
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
    ns_log notice "node1=[$node1 attributes] node2=[$node2 attributes]"

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
	set filelist [::util::findFiles [thisdir] *]

	# add the source file
	lappend filelist $inputfile

	# add file dependencies
	set depfile [get_build_rootname $inputfile].tdp_dep
	if { [file readable $depfile] } {
	    foreach filename [::util::readfile $depfile] {
		lappend filelist $filename
	    }
	}

	set mtime 0
	foreach filename $filelist {
	    if { [::util::newerFileThan $filename $mtime] } {
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

    set rootname [get_build_rootname $filename]
    set specfile ${rootname}.tdp_spec
    set xmlfile ${rootname}.tdp_xml
    set htmlfile ${rootname}.tdp_html
    set sharedlib [::xo::tdp::get_sharedlib $filename]
    set ininame [::xo::tdp::get_ininame $filename]


    set latest_mtime [latest_mtime $filename]
    if { [::xo::kit::performance_mode_p] && [file exists $sharedlib] } {
	if { [::util::newerFileThan $sharedlib $latest_mtime] } {
	    ns_log notice "--->>> load $sharedlib $ininame"
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
    # ns_log notice "--->>> (already loaded) unload $sharedlib"
    # unload $sharedlib
    # }



    ::xo::tdp::init_globals

    set doc [dom createDocument "html"]
    set root [$doc documentElement]
    if { [catch {$root appendFromScript "source $filename"} errMsg] } {
	$doc delete
	error $errMsg
	return
    } else {
	::util::writefile $specfile [$doc asHTML]
	::xo::tdp::compile_doc $doc $filename
    }


    ::util::writefile $xmlfile [::xo::tdp::as_xml $doc]

    ::util::writefile $htmlfile [$doc asHTML]
    $doc delete
    
    # we also explicitly set load=0 while calling cbuild


    # latest mtime may have changed because of the deps
    # get those names again, taking the new deps into consideration
    set sharedlib [::xo::tdp::get_sharedlib $filename]
    set ininame [::xo::tdp::get_ininame $filename]

    ns_log notice "--- (after compile) --->>> load $sharedlib $ininame"
    load $sharedlib $ininame
}

proc ::xo::tdp::next_other_id {} {
    variable widget_count

    return [::xo::html::obfuscate [incr widget_count]]
}

proc ::xo::tdp::compile_doc {templateDoc filename} {

    set rootname [get_build_rootname $filename]

    array set codearr [list \
			   build_rootname $rootname \
			   file $filename \
			   defs "" \
			   global_strings "" \
			   global_strings_len 0 \
			   macros ""]

    set ::__CSS_FILE__ [list]

    set start [clock milliseconds]


    # get widgets from dom tree
    set widgets [$templateDoc selectNodes {//widget}]

    # get some dependencies here, 
    # e.g. from master and include nodes, 
    # before we delete any widget
    set deps [list]
    foreach widget $widgets {
	set deps [concat ${deps} [::xo::tdp::compile_helper codearr $widget "deps"]]
    }


    set include_widgets [$templateDoc selectNodes {//widget[@type = 'include']}]
    foreach widget $include_widgets {

	if { [catch {::xo::tdp::compile_helper codearr $widget "initial_rewrite"} errmsg] } {
	    ::xo::kit::log "--->>>" \n\n errmsg=$errmsg \n\n widget=[$widget nodeName]
	}
	if { [$widget @__todelete "0"] } {
	    $widget delete
	}
    }

    ::util::writefile ${rootname}.tdp_spec_inc [$templateDoc asHTML]

    # initial rewrite
    #set sorted_widgets [lsort -command initial_rewrite_compare $widgets]
    set widgets [$templateDoc selectNodes {//widget}]
    foreach widget $widgets {
	if { [catch {::xo::tdp::compile_helper codearr $widget "initial_rewrite"} errmsg] } {
	    ::xo::kit::log "--->>>" \n\n errmsg=$errmsg \n\n widget=[$widget nodeName]
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
	    ::xo::kit::log "--->>>" \n\n errmsg=$errmsg \n\n widget=[$widget nodeName]
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


    # -------------------------- compile css -----------------------------------

    set css_min [::templating::css::compile_css codearr $templateDoc $filename rename_map seen]

    # -------------------------- compile js ------------------------------------

    set rootname [get_build_rootname $filename]
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

	exec "/bin/gzip -9 -c ${cdn_css_min_file} > ${cdn_css_min_file}.gz"

	set css_min_final_url [get_cdn_url "/css/${css_public_file}"]
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
		tpl -if "not @{val.registered_p}" {

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
		tpl -if "@{val.registered_p}" {

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
    ::xo::kit::log "compiled tdp file ($filename) in ${duration}ms"

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

    set rootname [get_build_rootname $filename]
    set c_file ${rootname}.tdp_c
    ::util::writefile $c_file $c_code

    set init_code [subst -nocommands -nobackslashes {

	// init_text
	DBG(fprintf(stderr,"templating initializing... $tcl_cmd_name\n"));

	RegisterExitHandlers(ip); // interp
	tdp_InitModule(ip);

    }]

    ::critcl::reset
    #::critcl::cflags "-Wall -pedantic"
    if { [::xo::kit::debug_mode_p] } { 
	::critcl::debug all
    }
    ::critcl::config outdir [get_outdir $filename]
    ::critcl::clibraries -L/opt/naviserver/lib -lnsd
    ::critcl::config I /opt/naviserver/include
    ::critcl::ininame [::xo::tdp::get_ininame $filename]
    ::critcl::cinit $init_code {
	// init_exts
    } $filename
    
    ::critcl::ccode $c_code $filename

    set base [get_base_rootname $filename]
    set load 0
    set pretend_load 1
    lassign [::critcl::cbuild ${filename} ${load} "" "" ${pretend_load} ${base}] libfile ininame

    set dir [file dirname ${rootname}]
    set tailname [file tail ${rootname}]
    set tarfile ${rootname}.tar.bz2
    set filelist [lsearch -all -inline -not \
		      [glob -directory ${dir} -type f -tails ${tailname}.*] \
		      [file tail ${tarfile}]]

    exec "/bin/tar --directory ${dir} -cjf ${tarfile} ${filelist}"

}

proc exists_indexed_script {codearrVar script {refVar ""}} {
    upvar $codearrVar codearr

    if { $refVar ne {} } {
	upvar $refVar ref
    }


    set md5_hex [::util::md5_hex ${script}]
    set ref [get_value_if codearr(script,${md5_hex}) ""]

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


proc ::xo::tdp::compile_to_c_helper {codearrVar templateDoc} {

    upvar $codearrVar codearr

    set htmlDoc $templateDoc

    set codearr(index) 1
    set widgets [$htmlDoc selectNodes {//widget}]
    #set widgets [lsort -command compareNodes $widgets]
    foreach widget $widgets {
	if { [$widget @skip "0"] } continue
	set cmdName [$widget @type]

	#ns_log notice "type=$cmdName id=[$widget @id ""]"

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

    set noroot [get_value_if codearr(pragma.noroot) "0"]
    set doctype [get_value_if codearr(pragma.doctype) ""]

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

    set c_global_strings [join [::xo::fun::map x $codearr(global_strings) {::util::cstringquote_escape_newlines $x}] ",\n\t\t"]

    set c_global_strings_len_arr [join [::xo::fun::map x $codearr(global_strings) {string bytelength $x}] {,}]



    set mime_type [get_value_if codearr(pragma.mime_type) "text/html"]

    set c_cmd_code [subst -nocommands -nobackslashes {

	${result}

	// TODO-HERE
	#ifdef 0
	Ns_Conn *conn = Ns_GetConn();
	const int status = 200;
	const char type[] = "${mime_type}";
	int len = Tcl_DStringLength(dsPtr);
	const char *data = Tcl_DStringValue(dsPtr);
	DBG(fprintf(stderr,"page size/length=%d\n",len));
	int result = Ns_ConnReturnCharData(conn, status,data,len,type);
	#endif

	return Result(interp,result);

    }]

    if { [get_value_if codearr(pragma.debug) "0"] } {
	append codearr(macros) "\n" "#define DEBUG"
    }

    if { [get_value_if codearr(pragma.reuse_dstring) "0"] } {
	append codearr(macros) "\n" "#define REUSE_DSTRING"
    }

    set data_object_type [::templating::config::get_option "data_object_type"]
    if { $data_object_type eq {NSF} } {
	append codearr(macros) "\n" "#define USE_NSF"
    }	

    return [subst -nocommands -nobackslashes {
	#include "tcl.h"
	#include "ns.h"

	#define TDP_ERROR TCL_ERROR
	#define TDP_OK    TCL_OK
	#define TDP_ABORT TCL_RETURN

	#define BOOL_LITERAL_false 0
	#define BOOL_LITERAL_true  1
	#define BOOL_LITERAL_off   0
	#define BOOL_LITERAL_on    1

	$codearr(macros)

	/*----------------------------------------------------------------------------
	|   Debug Macros
	|
	\---------------------------------------------------------------------------*/
	#ifdef DEBUG
	# define DBG(x) x
	#else
	# define DBG(x) 
	#endif

	#ifdef REUSE_DSTRING
	# define DSTRING_FREE(x)
	#else
	# define DSTRING_FREE(x) Tcl_DStringFree((x))
	#endif

	static const char *const global_strings[] = { 
	    $c_global_strings 
	};

	static const int global_string_len[] = {
	    $c_global_strings_len_arr
	};


	static inline int tdp_ReturnBlank() {
	    Ns_Conn *connPtr = (Ns_Conn *) Ns_GetConn();
	    if (connPtr->flags & NS_CONN_CLOSED) {
		DBG(fprintf(stderr,"NS_CONN_CLOSED, likely a redirect, do nothing\n"));
		return TCL_OK;
	    } else {
		return Ns_ConnReturnNotice(connPtr, 204, "No Content", NULL);
	    }
	}


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

	static void
	ExitHandler(ClientData clientData) {
	    Tcl_Interp *interp = (Tcl_Interp *) clientData;
	    tdp_cleanup(interp);
	    Tcl_Release(interp);
	}

	static void
	tdp_ThreadExitProc(ClientData clientData) {
	    void tdp_ExitProc(ClientData clientData);
	    Tcl_DeleteExitHandler(tdp_ExitProc, clientData);
	    ExitHandler(clientData);
	}

	void
	tdp_ExitProc(ClientData clientData) {
	    Tcl_DeleteThreadExitHandler(tdp_ThreadExitProc, clientData);
	    ExitHandler(clientData);
	}

	static void
	RegisterExitHandlers(ClientData clientData) {
	    Tcl_Preserve(clientData);
	    Tcl_CreateThreadExitHandler(tdp_ThreadExitProc, clientData);
	    Tcl_CreateExitHandler(tdp_ExitProc,clientData);
	}


	// ----------------------------------- auxiliary ----------------------------------------


	int strcmp_eq(const char *s1, const char *s2) {
	    return 0 == strcmp(s1,s2);
	}

	int strcmp_ne(const char *s1, const char *s2) {
	    return 0 != strcmp(s1,s2);
	}

	int intcmp_eq(int x, int y) {
	    return x==y;
	}

	int intcmp_ne(int x, int y) {
	    return x!=y;
	}

	const char *getstr(Tcl_Obj *objPtr) {
	    return Tcl_GetString(objPtr);
	}


	/* fetch value from "::__data__" array */
	static
	Tcl_Obj *getvar_0 /* tclvar */ (Tcl_Interp *interp, Tcl_Obj **global_objects, Tcl_Obj *const objPtr, Tcl_Obj *const objPtr2) {
	    return Tcl_ObjGetVar2(interp,objPtr,objPtr2,TCL_GLOBAL_ONLY);
	}


	#ifdef USE_NSF
	/* fetch value from xotcl object */
	static
	Tcl_Obj *getvar_1 /* nsfvar */ (Tcl_Interp *interp, Tcl_Obj **global_objects, Tcl_Obj *const objPtr1, Tcl_Obj *const objPtr2) {

	    Tcl_IncrRefCount(objPtr1);
	    Tcl_IncrRefCount(objPtr2);

	    Tcl_Obj *const objv[] = { 
		global_objects[OBJECT_NSF_VAR_SET], 
		objPtr1, 
		objPtr2 
	    };

	    if ( TCL_ERROR == Tcl_EvalObjv(interp, 3, objv, TCL_EVAL_GLOBAL) ) {
		Tcl_DecrRefCount(objPtr1);
		Tcl_DecrRefCount(objPtr2);
		return NULL;
	    }

	    Tcl_DecrRefCount(objPtr1);
	    Tcl_DecrRefCount(objPtr2);

	    return Tcl_DuplicateObj(Tcl_GetObjResult(interp));
	}
	#else
	/* fetch value from TCL dictionary */
	static
	Tcl_Obj *getvar_1 /* dict_elem_var */ (Tcl_Interp *interp, Tcl_Obj **global_objects, Tcl_Obj *const dictPtr, Tcl_Obj *const keyPtr) {

	    Tcl_Obj *valuePtr;
	    if (TCL_ERROR == Tcl_DictObjGet(interp,dictPtr,keyPtr,&valuePtr)) {
		DBG(fprintf(stderr,"DictObjGet error"));
		return NULL;
	    }
	    return valuePtr;
	}
	#endif


	static
	void append_quoted_html(Tcl_DString *dsPtr, const char *string, int length) {
	    while (length--) {
		switch (*string) {
		    case '<':
		    Tcl_DStringAppend(dsPtr, "&lt;",4);
		    break;

		    case '>':
		    Tcl_DStringAppend(dsPtr, "&gt;",4);
		    break;

		    case '&':
		    Tcl_DStringAppend(dsPtr, "&amp;",5);
		    break;

		    case '\'':
		    Tcl_DStringAppend(dsPtr, "&#39;",5);
		    break;

		    case '"': /* '" */
		    Tcl_DStringAppend(dsPtr, "&#34;",5);
		    break;
            
		    default:
		    Tcl_DStringAppend(dsPtr, string, 1);
		    break;
		}
		++string;
	    }
	}

	/* append value from "::__data__" array */
	static
	void append_0 /* tclvar */ (Tcl_Interp *interp, Tcl_Obj **global_objects, Tcl_Obj *objPtr1, Tcl_Obj *objPtr2, Tcl_DString *dsPtr, int noquote) {

	    if (!objPtr1 || !objPtr2)  return;

	    Tcl_Obj *objPtr = Tcl_ObjGetVar2(interp,objPtr1,objPtr2,TCL_GLOBAL_ONLY);
	    if (objPtr) {
		int length;
		const char *bytes = Tcl_GetStringFromObj(objPtr,&length);
		if (noquote) 
		  Tcl_DStringAppend(dsPtr,bytes,length);
		else
		  append_quoted_html(dsPtr,bytes,length);
	    }

	    // if (error) Tcl_DStringAppend(dsPtr,"-ERROR-",7);
	}

	#ifdef USE_NSF
	/* append value from xotcl object to dsPtr */
	static
	void append_1 /* nsfvar */ (Tcl_Interp *interp, Tcl_Obj **global_objects, Tcl_Obj *const objPtr1, Tcl_Obj *const objPtr2, Tcl_DString *const dsPtr, int noquote) {
	    Tcl_IncrRefCount(objPtr1);
	    Tcl_IncrRefCount(objPtr2);

	    Tcl_Obj *const objv[] = { global_objects[OBJECT_NSF_VAR_SET], objPtr1, objPtr2 };

	    if ( TCL_ERROR == Tcl_EvalObjv(interp, 3, objv, TCL_EVAL_GLOBAL) ) {
		Tcl_DecrRefCount(objPtr1);
		Tcl_DecrRefCount(objPtr2);
		return;
	    }

	    int length;
	    const char *bytes = Tcl_GetStringFromObj(Tcl_GetObjResult(interp),&length);
	    if (noquote) 
	      Tcl_DStringAppend(dsPtr,bytes,length);
	    else
	      append_quoted_html(dsPtr,bytes,length);


	    Tcl_DecrRefCount(objPtr1);
	    Tcl_DecrRefCount(objPtr2);
	}
	#else
	/* append value from TCL dictionary to dsPtr */
	static
	void append_1 /* dict_elem_var */ (Tcl_Interp *interp, Tcl_Obj **global_objects, Tcl_Obj *const dictPtr, Tcl_Obj *const keyPtr, Tcl_DString *const dsPtr, int noquote) {

	    Tcl_Obj *valuePtr;
	    if (TCL_ERROR == Tcl_DictObjGet(interp,dictPtr,keyPtr,&valuePtr)) {
		DBG(fprintf(stderr,"DictObjGet error in append_1"));
		return NULL;
	    }

	    int length;
	    const char *bytes = Tcl_GetStringFromObj(valuePtr,&length);
	    if (noquote) 
	      Tcl_DStringAppend(dsPtr,bytes,length);
	    else
	      append_quoted_html(dsPtr,bytes,length);

	}
	#endif


	static
	void append_obj(Tcl_Obj *objPtr, Tcl_DString *dsPtr, int noquote) {
	    int length;
	    const char *bytes = Tcl_GetStringFromObj(objPtr,&length);
	    if (noquote) 
	      Tcl_DStringAppend(dsPtr,bytes,length);
	    else
	      append_quoted_html(dsPtr,bytes,length);
	}

	static
	void append_obj_element(Tcl_Interp *interp,Tcl_Obj *objPtr, int index, Tcl_DString *dsPtr, int noquote) {
	    Tcl_Obj *elemPtr;
	    Tcl_ListObjIndex(interp,objPtr,index,&elemPtr);
	    if (!elemPtr) {
		// TODO: possibly raise error
		return;
	    }
	    int length;
	    const char *bytes = Tcl_GetStringFromObj(elemPtr,&length);
	    if (noquote) 
	      Tcl_DStringAppend(dsPtr,bytes,length);
	    else
	      append_quoted_html(dsPtr,bytes,length);
	}

	static
	Tcl_Obj *getvar_obj_element(Tcl_Interp *interp,Tcl_Obj *objPtr, int index) {
	    Tcl_Obj *elemPtr;
	    Tcl_ListObjIndex(interp,objPtr,index,&elemPtr);
	    if (!elemPtr) {
		// TODO: possibly raise error
		return;
	    }
	    return elemPtr;
	}

	static
	int getint_0 /* tclvar */ (Tcl_Interp *interp, Tcl_Obj **global_objects, Tcl_Obj *part1Ptr, Tcl_Obj *part2Ptr) {


	    Tcl_Obj *objPtr = Tcl_ObjGetVar2(interp,part1Ptr,part2Ptr,TCL_GLOBAL_ONLY);
	    // TODO: check if objPtr is null
	    if (!objPtr) {
		DBG(fprintf(stderr,"getint_0 / tclvar / error\n"));
	    }
	    Tcl_IncrRefCount(objPtr);


	    int intValue;
	    if (TCL_OK != Tcl_GetIntFromObj(interp,objPtr,&intValue)) {
		// return TCL_ERROR;
		Tcl_DecrRefCount(objPtr);
		return 0;
	    }

	    Tcl_DecrRefCount(objPtr);
	    return intValue;
	}

	static
	int getint_1 /* nsfvar */ (Tcl_Interp *interp, Tcl_Obj **global_objects, Tcl_Obj *part1Ptr, Tcl_Obj *part2Ptr) {

	    Tcl_Obj *objPtr = getvar_1 /* nsfvar */ (interp,global_objects,part1Ptr,part2Ptr);
	    // TODO: check if objPtr is null
	    if (!objPtr) {
		DBG(fprintf(stderr,"getint_1 / nsfvar / error\n"));
	    }
	    Tcl_IncrRefCount(objPtr);

	    int intValue;
	    if (TCL_OK != Tcl_GetIntFromObj(interp,objPtr,&intValue)) {
		// return TCL_ERROR;
		Tcl_DecrRefCount(objPtr);
		return 0;
	    }

	    Tcl_DecrRefCount(objPtr);
	    return intValue;

	}

	static
	int getint_2 /* tclobj */ (Tcl_Interp *interp, Tcl_Obj *objPtr) {
	    if (!objPtr) {
		// TODO: raise error somehow, use 'goto' perhaps?
		return 0;
	    }

	    int intValue;
	    if (TCL_OK != Tcl_GetIntFromObj(interp,objPtr,&intValue)) {
		// return TCL_ERROR;
		return 0;
	    }
	    return intValue;
	}

	static
	int getbool_0 /* tclvar */ (Tcl_Interp *interp, Tcl_Obj **global_objects, Tcl_Obj *part1Ptr, Tcl_Obj *part2Ptr) {


	    Tcl_Obj *objPtr = Tcl_ObjGetVar2(interp,part1Ptr,part2Ptr,TCL_GLOBAL_ONLY);
	    // TODO: check if objPtr is null
	    if (!objPtr) {
		DBG(fprintf(stderr,"getbool_0 / tclvar / error\n"));
	    }
	    Tcl_IncrRefCount(objPtr);

	    int boolValue;
	    if (TCL_OK != Tcl_GetBooleanFromObj(interp,objPtr,&boolValue)) {
		// return TCL_ERROR;
		Tcl_DecrRefCount(objPtr);
		return 0;
	    }

	    Tcl_DecrRefCount(objPtr);
	    return boolValue;

	}

	static
	int getbool_1 /* nsfvar */ (Tcl_Interp *interp, Tcl_Obj **global_objects, Tcl_Obj *part1Ptr, Tcl_Obj *part2Ptr) {

	    Tcl_Obj *objPtr = getvar_1 /* nsfvar */ (interp,global_objects,part1Ptr,part2Ptr);
	    // TODO: check if objPtr is null
	    if (!objPtr) {
		DBG(fprintf(stderr,"getbool_1 / nsfvar / error\n"));
		return 0;
	    }
	    Tcl_IncrRefCount(objPtr);

	    int boolValue;
	    if (TCL_OK != Tcl_GetBooleanFromObj(interp,objPtr,&boolValue)) {
		// return TCL_ERROR;
		Tcl_DecrRefCount(objPtr);
		return 0;
	    }

	    Tcl_DecrRefCount(objPtr);
	    return boolValue;

	}

	int getbool_2 /* tclobj */ (Tcl_Interp *interp, Tcl_Obj *objPtr) {
	    if (!objPtr) {
		// TODO: raise error somehow, use 'goto' perhaps?
		return 0;
	    }

	    int boolValue;
	    if (TCL_OK != Tcl_GetBooleanFromObj(interp,objPtr,&boolValue)) {
		// return TCL_ERROR;
		return 0;
	    }
	    return boolValue;
	}


	// ----------------------------------- widgets ----------------------------------------

	$codearr(defs)

	// ----------------------------------- www_{ino}_Cmd ----------------------------------


	static int
	Result(Tcl_Interp *interp, int result)
	{
	    Tcl_SetObjResult(interp, Tcl_NewBooleanObj(result == TCL_OK ? 1 : 0));
	    return TCL_OK;
	}

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
	if { [catch {set result [$cmd codearr $node]} errMsg] } {
	    ns_log error "--->>> cmd=$cmd node=[$node nodeName] attributes=[$node attributes] \n\n errMsg=$errMsg \n\n"
	}
    }
    return $result
}


proc ::xo::tdp::get_build_rootname {filename} {

    set rootname [file rootname $filename]
    set root_dir [acs_root_dir]
    set root_dir_len [string length $root_dir]
    set prefix_dir_of_rootname [string range $rootname 0 [expr {$root_dir_len - 1}]]
    if { $prefix_dir_of_rootname eq $root_dir } {
	set rootname [string range $rootname [expr { $root_dir_len + 1 }] end]
    }

    set build_dir /web/data/build
    set build_rootname ${build_dir}/${rootname}
    if { ![file isdirectory [file dirname $build_rootname]] } {
	file mkdir [file dirname $build_rootname]
    }

    return ${build_rootname}
}

proc ::xo::tdp::get_base_rootname {filename} {
    set build_rootname [get_build_rootname $filename]
    return ${build_rootname}.[::xo::kit::performance_mode_p].[::util::ino $filename].[latest_mtime $filename]
}


proc ::xo::tdp::get_outdir {filename} {
    return [file dirname [get_build_rootname $filename]]
    #return /web/local-data/critcl
}

proc ::xo::tdp::get_ininame {filename} {
    set mode [::xo::kit::performance_mode_p]
    set ino [::util::ino $filename]
    set rootname [file rootname [file tail $filename]]
    set ininame [string totitle [string map {"-" "_"} $rootname]]_${mode}_${ino}
    #set ininame [string totitle [string map {"-" "_"} $rootname]]
    return ${ininame}
}


proc ::xo::tdp::get_sharedlib {filename} {
    set sharedlibext [info sharedlibextension]
    return [get_base_rootname $filename]${sharedlibext}
}



proc ::xo::tdp::excludeClassesFromRenaming {selectors} {
    ::templating::css::keepCss ${selectors}
    foreach selector ${selectors} {
	set ::__CSS_EXCLUDE__(${selector}) 1
    }
}



