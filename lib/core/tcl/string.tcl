# This one was written by Bob Techentin (RWT in Tcl'ers Wiki):
# http://www.techentin.net
# mailto:techentin.robert@mayo.edu
#
# Later, he send me an email stated that I can use it anywhere, because
# no copyright was added, so the code is defacto in the public domain.
#
# You can found it in the Tcl'ers Wiki here:
# http://mini.net/cgi-bin/wikit/460.html
#
# Bob wrote:
# If you need to split string into list using some more complicated rule
# than builtin split command allows, use following function. It mimics
# Perl split operator which allows regexp as element separator, but,
# like builtin split, it expects string to split as first arg and regexp
# as second (optional) By default, it splits by any amount of whitespace. 
# Note that if you add parenthesis into regexp, parenthesed part of separator
# would be added into list as additional element. Just like in Perl. -- cary 
#
# Speed improvement by Reinhard Max:
# Instead of repeatedly copying around the not yet matched part of the
# string, I use [regexp]'s -start option to restrict the match to that
# part. This reduces the complexity from something like O(n^1.5) to
# O(n). My test case for that was:
# 
# foreach i {1 10 100 1000 10000} {
#     set s [string repeat x $i]
#     puts [time {splitx $s .}]
# }
#
proc ::tcl::string::__splitx {str {regexp {[\t \r\n]+}}} {
    # Bugfix 476988
    if {[string length $str] == 0} {
        return {}
    }
    if {[string length $regexp] == 0} {
        return [::split $str ""]
    }
    set list  {}
    set start 0
    while {[regexp -start $start -indices -- $regexp $str match submatch]} {
        foreach {subStart subEnd} $submatch break
        foreach {matchStart matchEnd} $match break
        incr matchStart -1
        incr matchEnd
        lappend list [string range $str $start $matchStart]
        if {$subStart >= $start} {
            lappend list [string range $str $subStart $subEnd]
        }
        set start $matchEnd
    }
    lappend list [string range $str $start end]
    return $list
}

#
# splitn --
#
# splitn splits the string $str into chunks of length $len.  These
# chunks are returned as a list.
#
# If $str really contains a ByteArray object (as retrieved from binary
# encoded channels) splitn must honor this by splitting the string
# into chunks of $len bytes.
#
# It is an error to call splitn with a nonpositive $len.
#
# If splitn is called with an empty string, it returns the empty list.
#
# If the length of $str is not an entire multiple of the chunk length,
# the last chunk in the generated list will be shorter than $len.
#
# The implementation presented here was given by Bryan Oakley, as
# part of a ``contest'' I staged on c.l.t in July 2004.  I selected
# this version, as it does not rely on runtime generated code, is
# very fast for chunk size one, not too bad in all the other cases,
# and uses [split] or [string range] which have been around for quite
# some time.
#
# -- Robert Suetterlin (robert@mpe.mpg.de)
#
proc ::tcl::string::__splitn {str {len 1}} {

    if {$len <= 0} {
        return -code error "len must be > 0"
    }

    if {$len == 1} {
        return [split $str {}]
    }

    set result [list]
    set max [string length $str]
    set i 0
    set j [expr {$len -1}]
    while {$i < $max} {
        lappend result [string range $str $i $j]
        incr i $len
        incr j $len
    }

    return $result
}

proc ::tcl::string::diff {old new {show_old_p "1"}} {
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

set ensemble "string"
set __config_map [namespace ensemble configure $ensemble -map]
lappend __config_map "__splitx" "::tcl::string::__splitx"
lappend __config_map "__splitn" "::tcl::string::__splitn"
lappend __config_map "__diff" "::tcl::string::__diff"
namespace ensemble configure $ensemble -map $__config_map
unset __config_map

