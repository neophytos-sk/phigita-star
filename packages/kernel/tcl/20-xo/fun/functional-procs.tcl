# Functional.tcl - Functional Programming Library for TCL
# Version 30Nov2004
#
# Copyright (C) 2004 Salvatore Sanfilippo <antirez at invece dot org>
#
# The following terms apply to all files associated with the software
# unless explicitly disclaimed in individual files.
#
# The authors hereby grant permission to use, copy, modify, distribute,
# and license this software and its documentation for any purpose, provided
# that existing copyright notices are retained in all copies and that this
# notice is included verbatim in any distributions. No written agreement,
# license, or royalty fee is required for any of the authorized uses.
# Modifications to this software may be copyrighted by their authors
# and need not follow the licensing terms described here, provided that
# the new terms are clearly indicated on the first page of each file where
# they apply.
# 
# IN NO EVENT SHALL THE AUTHORS OR DISTRIBUTORS BE LIABLE TO ANY PARTY
# FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
# ARISING OUT OF THE USE OF THIS SOFTWARE, ITS DOCUMENTATION, OR ANY
# DERIVATIVES THEREOF, EVEN IF THE AUTHORS HAVE BEEN ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
# 
# THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.  THIS SOFTWARE
# IS PROVIDED ON AN "AS IS" BASIS, AND THE AUTHORS AND DISTRIBUTORS HAVE
# NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR
# MODIFICATIONS.
# 
# GOVERNMENT USE: If you are acquiring this software on behalf of the
# U.S. government, the Government shall have only "Restricted Rights"
# in the software and related documentation as defined in the Federal 
# Acquisition Regulations (FARs) in Clause 52.227.19 (c) (2).  If you
# are acquiring the software on behalf of the Department of Defense, the
# software shall be classified as "Commercial Computer Software" and the
# Government shall have only "Restricted Rights" as defined in Clause
# 252.227-7013 (c) (1) of DFARs.  Notwithstanding the foregoing, the
# authors grant the U.S. Government and others acting in its behalf
# permission to use and distribute the software in accordance with the
# terms specified in this license.

################################################################################
# FUNCTIONAL PROGRAMMING COMMANDS
################################################################################

namespace eval ::xo {;}
namespace eval ::xo::fun {;}

