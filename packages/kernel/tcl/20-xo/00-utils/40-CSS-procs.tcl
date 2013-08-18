proc sv_cache_eval {varname element script} {
    set result ""
    set exists_p [nsv_exists $varname $element]
    if { !$exists_p } {
	# The stack level of the invoking procedure. 
	#set level [info level]
	proc _sv_cache_eval_proc {} [list uplevel 2 $script]
	set result [_sv_cache_eval_proc]
	#ns_log notice "sv_cache_eval $varname $element = $result"
	nsv_set $varname $element $result
    } else {
	set result [nsv_get $varname $element]
    }
    return $result
}


package require crc16

namespace eval ::xo {;}
namespace eval ::xo::html {

    variable sBase64Chars

    set i 0
    foreach char {
	a b c d e f g h i j k l m n
	o p q r s t u v w x y z 0 1 
	2 3 4 5 6 7 8 9 _
    } {
	set sBaseChars(${i}) $char
	incr i
    }

}

namespace eval ::xo::html::style {;}


proc ::xo::html::add_style {spec} {
    set key [::util::boolean [ad_conn user_id]].[ad_conn file]
    if { [nsv_exists CSS_MEMOIZE CSS:${key}] } {
	return
    }
    global __CSS__
    append __CSS__ "${spec}"
}

### HAS BUGS
proc ::xo::html::add_style_file {url} {
    global __CSS_FILE__
    lappend __CSS_FILE__ "${url}"
    link -href ${url} -media "all" -rel "stylesheet" -type "text/css"
}

### HAS BUGS
proc ::xo::html::compile_style_file {url} {
    sv_cache_eval CSS_MEMOIZE CSS_FILE:${url} {
	set infile [file normalize /web/service-phigita/www/${url}]
	set outfile [file normalize /web/data/${url}]
	if { ![file exists $outfile] } {
	    set fp [open $infile]
	    set css [read $fp]
	    close $fp
	    ::xo::html::compile_style $css compiled_file
	    file copy $compiled_file $outfile
	}
	if { [file mtime $infile] > [file mtime $outfile] } {
	    ns_log notice "outfile=$outfile is older than [ad_conn file] ... recompile/remove outfile!"
	}
	return 1
    }
}

proc ::xo::html::include_style {url} {
    ::xo::html::add_style [sv_cache_eval CSS_MEMOIZE CSS_FILE:${url} {
	set filename [file normalize [acs_root_dir]/www/${url}]
	set fp [open $filename]
	set data [read $fp]
	close $fp
	set data
    }]
}


if { [::xo::kit::performance_mode_p] } {
    proc ::xo::html::get_cache_key {} {
	set host [ns_info hostname]
	set filekey [string map {/ .} [ad_conn file]]
	set selectors [join [lsort -unique [array names ::__CSS_EL__]] {.}]
	set key ${host}-[crc::crc16 -format %X ${filekey}-${selectors}]
    }
} else {
    proc ::xo::html::get_cache_key {} {
	set host [ns_info hostname]
	set filekey [string map {/ .} [ad_conn file]]
	set mtime [file mtime [ad_conn file]]
	set selectors [join [lsort -unique [array names ::__CSS_EL__]] {.}]
	set key ${host}-[crc::crc16 -format %X ${filekey}-${selectors}]-${mtime}
    }
}

proc ::xo::html::compile_style {css {outfileVar ""}} {

    if { $outfileVar ne {} } {
	upvar $outfileVar outfile
    }

    #set key [ns_info hostname]-[::util::boolean [ad_conn user_id]]-[string map {/ .} [ad_conn file]-[file mtime [ad_conn file]]]
    set key [::xo::html::get_cache_key]

    set path /web/data/css
    set prefix ${path}/${key}
    set token [ns_sha1 ${css}]
    set infile ${prefix}-in-${token}.css
    set outfile ${prefix}-out-${token}.css
    set mapfile ${prefix}-map-${token}.css

    if { ![file exists $infile] } {

	foreach filename [glob -nocomplain ${prefix}-*] {
	    file delete -force -- $filename
	}
	#ns_log notice "infile=$infile"
	set fp [open ${infile} w]
	puts $fp [::xo::html::opticss $css true]
	close $fp
	
	set fp [open ${mapfile} w]
	puts $fp [dict create file [ad_conn file] map [array get ::__CSS_EL__] is_registered_p [::xo::kit::is_registered_p] url [ns_conn url] query [ns_conn query]]
	close $fp

    }
    if { ![file exists $outfile] } {
	#set JAVA /usr/bin/java
	#set cmd "${JAVA} -jar /opt/yuicompressor/build/yuicompressor-2.2.5.jar --type css ${infile} -o ${outfile}"
	ns_log notice "::xo::html::compile_style (YUICOMPRESSOR)"
	#exec -- /bin/sh -c "${cmd} 2>&1 || exit 0" 2> /dev/null
	::CSS do minimize $infile $outfile
    }
    set result ""
    set fp [open $outfile]
    set result [read $fp]
    close $fp
    return $result

    #return [string map {\n ""} ${css}]
}



