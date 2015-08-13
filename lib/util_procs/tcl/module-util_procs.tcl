package provide util_procs 0.1

set dir [file dirname [info script]]

namespace eval ::util {;}

proc ::util::boolean {value} {
    return [expr { ![string is false -strict $value] }]
}

# ---------------------------------- numbers ------------------------------

namespace eval ::util {
    variable base_chars "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
}

proc ::util::to_base {number base} {
        variable base_chars
        if {$number==0} { 
                return 0 
        } elseif {(($base>62) || ($base<2))} { 
                return -code error "base: expected integer between 2 and 62, got '$base'"
        } 
        set nums [string range $base_chars 0 [expr $base - 1]] 
        set result ""
        while {$number > 0} { 
                set result "[string index $nums [expr $number % $base]]${result}"
                set number [expr int($number / $base)]
        }
        set result
} 

proc ::util::from_base {number base} {
        variable base_chars
        if {(($base>62) || ($base<2))} { 
                return -code error "base: expected integer between 2 and 62, got '$base'"
        }
        set nums [string range $base_chars 0 [expr $base - 1]]  
        for {
                set result 0 
                set i 0
                set len [string length $number]
        } {$i<$len} {
                incr i
        } {     incr i
                set result [expr $result * $base] 
                set result [expr $result + [string first [string index $number $i] $nums]]  
        } 
        set result
} 

# ---------------------------------- numbers ------------------------------
 
proc ::util::dec_to_hex {num} {
    return [format "%x" $num]
}

proc ::util::hex_to_dec {hex} {
    return [expr "0x${hex}"]
}

# ---------------------------------- lists ------------------------------

proc ::util::head {list} {
    return [lindex $list 0]
}

proc ::util::prepend {prefix textVar} {
    upvar $textVar text
    set text "${prefix}${text}"
}


# ---------------------------------- uri ------------------------------

namespace eval ::util {

    variable ue_map
    variable ud_map

}

# ------------------------ datetime -----------------------------

namespace eval ::util::dt {;}

proc ::util::dt::age_to_timestamp {age timeval} {

    set sign "-"
    if { [lindex ${timeval} end] eq {ago} } {
	set age  [lrange ${age} 0 end-1]
	set sign "-"
    }

    set secs 0
    foreach {num precision} ${age} {
	switch -exact ${precision} {
	    sec -
	    secs -
	    second -
	    seconds  { incr secs ${num} }
	    min -
	    mins -
	    minute -
	    minutes  { incr secs [expr { ${num} * 60 }] }
	    hour -
	    hours  { incr secs [expr { ${num} * 3600 }] }
	    day -
	    days  { incr secs [expr { ${num} * 86400 }] }
	    week - 
	    weeks  { incr secs [expr { ${num} * 86400 * 7 }] }
	    month -
	    months  { incr secs [expr { ${num} * 86400 * 30 }] }
	    year -
	    years  { incr secs [expr { ${num} * 86400 * 365 }] }
	}
    }

    incr timeval "${sign}${secs}"
    set timestamp [clock format ${timeval} -format "%Y%m%dT%H%M"]

    return ${timestamp}
}


# ---------------------------------- files ------------------------------

namespace eval ::util::fs {;}

proc ::util::fs::ls {dir {types "d"}} {
    return [glob -nocomplain -tails -types ${types} -directory ${dir} -- "*"]
}

# TODO: move fs commands under ::util::fs
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

proc ::util::newerFile {a b} {
    return [expr {[file mtime $a] > [file mtime $b]}]
}

proc ::util::newerFileThan {path mtime} {
    return [expr {[file exists $path] && ([file mtime $path] > $mtime)}]
}



# ---------------------------------- strings ------------------------------

namespace eval ::util::strings {;}

proc ::util::strings::diff {old new {show_old_p "1"}} {
    package require struct::list

    set old [split $old " "]
    set new [split $new " "]

    # tcllib procs to get a list of differences between 2 lists
    # see: http://tcllib.sourceforge.net/doc/struct_list.html
    set len1 [llength $old]
    set len2 [llength $new]
    set result [::struct::list longestCommonSubsequence $old $new]
    set result [::struct::list lcsInvert $result $len1 $len2]

    # each chunk is either 'deleted', 'added', or 'changed'
    set i 0
    foreach chunk $result {
	#ns_log notice "\n$chunk\n"
        set action [lindex $chunk 0]
        set old_index1 [lindex [lindex $chunk 1] 0]
        set old_index2 [lindex [lindex $chunk 1] 1]
        set new_index1 [lindex [lindex $chunk 2] 0]
        set new_index2 [lindex [lindex $chunk 2] 1]
        
        while {$i < $old_index1} {
            lappend output [lindex $old $i]
            incr i
        }

        if { $action eq "changed" } {
	    if {$show_old_p} {
		lappend output <d>
		foreach item [lrange $old $old_index1 $old_index2] {
		    lappend output [string trim $item]
		}
		lappend output </d>
	    }
            lappend output <a>
            foreach item [lrange $new $new_index1 $new_index2] {
                lappend output [string trim $item]
            }
            lappend output </a>
            incr i [expr {$old_index2 - $old_index1 + 1}]
        } elseif { $action eq "deleted" } {
            lappend output <d>
            foreach item [lrange $old $old_index1 $old_index2] {
                lappend output [string trim $item]
            }
            lappend output </d>
            incr i [expr {$old_index2 - $old_index1 + 1}]
        } elseif { $action eq "added" } {
            while {$i < $old_index2} {
                lappend output [lindex $old $i]
                incr i
            }
            lappend output <a>
            foreach item [lrange $new $new_index1 $new_index2] {
                lappend output [string trim $item]
            }
            lappend output </a>
        }
    }
    
    # add any remaining words at the end.
    while {$i < $len1} {
        lappend output [lindex $old $i]
        incr i
    }

    set output [join $output { }]
 
    # set output [string map {"<d>" {<span class="diff-deleted">}
    # "</d>" </span>
    # "<a>" {<span class="diff-added">}
    # "</a>" </span>} $output]

    return "$output"
}

# ------------------------ quoting -----------------------------

proc ::util::doublequote {text} {
    return \"[string map {\" {\"}} ${text}]\"
}


proc ::util::striphtml {html} {
    return [ns_striphtml ${html}]
    ###
    regsub -all -- {<[^>]*>} ${html} "" html
    return ${html}
}


# ------------------------ variables -----------------------------