# [map] works exactly like Tcl's [foreach] command, but for every
# iteration, the result of the body script is appended to a list
# that is finally returned.
#
# Examples:
#
# map x {1 2 3} {expr {$x*$x}} ;# => [list 1 4 9]
# map x {hello foo foobar} {string length $x} ;# => [list 5 3 6]
# map {x y} {1 2 3 4} {expr {$x+$y}}; # => [list 3 7]
#
#
# Note: contrary to [foreach], [map] requires that every list is
# consumed by the corresponding varList in the same number of iterations.
proc ::xo::fun::map args {
    set argc [llength $args]
    # Check arity
    if {$argc < 3 || ($argc % 2) != 1} {
	error {wrong # args: should be "map varList list ?varList list? script"}
    }
    set listNum [expr {($argc-1)/2}]
    set numIter -1
    # Check if number of vars matches the length of the lists
    # and if the number of iterations is the same for all the lists.
    for {set i 0} {$i < $listNum} {incr i} {
	set varList [lindex $args [expr {$i*2}]]
	set curList [lindex $args [expr {$i*2+1}]]
	if {[llength $curList] % [llength $varList]} {
	    error "list length doesn't match varList in arg # [expr {$i*2+1}]"
	}
	set curNumIter [expr {[llength $curList]/[llength $varList]}]
	if {$numIter == -1} {
	    set numIter $curNumIter
	} elseif {$numIter != $curNumIter} {
	    error "different number of iterations for varList/list pairs"
	}
    }
    # Performs the actual mapping.
    set script [lindex $args end]
    set res {}
    for {set iter 0} {$iter < $numIter} {incr iter} {
	for {set i 0} {$i < $listNum} {incr i} {
	    set varList [lindex $args [expr {$i*2}]]
	    set curList [lindex $args [expr {$i*2+1}]]
	    set numVars [llength $varList]
	    set listSlice [lrange $curList [expr {$numVars*$iter}] \
					    [expr {$numVars*$iter+$numVars-1}]]
	    uplevel 1 [list foreach $varList $listSlice break]
	}
	lappend res [uplevel 1 $script]
    }
    return $res
}

# Filter takes as input a list, the name of a variable and an [expr]'s
# expression, tests every element of the list usign the expression
# (evaluated assigning to the variable name the value of the element),
# and returns a list composed of only the elements passing the test.
#
# Example:
#
# filter {1 2 3 4 5} x {$x > 3} ;# => [list 4 5]
proc ::xo::fun::filter {flist fvar fexpr} {
    upvar 1 $fvar var
    set res {}
    foreach var $flist {
	set varCopy $var
	if {[uplevel 1 [list expr $fexpr]]} {
	    lappend res $varCopy
	}
    }
    return $res
}

# [lsplit] works like [filter], but instead to return the elements
# passing the test, it returns [list $no $yes], where $no
# is a list composed of elements passing the test, and $yes
# is a list composed of elements NOT passing it.
#
# Example:
#
# lsplit {1 2 3 4 5} x {$x > 3} ;# => [list [list 1 2 3] [list 4 5]]
proc lsplit {flist fvar fexpr} {
    upvar 1 $fvar var
    set left {}
    set right {}
    foreach var $flist {
	set varCopy $var
	if {[uplevel 1 [list expr $fexpr]]} {
	    lappend right $varCopy
	} else {
	    lappend left $varCopy
	}
    }
    return [list $left $right]
}

# Reverse the list 'l'.
#
# Example: lreverse {a b c} ;# => [list c b a]
proc lreverse l {
    set result {}
    set i [llength $l]
    while {[incr i -1] >= 0} {
	lappend result [lindex $l $i]
    }
    return $result
}

# lmax list
# lmin list
#
# [lmax] returns the element with the greatest value in 'list',
# that's a list composed numerical elements.
#
# [lmix] returns the element with the littlest value.
#
# Both the fuctions return an empty string if the input list is empty.
#
# Example: lmax {10 5 12 4} ;# -> 12
foreach {name op} {lmax > lmin <} {
    proc $name l [format {
	set winner [lindex $l 0]
	foreach e $l {
	    if {$e %s $winner} {
		set winner $e
	    }
	}
	return $winner
    } $op]
}

# Interleave lists passed as arguments.
# Example: interleave {a b c} {1 2 3} ;# => [list a 1 b 2 c 3]
proc linterleave args {
    set maxlen [lmax [::xo::fun::map x $args {llength $x}]]
    set numlists [llength $args]
    set result {}
    for {set i 0} {$i < $maxlen} {incr i} {
	for {set j 0} {$j < $numlists} {incr j} {
	    lappend result [lindex $args $j $i]
	}
    }
    return $result
}

# A non garbage collecting [lamda] implementation.
# The best we can get for now. Note that's not very useful
# with the implementation of other functional command in this
# library because [map], [filter], ... all take Tcl scripts directly
# as "inline functions", so lambda is not required.
#
# However there are times where a command is passed as argument, like
# in the case of [fold] command. In such a case [lambda] is useful.
proc lambda {argl body} {
    set name [info level 0]
    proc $name $argl $body
    set name
}

# Given a command 'cmd' and a list 'l' with elements l1, l2, l3, ..., lN
# [fold] returns [$cmd ... [$cmd [$cmd l1 l2] l3] ... lN].
# For example if 'cmd' is the procedure:
#
# proc add {x y} {expr {$x+$y}}
#
# Then [fold {1 2 3 4} add] returns (((1+2) + 3) + 4)
proc ::xo::fun::fold {l cmd} {
    set res [lindex $l 0]
    for {set i 1} {$i < [llength $l]} {incr i} {
	set res [$cmd $res [lindex $l $i]]
    }
    return $res
}

################################################################################
# ALISTS OPERATIONS
################################################################################

# Returns the value relative to the key 'k' in the alist 'l'.
proc aget {l k} {
    if {[llength $l] % 2} {
	error "aget: malformed alist, odd number of elements in list."
    }
    foreach {key val} $l {
	if {$key eq $k} {
	    return $val
	}
    }
    return {}
}

# Set the value 'v' for the key 'k' in the alist stored in the variable 'lvar'.
# If the given key is not present it is added to the alist.
proc aset {lvar k v} {
    upvar 1 $lvar l
    if {[llength $l] % 2} {
	error "aget: malformed alist, odd number of elements in list."
    }
    set idx 1
    foreach {key val} $l {
	if {$key eq $k} {
	    return [lset l $idx $v]
	}
	incr idx 2
    }
    lappend l $k $v
}

# Returns the index of the 'key' in the alist 'l'. If the key is not
# present, -1 is returned.
proc aindex {l k} {
    set idx 0
    foreach {key val} $l {
	if {$key eq $k} {
	    return $idx
	}
	incr idx 2
    }
    return -1
}

################################################################################
# MATH OPERATORS AS COMMANDS
################################################################################

# Math operators as commands
foreach {op neutral} {+ 0 * 1} {
    proc $op args [format {
	set result %s
	foreach a $args {
	    set result [expr {$result %s $a}]
	}
	return $result
    } $neutral $op]
}

proc - args {
    if {[llength $args] > 1} {
	set result [lindex $args 0]
	foreach a [lrange $args 1 end] {
	    set result [expr {$result - $a}]
	}
	return $result
    } elseif {[llength $args] == 1} {
	expr {-[lindex $args 0]}
    } else {
	error "- expects at least 1 argument."
    }
}

proc / args {
    if {[llength $args] > 1} {
	set result [lindex $args 0]
	foreach a [lrange $args 1 end] {
	    set result [expr {$result / $a}]
	}
	return $result
    } elseif {[llength $args] == 1} {
	expr {1.0/[lindex $args 0]}
    } else {
	error "/ expects at least 1 argument."
    }
}

################################################################################
# SETS OPERATIONS
################################################################################

proc lintersect {a b} {
    foreach e $a {
	set x($e) {}
    }
    set result {}
    foreach e $b {
	if {[info exists x($e)]} {
	    lappend result $e
	}
    }
    return $result
}

proc lunion {a b} {
    foreach e $a {
	set x($e) {}
    }
    foreach e $b {
	if {![info exists x($e)]} {
	    lappend a $e
	}
    }
    return $a
}

proc ldifference {a b} {
    foreach e $b {
	set x($e) {}
    }
    set result {}
    foreach e $a {
	if {![info exists x($e)]} {
	    lappend result $e
	}
    }
    return $result
}

proc in {list element} {
    expr {[lsearch -exact $list $element] != -1}
}

################################################################################
# ADDITIONAL LIST FUNCTIONS
################################################################################

# The [range] command as for TIP 225.
proc rangeLen {start end step} {
    if {$step == 0} {return -1}
    if {$start == $end} {return 0}
    if {$step > 0 && $start > $end} {return -1}
    if {$step < 0 && $end > $start} {return -1}
    expr {1+((abs($end-$start)-1)/abs($step))}
}

proc range args {
    # Check arity
    set l [llength $args]
    if {$l == 1} {
	set start 0
	set step 1
	set end [lindex $args 0]
    } elseif {$l == 2} {
	set step 1
	foreach {start end} $args break
    } elseif {$l == 3} {
	foreach {start end step} $args break
    } else {
        error {wrong # of args: should be "range ?start? end ?step?"}
    }

    # Generate the range
    set rlen [rangeLen $start $end $step]
    if {$rlen == -1} {
	error {invalid (infinite?) range specified}
    }
    set result {}
    for {set i 0} {$i < $rlen} {incr i} {
	lappend result [expr {$start+($i*$step)}]
    }
    return $result
}


    proc ldetect {var_ref list test} {
        upvar $var_ref var
        foreach a $list {
            set var $a
            set rtest [uplevel [list expr $test]]
            if $rtest {
                return $a
            }
        }
        return
    }
    proc lselect {var_ref list test} {
        upvar $var_ref var
        set ret {}
        foreach a $list {
            set var $a
            set rtest [uplevel [list expr $test]]
            if $rtest {
                lappend ret $var
            }
        }
        return $ret
    }