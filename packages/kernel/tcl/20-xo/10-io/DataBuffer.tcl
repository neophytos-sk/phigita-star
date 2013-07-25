package require XOTcl; namespace import -force ::xotcl::*

namespace eval ::xo::io {;}

proc ::xo::io::memchan {} {
    return [chan create {read write} [DataBuffer new]]
}

Class DataBuffer -parameter {
    {channel ""}
    {content ""}
    {at 0}
}
DataBuffer instproc init {args} {
    my instvar allowed requested delay 
    array set allowed {
	read  0
	write 0
    }
    set requested {}
    set delay     10
    return
}
DataBuffer instproc initialize {ch mode} {
    #puts [self proc]-$args
    return "initialize finalize watch read write seek"
}
DataBuffer instproc finalize {ch} {
    #puts [self proc]-$args
    my destroy
}
DataBuffer instproc watch {ch events} {
    #puts [self proc]-$args
    
}
DataBuffer instproc  read {c n} {
    my instvar at content

    # First determine the location of the last byte to read,
    # relative to the current location, and limited by the maximum
    # location we are allowed to access per the size of the
    # content.

    set last [expr {min($at + $n,[string length $content])-1}]

    # Then extract the relevant range from the content, move the
    # seek location behind it, and return the extracted range. Not
    # to forget, switch readable events based on the seek
    # location.

    set res [string range $content $at $last]
    set at $last
    incr at

    my Events
    return $res
}
DataBuffer instproc write {c newbytes} {
    my instvar at content

    # Return immediately if there is nothing is to write.
    set n [string length $newbytes]
    if {$n == 0} {
	return $n
    }

    # Determine where and how to write. There are three possible cases.
    # (1) Append at/after the end.
    # (2) Starting in the middle, but extending beyond the end.
    # (3) Replace in the middle.

    set max [string length $content]
    if {$at >= $max} {
	# Ad 1.
	append content $newbytes
	set at [string length $content]
    } else {
	set last [expr {$at + $n - 1}]
	if {$last >= $max} {
	    # Ad 2.
	    set content [string replace $content $at end $newbytes]
	    set at [string length $content]
	} else {
	    # Ad 3.
	    set content [string replace $content $at $last $newbytes]
	    set at $last
	    incr at
	}
    }

    my Events
    return $n
}
DataBuffer instproc seek  {c offset base} {
    my instvar at content

    # offset == 0 && base == current
    # <=> Seek nothing relative to current
    # <=> Report current location.

    if {!$offset && ($base eq "current")} {
	return $at
    }

    # Compute the new location per the arguments.

    set max [string length $content]
    switch -exact -- $base {
	start   { set newloc $offset}
	current { set newloc [expr {$at  + $offset    }] }
	end     { set newloc [expr {$max + $offset - 1}] }
    }

    # Check if the new location is beyond the range given by the
    # content.

    if {$newloc < 0} {
	return -code error "Cannot seek before the start of the channel"
    } elseif {$newloc >= $max} {
	# We can seek beyond the end of the current contents, add
	# a block of zeros.
	append content [binary format @[expr {$newloc - $max}]]
    }

    # Commit to new location, switch readable events, and report.
    set at $newloc

    my Events
    return $at
}
DataBuffer instproc Events {args} {
    my instvar at content
    return ;# FIXME: HERE HERE HERE
    if {$at >= [string length $content]} {
	my disallow read
    } else {
	my allow read
    }

}

#% source DataBuffer.tcl
#% set ch [::xo::io::memchan]
#rc0
#% puts $ch "hello world"
#% seek $ch 0 start
#% gets $ch
#hello world
