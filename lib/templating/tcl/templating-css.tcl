namespace eval ::templating::css {;}

proc ::templating::css::cssId {name} {

    if {[info exists ::__CSS_EL__(${name})]} {
	return $::__CSS_EL__(${name})
    }
    return [set ::__CSS_EL__(${name}) [::xo::html::obfuscate [incr ::__CSS_ID__]]]
}

proc ::templating::css::keepCss {selectors} {
    foreach selector ${selectors} {
	set ::__CSS_KEEP__(${selector}) 1
    }
}

proc ::templating::css::cssClassesToKeep {} {
    return [array names ::__CSS_KEEP__]
}

proc ::templating::css::excludedClassesFromRenaming {} {
    return [array names ::__CSS_EXCLUDE__]
}
proc ::templating::css::excludedClassesCmdString {} {
    set cssClasses [excludedClassesFromRenaming]
    set excluded_classes_string ""
    foreach cssClass $cssClasses {
	append excluded_classes_string " --excluded-classes-from-renaming ${cssClass} "
    }
    return $excluded_classes_string
}

proc ::templating::css::setCssNameMapping {selectors rename_mapVar} {

    upvar $rename_mapVar rename_map

    set result [list]
    foreach selector ${selectors} {
	if { [info exists rename_map($selector)] } {
	    set newselector $rename_map($selector)
	} else {
	    set newselector [cssId $selector]
	}
	lappend result "'${selector}':'${newselector}'"

	# keep renamed selector that was specifically asked to be kept via 'names' attr of js
	# but may not appear in the html
	keepCss $newselector

    }
    return "xo.setCssNameMapping(\{[join ${result} {,}]\});"
}


