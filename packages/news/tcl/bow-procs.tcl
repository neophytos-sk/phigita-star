namespace eval ::bow {;}

proc ::bow::getClassTreeSk {text {port 1821}} {
    return [string map {/ .} [lindex [lindex [getClassificationList ${text} ${port}] 0] 0]]
}
proc ::bow::getClassificationList { text {port 1821}} {
    set result ""
    try {

	set sp [socket localhost $port]
	fconfigure $sp -buffering none

	puts $sp "$text"
	puts $sp "."
	flush $sp

	set line ""
	gets $sp line
	while { ${line} ne {.} } {
	    lappend result $line
	    gets $sp line
	}

    } catch {*} {
	# do nothing
    } finally {
	if { [info exists sp] } {
	    close $sp
	}
    }
    return $result
}

proc ::bow::getExpandedVector tsVector {
    set result [list]
    foreach lexeme [split $tsVector " "] {
	foreach {word positions} [string map {: " "} $lexeme] break
	set word [string trim $word ']
	set times [llength [split $positions ,]]
	lappend result [string repeat "$word " $times]
    }
    return [join $result]
}
