namespace eval ::ttext {;}

proc ::ttext::langclass {text} {

    set result [list]

    set lc_str [::ttext::__langclass $text]

    if { ${lc_str} eq {UNKNOWN} } {
	return ${result}
    }

    set lc_list [split ${lc_str} {[]}]
    set lc_final [lsearch -all -inline -not ${lc_list} {}]
    foreach lc ${lc_final} {
	lassign [split ${lc} {-}] lang variant charset
	if { ${variant} eq {} } {
	    set lc_dot ${lang}.${charset}
	} else {
	    set lc_dot ${lang}-${variant}.${charset}
	}
	lappend result ${lc_dot}
    }
    return ${result}
}