proc ::templating::css::compile_css {codearrVar templateDoc template_file rename_mapVar seenVar} {

    upvar $codearrVar codearr
    upvar $rename_mapVar rename_map
    upvar $seenVar seen

    # rewrite ids and classes based on the output of closure-stylesheets
    set css ""
    array set seen_file [list]
    foreach file $::__CSS_FILE__ {
	if { ![info exists seen($file)] } {
	    append css [::util::readfile $file]
	    set seen_file($file) 1
	}
    }
    set style_nodes [${templateDoc} selectNodes {//style[@type='text/css']}]
    foreach node $style_nodes {
	append css [$node text]
	$node delete
    }

    # google stylesheets fails when it comes across backslashes
    set re {(\s*[^\\]+\\9\s*;\s*)}
    set css [removeComments [regsub -line -all -- $re $css "/*\\1*/"]]

    set re {\.[a-z][a-z0-9\-]+[a-z0-9]}
    set all_css_classes [lsort -unique [regexp -nocase -inline -all -- $re $css]]

    #::xo::kit::log all_css_classes=$all_css_classes

    # add alternate directive
    set new_css ""
    set parts [split $css "\{\}"]
    foreach {selectors rule_body} $parts {
	if { [string trim $selectors] eq {} || [string trim $rule_body] eq {} } continue 
	if { [string index [string trimleft $selectors] 0] eq {@} } {
	    # TODO: google-closure-stylesheets does not seem to handle this kind of directives
	    continue
	    set new_rule_body $rule_body
	} else {
	    set rule_lines [split $rule_body {;}]
	    array set seen_css_property [list]
	    set new_rule_lines ""
	    foreach rule_line $rule_lines {
		lassign [split $rule_line {:}] rule_property rule_property_value
		set rule_property [string trim $rule_property]
		if { [info exists seen_css_property($rule_property)] } {
		    lappend new_rule_lines "/* @alternate */ $rule_line"
		} else {
		    lappend new_rule_lines $rule_line
		}
		set seen_css_property($rule_property) 1
	    }
	    array unset seen_css_property
	}
	set new_rule_body [join $new_rule_lines {;}]
	append new_css [expand_selectors all_css_classes $selectors] " \{" ${new_rule_body} "\}\n"
    }
    set css $new_css


    set rootname $codearr(build_rootname)
    set css_input_file ${rootname}.tdp_css
    set css_output_file ${rootname}.tdp_css_min
    set css_map_file ${rootname}.tdp_css_map
    if { [file exists $css_output_file] } {
	file delete -force -- $css_output_file
	file delete -force -- $css_map_file
    }
    ::util::writefile $css_input_file $css
    ::util::writefile ${rootname}.tdp_css_keep [cssClassesToKeep]

    set excluded_classes_from_renaming [excludedClassesCmdString]

    set cmd "/usr/bin/java -jar /web/files/closure/closure-stylesheets-20111230.jar ${css_input_file} --output-file ${css_output_file} --output-renaming-map ${css_map_file} ${excluded_classes_from_renaming} --allow-unrecognized-functions --allow-unrecognized-properties --rename CLOSURE --output-renaming-map-format PROPERTIES"

    exec ${cmd}
    if { ![file exists $css_output_file] } {
	error "css compilation failed"
    }

    array set rename_map [string map {{=} { }} [::util::readfile $css_map_file]]

    # we used to call rename_doc_classes from here

    set css_min [::util::readfile $css_output_file]
    return $css_min

}





proc replace_css_url {codearrVar textVar} {
    upvar $codearrVar codearr

    upvar $textVar text

    # ns_log notice replace_css_url=$text

    # TODO: if http url, fetch the file from the web

    set filename [file normalize [acs_root_dir]/www/${text}]

    if { [file readable $filename] } {
	set ext [file extension ${text}]
	set md5_hex [::util::md5_hex ${filename}]
	set img_public_file ${md5_hex}${ext}
	set targetfile [get_img_dir]/${img_public_file}
	if { ![file exists $targetfile] || [::util::newerFile $filename $targetfile] } {
	    file copy -force $filename $targetfile
	}
	return url([get_cdn_url "/img/${img_public_file}"])
    }

    return url($text)
}


proc ::templating::css::rename_doc_classes {templateDoc rename_mapVar seenVar} {

    upvar $rename_mapVar rename_map
    upvar $seenVar seen

    set ::__CSS_ID__ [llength [array names rename_map]]

    #::xo::kit::log rename_map=[array get rename_map]


    # TODO: in css_valid_selector, create xpath from selector and search templateDoc
    # if not found, return 0, otherwise 1
    array set seen [list]
    foreach domNode [${templateDoc} selectNodes {//*}] {
	set tagName [$domNode tagName]
	set seen(${tagName}) 1
    }


    foreach domNode [${templateDoc} selectNodes {//*[@class or @id or (local-name()='label' and @for)]}] {
	set tagName [$domNode tagName]
	if { ${tagName} eq {widget} } continue

	set seen(${tagName}) 1
	set cssClasses [$domNode @class ""]
	if { $cssClasses ne {} } {
	    set newCssClasses [list]
	    foreach cls $cssClasses {
		set new_cls_keywords [list]
		foreach keyword [split $cls {-}] {
		    if { ![info exists rename_map(${keyword})] } {
			lappend new_cls_keywords $keyword
			#lappend newCssClasses ${new_cls_keyword}
		    } else {
			lappend new_cls_keywords $rename_map(${keyword})
			#lappend newCssClasses $new_cls
		    }
		}
		set new_cls [join $new_cls_keywords {-}]
		lappend newCssClasses $new_cls
		set seen(.${new_cls}) 1
		set seen("${tagName}.${new_cls}") 1
	    }
	    if { $newCssClasses ne {} } {
		$domNode setAttribute class $newCssClasses
	    } else {
		$domNode removeAttribute class
	    }
	    
	    if { 0 && [::xo::kit::debug_mode_p] } {
		$domNode setAttribute oldClass $cssClasses
	    }
	}
    }
}



proc ::templating::css::optimize_css {codearrVar templateDoc template_file css_min seenVar} {

    upvar $codearrVar codearr

    upvar $seenVar seen

    set dropped_css ""
    set new_css_min ""
    set parts [split $css_min "\{\}"]
    foreach {selectors rule_body} $parts {
	set new_selectors [list]
	foreach selector [split $selectors {,}] {
	    if { [css_valid_selector $templateDoc $selector seen] } {
		lappend new_selectors $selector
	    } else {
		append dropped_css "\n" ${selector} "\{" ${rule_body} "\}"
	    }
	}
	if { $new_selectors ne {} } {
	    append new_css_min [join $new_selectors {,}] "\{" ${rule_body} "\}"
	}
    }

    set re {url\(([^\)]+)\)}
    set new_css_min [while_re codearr $re new_css_min replace_css_url count]


    set rootname $codearr(build_rootname)
    set css_output_file ${rootname}.tdp_css_min_final
    ::util::writefile ${css_output_file} $new_css_min

    if { ${dropped_css} ne {} } {
	set css_dropped_file ${rootname}.tdp_css_min_dropped
	::util::writefile ${css_dropped_file} $dropped_css
    }


    return $new_css_min

}

proc css_valid_selector {templateDoc selector seenVar} {

    global __CSS_KEEP__

    upvar $seenVar seen

    # add spaces around special symbols
    set re {([+<>])}
    set selector [regsub -all -- $re $selector { \1 }]

    # .corner.top.right => .corner .top .right
    set re {([.])}
    set selector [string trim [regsub -all -- $re $selector { \1}]]

    foreach keyword $selector {

	if { [regexp -- {input\[type=\"([\w]+)\"\]} $keyword whole submatch] } {
	    set x [$templateDoc selectNodes "//input\[@type='${submatch}'\]"]
	    if { $x ne {} } {
		continue
	    }
	}

	set keyword [lindex [split $keyword {:}] 0]
	if { [info exists seen($keyword)] } {
	    continue
	}

	if { [info exists __CSS_KEEP__(${keyword})] 
	     || [info exists __CSS_KEEP__([string trimleft $keyword ".\#"])] } {
	    continue
	}

	set firstChar [string index $keyword 0]
	if { $firstChar eq {.} } {
	    # css classes found are in the 'seen' or '__CSS_KEEP__' array, return 0
	    return 0
	} elseif { $firstChar eq "\#" || $firstChar eq {>} || $firstChar eq {<} || $firstChar eq {+} } {
	    continue
	} else {
	    if { [string is alpha $keyword] } {
		set nodes [$templateDoc selectNodes //${keyword}]
		if { $nodes ne {} } {
		    set seen($keyword) 1
		    continue
		} else {
		    #::xo::kit::log not_found_keyword=$keyword
		    return 0
		}
	    } else {
		return 0
	    }
	}
    }
    return 1
}

proc removeComments { text {replacement ""} } {
    regsub -all {[/][*].*?[*][/]} $text ${replacement} text
    return $text
}

proc expand_selectors {cssClassesVar selectors} {

    upvar $cssClassesVar cssClasses

    set new_selectors ""
    # 1. find class*="something"
    # 2. rewrite selectors according to all cssClasses matching 'something'

    set re {\[class[\*\^]="([a-zA-Z_]+[a-zA-Z0-9_\-]*)"\]}
    set parts [split $selectors {,}]
    foreach selector $parts {
	set matches [regexp -inline -indices -all -- $re $selector]
	if { $matches ne {} } {
	    #::xo::kit::log matches=$matches
	    set list_of_lists [list]
	    foreach {match_range submatch_range} $matches {
		lassign $match_range match_start match_end
		lassign $submatch_range submatch_start submatch_end
		set op [string index $selector [expr {$match_start + 6}]]
		set submatch [string range $selector $submatch_start $submatch_end]
		set pattern "*${submatch}*"
		#::xo::kit::log op=$op
		if { $op eq {*} } {
		    set class_names [lsearch -all -inline -glob $cssClasses $pattern]
		} elseif { $op eq {^} } {
		    set class_names [lsearch -all -inline -glob $cssClasses $pattern]
		} else {
		    ::xo::kit::log "unknown operator, supported for now is class*= and class^="
		}
		lappend list_of_lists $class_names
	    }
	    #::xo::kit::log list_of_lists=$list_of_lists
	    # TODO: rewrite selector according to cartesian product of list_of_lists
	    if { 1 == [llength $list_of_lists] } {
		foreach class_names $list_of_lists {match_range submatch_range} $matches {
		    lassign $match_range match_start match_end
		    foreach class_name $class_names {
			lappend new_selectors [string trim [string replace $selector $match_start $match_end $class_name]]
		    }
		}
	    } else {
		## TODO: not implemented yet, when we have multiple patterns in a selector
		#lappend new_selectors $selector
		lappend new_selectors $selector
	    }
	    #::xo::kit::log new_selectors=[join $new_selectors {, }]
	} else {
	    lappend new_selectors $selector
	}
    }
    return [join $new_selectors {, }]
}
