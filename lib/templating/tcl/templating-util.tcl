namespace eval ::templating::util {;}

proc ::templating::util::dict_get {dictionaryValue key} \
    "return \[[::templating::config::dict_get_cmd] \${dictionaryValue} \${key}\]"




  # ouch, some md5 implementations return hex, others binary
if {[string length [md5 ""]] == 32} {
    proc ::util::md5_hex {s} { return [md5 ${s}] }
} else {
    proc ::util::md5_hex {s} { binary scan [md5 ${s}] H* md; return ${md} }
}


proc ::util::cstringquote {str} {
    return [::util::doublequote "[string map {"\\" {\\}} ${str}]\\n"]
}

proc ::util::cstringquote_escape_newlines {str {lengthVar ""}} {

    if { $lengthVar ne {} } {
	upvar $lengthVar length
	set length [string bytelength ${str}]
    }

    set quoted_string [::util::doublequote [string map {"\n" {\n} "\r" {\r} "\\" {\\}} ${str}]]

    return ${quoted_string}
}

proc ::util::multiline_cstringquote {str} {
    return [map x [split $str "\n"] {::util::cstringquote "${x}"}]
}

proc ::util::localtime {{format "%A, %d %B %Y, %H:%M %Z"}} {
    return [clock format [clock seconds] -format ${format}]
    # return [ClockMgr getLocalTime -format $format]
}


proc tclcode_to_cstring {tclcode} {
    if { $tclcode eq {} } {
	return \"\"
    } else {
	return "[join [::util::multiline_cstringquote $tclcode] "\n\t\t"]"
    }
}

namespace eval ::templating::util {;}




# --------------------- used mainly by datastore -------------------------

proc transform_refs_getter {codearrVar varname_expr} {

    upvar $codearrVar codearr

    set parts [split ${varname_expr} {:}]
    set num_parts [llength ${parts}]

    if { ${num_parts} == 1 } {

	return "\$::__data__(${varname_expr})"

    } elseif { ${num_parts} == 2 } {

	lassign ${parts} part1 part2

	if { ${part2} eq {rowcount} } {

	    # part1 needs to be a datastore
	    set varname ${part1}
	    if { ![exists_global_string codearr "OBJECT_VARNAME_${varname}"] } {
		error "transform_refs_helper (store:rowcount): no such identifier '${varname}'"
	    }

	    return \$::__data__(${varname},rowcount)

	} elseif { ${part2} eq {varname} } {

	    # return varname, not a substitution
	    return ::__data__(${part1})

	} elseif { ${part2} eq {trim} } {

	    return "\[string trim \$::__data__(${part1})\]"

	} elseif { ${part2} eq {length} } {

	    return "\[string length \$::__data__(${part1})\]"

	}  elseif { ${part2} eq {llength} } {

	    return "\[llength \$::__data__(${part1})\]"

	} else {

	    error "do not know what to do with varname_expr=${varname_expr}"

	}

    } else {

	error "do not know what to do with varname_expr=${varname_expr}"

    }

}

proc transform_refs_helper {codearrVar textVar} {

    upvar $codearrVar codearr

    upvar $textVar text

    set parts [split $text .]
    set numparts [llength $parts]
    if { $numparts == 1 } {

	return [transform_refs_getter codearr ${text}]

    } elseif { $numparts == 2 } {

	lassign $parts part1 part2

	if { $part1 eq {val} || $part1 eq {param} || $part1 eq {top} } {

	    return [transform_refs_getter codearr ${part2}]

	} elseif { $part2 eq {parent} } {

	    # do nothing, let if fail

	} elseif { $part2 eq {proc} } {

	    # do nothing, let it fail

	} else {

	    # part1 needs to be an nsf object, e.g. a singleton datastore or the result of processing
	    set varname ${part1}
	    if { ![exists_global_string codearr "OBJECT_VARNAME_${varname}"] } {
		error "transform_refs_helper (object.property): no such identifier '${varname}'"
	    }

	    # nsf::var::set or dict get
	    set dict_get_cmd [::templating::config::dict_get_cmd]
	    return "\[${dict_get_cmd} \$::__data__(${part1}) ${part2}\]"

	}

    } elseif { $numparts == 3 } {

	lassign $parts part1 part2 part3

	if { $part1 eq {object_get} } {

	    # part1 needs to be an nsf object, e.g. a singleton datastore or the result of processing
	    set varname ${part2}
	    if { ![exists_global_string codearr "OBJECT_VARNAME_${varname}"] } {
		error "tranforms_refs_helper (object_get.object.property): no such identifier '${varname}'"
	    }

	    # nsf::var::set or dict get
	    set dict_get_cmd [::templating::config::dict_get_cmd]
	    return "\[${dict_get_cmd} \$::__data__(${part2}) ${part3}\]"
	} else {

	    error "no such thing ${text}"

	}

    }

}