if { [::xo::kit::performance_mode_p] } {

    #key is usually [ad_conn file]
    proc ::xo::html::get_compiled_style {} {
    
	#set key [::util::boolean [ad_conn user_id]].[ad_conn file]
	set key [::xo::html::get_cache_key]
	global __CSS__
	append __CSS__ ""
	return [sv_cache_eval CSS_MEMOIZE CSS:${key} {
	    return [::xo::html::compile_style ${__CSS__}]
	}]
    }

} else {

    #key is usually [ad_conn file]
    proc ::xo::html::get_compiled_style {} {
    
	#set key [::util::boolean [ad_conn user_id]].[ad_conn file]
	set key [::xo::html::get_cache_key]

	global __CSS__
	append __CSS__ ""

	set path /web/data/css
	set prefix ${path}/${key}
	set token [ns_sha1 ${__CSS__}]
	set infile ${prefix}-in-${token}.css
	set extra_flags ""
	if { ![file exists $infile] && [nsv_exists CSS_MEMOIZE CSS:${key}] } {
	    set extra_flags "-force"
	    nsv_unset CSS_MEMOIZE CSS:${key}
	}
	#{*}${extra_flags} 
	return [sv_cache_eval CSS_MEMOIZE CSS:${key} {
	    return [::xo::html::compile_style ${__CSS__}]
	}]
    }

}

proc ::xo::html::cssId {name} {
    #ns_log notice "cssId $name"
    if { [info exists ::__CSS_EXCLUDE__(${name})] } {
	return $::__CSS_EXCLUDE__(${name})
    }
    if {[info exists ::__CSS_EL__(${name})]} {
	return $::__CSS_EL__(${name})
    }
    return [set ::__CSS_EL__(${name}) [::xo::html::obfuscate [incr ::__CSS_ID__]]]
}

proc ::xo::html::cssList {elements} {
    set result [list]
    foreach element ${elements} {
	lappend result [::xo::html::cssId ${element}]
    }
    return ${result}
}

proc ::xo::html::iexclude {selectors} {
    foreach selector ${selectors} {
	set ::__CSS_EXCLUDE__(${selector}) ${selector}
    }
}

proc ::xo::html::iuse {selectors} {
    foreach selector ${selectors} {
	set ::__CSS_EL__(${selector}) ${selector}
    }
}

proc ::xo::html::cssListToJS {arrayName selectors} {
    set result [list]
    foreach selector ${selectors} newselector [::xo::html::cssList ${selectors}] {
	lappend result "'${selector}':'${newselector}'"
    }
    #return "window\['${arrayName}'\]=\{[join ${result} {,}]\};"
    return "xo.setCssNameMapping(\{[join ${result} {,}]\});"

}


proc ::xo::html::obfuscate {id} {
    variable sBaseChars
    set result ""
    append result $sBaseChars([expr {${id} & 0x0f}])
    set id [expr { ${id} >> 4  }]
    while { ${id} != 0 } {
	append result $sBaseChars([expr {${id} & 0x1f}])
	set id [expr { ${id} >> 5  }]
    }
    return ${result}
}



proc ::xo::html::get_css_element {element} {
    set result [list]
    foreach part ${element} {
	set char ""
	set tag ""
	set selector ""
	set extra ""
	lassign [split ${part} {.#}] tag selector
	lassign [split ${selector} {:}] selector extra
	if { $selector ne {} } {
	    set char [string index ${part} [string length ${tag}]]
	    set newElement ${tag}${char}[::xo::html::cssId ${selector}]
	    if { $extra ne {} } {
		append newElement :${extra}
	    }
	    lappend result $newElement
	    #ns_log notice "part=$part tag=$tag selector=$selector char=$char"
	} else {
	    lappend result ${tag}
	}
    }
    return [join $result]
}

proc ::xo::html::cssId_p {element} {
    foreach part $element {
	set selector ""
	lassign [split $part {.#}] tag selector
	lassign [split ${selector} {:}] selector __hover_etc__
	if { $selector ne {} } {
	    if { ![info exists ::__CSS_EL__(${selector})] } { 
		#ns_log notice "cssId_p=0 for $selector"
		return 0
	    }
	    # else continue
	} else {
	    # css for html tag names
	    return 1
	}
    }
    return 1
}


# creates a tcl style global array object from a CSS file
# returns the name of the tcl style global array (object)
proc ::xo::html::opticss {css {advanced_p false}} {

    set result ""
    # first we get rid of comments - css comments are not allowed to go over a line
    regsub -all {/\*[^\n]*\*/} $css "" newcss

    # we want to grab every string of the form
    #     "foo foo1 . . { attr1: val1 val2 ...; .... attrn: valn1 valn2 ...[;] }"
    # and turn it into
    #     "style(stmt# foo foo1 ...) { attr1 {val1 val2 ...} .... attrn {valn1 valn2 ...} }

    for { set i 1 } {[regexp {^([^\{]*)\{([^\}]*)\}} $newcss match elements attrs]} { incr i } {
        # strip the match from newcss
        set newcss [ string range $newcss [string length $match] end ]


	set newelements [list]
	foreach el [split $elements {,}] {
	    set el [string trim ${el}]
	    if { $advanced_p && ![::xo::html::cssId_p $el] } { 
		# TODO: Add these in a file.
		# ns_log notice "unused css: $el"
		continue 
	    }
	    lappend newelements [::xo::html::get_css_element $el]
	}
	if { ${newelements} ne {} } {
	    append result "\n[join $newelements {,}] \{$attrs\}"
	}
    }
    # newcss should now be empty
    if { [string trim $newcss] ne {} } {
        ns_log notice "Error in stylesheet. The following was not parsed: [ string trim $newcss ]"
    }

   return $result
 }
