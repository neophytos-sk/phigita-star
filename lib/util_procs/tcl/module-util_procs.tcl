package provide util_procs 0.1

set dir [file dirname [info script]]
source [file join $dir list_procs.tcl]

namespace eval ::util {;}


proc ::util::boolean {value} {
    return [expr { ![string is false -strict $value] }]
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

proc ::util::prepend {prefix text} {
    return "${prefix}${text}"
}


# ---------------------------------- uri ------------------------------

proc ::util::host_from_url {url} {

    set host ""
    set re {://([^/]+)}
    regexp -- ${re} ${url} match host
    return ${host}
}

proc ::util::domain_from_host {host} {

    if { ${host} eq {} } {
	return
    }

    set re {([^\.]+\.)(com\.cy|ac.cy|gov.cy|org.cy|gr|com|net|org|info|coop|int|co\.uk|org\.uk|ac\.uk|uk|co|eu|__and so on__)$}

    if { [regexp -- ${re} ${host} whole domain tld] } {
	return ${domain}${tld}
    }

    puts "could not match regexp to host=${host}"

    return ${host}
}

proc ::util::domain_from_url {url} {

    if { ${url} eq {} } {
	return
    }

    set index [string first {:} ${url}]
    if { ${index} == -1 } {
	return
    }

    set scheme [string range ${url} 0 ${index}]
    if { ${scheme} ne {http:} && ${scheme} ne {https:} } {
	return
    }

    set host [host_from_url ${url}]

    # note that host can be empty, e.g. if url was "http:///"    

    return [::util::domain_from_host ${host}]
}


proc ::util::urldecode {str} {
    # rewrite "+" back to space
    # protect \ from quoting another '\'
    set str [string map [list + { } "\\" "\\\\"] $str]

    # prepare to process all %-escapes
    regsub -all -- {%([A-Fa-f0-9][A-Fa-f0-9])} $str {\\u00\1} str

    # process \u unicode mapped chars
    return [subst -novar -nocommand $str]
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

proc ::util::readfile {filename} {
    set fp [open ${filename}]
    set data [read $fp [file size ${filename}]]
    close $fp
    return $data
}

proc ::util::writefile {filename data} {
    set fp [open $filename w]
    puts -nonewline $fp $data
    close $fp
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


# findFiles
# basedir - the directory to start looking in
# pattern - A pattern, as defined by the glob command, that the files must match
proc ::util::findFiles { basedir pattern } {

    # Fix the directory name, this ensures the directory name is in the
    # native format for the platform and contains a final directory seperator
    set basedir [string trimright [file join [file normalize $basedir] { }]]
    set fileList {}

    # Look in the current directory for matching files, -type {f r}
    # means ony readable normal files are looked at, -nocomplain stops
    # an error being thrown if the returned list is empty
    foreach fileName [glob -nocomplain -type {f r} -path $basedir $pattern] {
        lappend fileList $fileName
    }

    # Now look for any sub direcories in the current directory
    foreach dirName [glob -nocomplain -type {d  r} -path $basedir *] {
        # Recusively call the routine on the sub directory and append any
        # new files to the results
        set subDirList [findFiles $dirName $pattern]
        if { [llength $subDirList] > 0 } {
            foreach subDirFile $subDirList {
                lappend fileList $subDirFile
            }
        }
    }
    return $fileList
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


# ------------------------ variables -----------------------------

namespace eval ::util::var {;}

proc ::util::var::get_value_if {varname {default ""}} {
    upvar $varname var
    if { [info exists var] } {
	return ${var}
    }
    return ${default}
}

# Returns 1 if the variable name exists in the caller's environment and is not the empty string.
proc ::util::var::exists_and_not_null { varname } {
    upvar 1 ${varname} var
    return [expr { [info exists var] && (${var} ne {}) }] 
} 

namespace eval ::util::var {
    namespace export *
}

namespace eval :: {
    namespace import ::util::var::*
}