proc transform_refs {codearrVar text {countVar ""}} {
    upvar $codearrVar codearr

    if { $countVar ne {} } {
	upvar $countVar count
    }
    set re {@\{([a-zA-Z_][a-zA-Z_0-9\.:]*)\}}
    return [while_re codearr $re text transform_refs_helper count]
}


proc prepend_with_object {text object_id {countVar ""}} {
    if { $countVar ne {} } {
	upvar $countVar count
    }
    set re {@\{([a-zA-Z_][a-zA-Z_0-9\.]*)\}}
    regsub -all -- $re $text "@{object_get.${object_id}.\\1}"
}



proc transform_dataset_refs {codearrVar dataset} {
    upvar $codearrVar codearr

    foreach varname {where often limit} {
	if { [$dataset exists $varname] } {
	    $dataset set $varname [transform_refs codearr [$dataset set $varname]]
	}
    }
}

proc sql_bind_var_substitution {__db_sql} {

    set __db_lst [regexp -inline -indices -all -- {:?:\w+} $__db_sql]
    for {set __db_i [expr [llength $__db_lst] - 1]} {$__db_i >= 0} {incr __db_i -1} {
	set __db_ws [lindex [lindex $__db_lst $__db_i] 0]
	set __db_we [lindex [lindex $__db_lst $__db_i] 1]
	set __db_bind_var [string range $__db_sql $__db_ws $__db_we]
	if {![string match "::*" $__db_bind_var]} {
	    set __db_tcl_var [string range $__db_bind_var 1 end]
	    #set __db_tcl_var [set $__db_tcl_var]
	    if { $__db_tcl_var eq {} } {
		set __db_tcl_var null
	    } else {
		#set __db_tcl_var "'[DoubleApos $__db_tcl_var]'"
		set __db_tcl_var "\[ns_dbquotevalue \$::__data__($__db_tcl_var)\]"
	    }
	    set __db_sql [string replace $__db_sql $__db_ws $__db_we $__db_tcl_var]
	}                
    }

    return $__db_sql

}

# --------------------- regexp utils -------------------------

proc while_re {codearrVar re textVar fn {countVar ""}} {

    upvar $codearrVar codearr

    upvar $textVar text

    if { $countVar ne {} } {
	upvar $countVar count
    }

    set result ""
    set count 0
    set start 0
    while {[regexp -start $start -indices -- $re $text match submatch]} {

	lassign $submatch subStart subEnd
	lassign $match matchStart matchEnd
	incr matchStart -1
	incr matchEnd

	set before_text [string range $text $start $matchStart]
	if { $before_text ne {} } {
	    append result $before_text
	}

	set in_text [string range $text $subStart $subEnd]
	append result [$fn codearr in_text]
	set start $matchEnd
	incr count
    }
    set after_text [string range $text $start end]
    if { $after_text ne {} } { 
	append result $after_text
    }
    return $result
}


# ------------------------ content delivery -----------------------------


if { [::xo::kit::production_mode_p] } { 
    set default_cdn_host [::templating::config::get_option "default_cdn_host"]
    proc get_cdn_url {url} "return \"//${default_cdn_host}/\[string trimleft \${url} {/}\]\""
    
} else {
    proc get_cdn_url {url} {
	return "/r/[string trimleft ${url} {/}]"
    }    
}

    proc get_resources_dir {} { return /web/data/build/resources }
    proc get_js_dir {} { return [get_resources_dir]/js }
    proc get_css_dir {} { return [get_resources_dir]/css }
    proc get_img_dir {} { return [get_resources_dir]/img }

proc make_resources_skel {} {
    if { ![file isdirectory [get_js_dir]] } { 
	file mkdir [get_js_dir]
    }
    if { ![file isdirectory [get_css_dir]] } { 
	file mkdir [get_css_dir]
    }
    if { ![file isdirectory [get_img_dir]] } { 
	file mkdir [get_img_dir]
    }
}

make_resources_skel


