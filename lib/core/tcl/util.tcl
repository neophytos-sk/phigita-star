namespace eval ::util { 
    namespace export \
        coalesce \
        boolval \
        valuelist_if \
        value_if \
        set_if \
        unset_if \
        reversedotted \
        readfile \
        writefile \
		exists_and_not_null
}

proc ::util::coalesce {args} {
    return [lsearch -not -inline $args {}]
}

proc ::util::boolval {value} {
    assert { $value ne {} } 
    set true_p [string is true -strict $value]
    set false_p [string is false -strict $value]
    assert { !(${true_p} && ${false_p}) }
    return ${true_p}
}

proc ::util::value_if {varname {default ""}} {
    upvar $varname var
    if { [info exists var] } {
        return ${var}
    }
    return ${default}
}

proc ::util::valuelist_if {varlist {defaults ""}} {
    set result [list]
    foreach varname $varlist default_value $defaults {
        upvar $varname _
        lappend result [if { [info exists _] } { set _ } else { set default_value }]
    }
    return ${result}
}

proc ::util::set_if {varname value} {
    upvar $varname _
    if { ![info exists _] } { 
        set _ $value
    } else {
        set _
    }
}

proc ::util::unset_if {varname} {
    upvar $varname _
    if { [info exists _] } { 
        unset _
    }
}


proc ::util::reversedotted {dotted_str} {
    return [join [lreverse [split ${dotted_str} {.}]] {.}]
}

proc ::util::readfile {filename args} {
    set fp [open ${filename}]
    if { $args ne {} } {
        fconfigure $fp {*}$args
    }
    set data [read $fp [file size ${filename}]]
    close $fp
    return $data
}

proc ::util::writefile {filename data args} {
    set fp [open $filename w]
    if { $args ne {} } {
        fconfigure $fp {*}$args
    }
    puts -nonewline $fp $data
    close $fp
}

proc ::util::writelink {src target} {
    if { [file exists $src] } {
        set old_target [file link $src]
        if { $old_target ne $target } { 
            file delete $src
        } else {
            return
        }
        set src_dir [file dirname $src]
        if { ![file isdirectory $src_dir] } {
            file mkdir $src_dir
        }
        file link $src $target
    } else {
        file link $src $target
    }
}

proc ::util::ino {filename} {
    file stat $filename arr
    return $arr(ino)
}

proc ::util::exists_and_not_null {varname} {
	upvar ${varname} _
	return [expr { [info exists {_}] && ${_} ne {} }]
}


proc util_memoize {script {interval "0"}} {
    return [eval ${script}]
}



namespace eval :: {
    namespace import ::util::coalesce
    namespace import ::util::boolval
    namespace import ::util::value_if
    namespace import ::util::valuelist_if
    namespace import ::util::set_if
    namespace import ::util::unset_if
    namespace import ::util::reversedotted
    namespace import ::util::exists_and_not_null
}


