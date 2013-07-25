
proc iota n {
    # index vector generator, e.g. iota 5 => 0 1 2 3 4
    set res {}
    for {set i 0} {$i<$n} {incr i} {
        lappend res $i
    }
    set res
}



namespace eval ::util {;}


proc ::util::namespaceIf { name } {
    namespace eval ${name} {;}
}

proc ::util::returnIf { expression trueString falseString } {
    if { [expr $expression] } {
	return $trueString
    } else {
	return $falseString
    }
}

proc ::util::map {ff list} {

    set result [list]
    foreach value ${list} {
        lappend result [{*}${ff} "${value}"]
    }

    return ${result}
}

namespace eval json {;}

proc ::json::encode(s) {value {spec ""}} {
    return [::util::jsquotevalue ${value}]
}
proc ::json::encode(b) {value {spec ""}} {
    return [expr { [::util::boolean ${value}] ? true : false }]
}
proc ::json::encode(n) {value {spec ""}} {
    return ${value}
}

proc ::json::encode(fn) {value {spec ""}} {
    return ${value}
}


proc ::json::encode(L) {list {spec ""}} {
    set result {}
    set spec [::util::coalesce $spec "s"]
    if { 1 == [llength ${spec}] } {
	set spec [split [string repeat ${spec} [llength $list]] ""]	
    }
    foreach value ${list} NS ${spec} {
	lappend result [::json::encode(${NS}) ${value}]
    }
    return \[[join $result {,}]\]
}


proc ::json::encode(M) {map args} {
    set result {}
    foreach {key value} ${map} {
	lassign [lreverse [split ${key} {:}]] name NS
	lassign [split [::util::coalesce ${NS} {s}] {|}] type spec
	lappend result [::util::jsquotevalue ${name}]:[::json::encode(${type}) ${value} ${spec}]
    }
    return \{[join ${result} ,]\}
}

proc ::util::map2json {args} {
    return [::json::encode(M) ${args}]
}

proc ::util::list2json {list {spec ""}} {
    return [::json::encode(L) ${list} ${spec}]
}



proc ::util::base_characters {base_n} {
    set base [list 0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M \
         N O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p \
                  q r s t u v w x y z]
    if {$base_n < 2 || $base_n > 62} {
         error "Invalid base \"$base_n\" (should be an integer between 2 and 62)"
    }
    return [lrange $base 0 [expr $base_n - 1]]
}


proc ::util::decimal_to_base_n {number base_n {base ""}} {
    if { $base eq {} } {
        set base [base_characters $base_n]
    }
    # trim white space in case [format] is used
    set number [string trim $number]

    if {![string is integer $number] || $number < 0} {
         error "$number is not a base-10 integer between 0 and 2147483647"
    }

    while 1 {
        set quotient  [expr $number / $base_n]
        set remainder [expr $number % $base_n]
         lappend remainders $remainder
         set number $quotient
        if {$quotient == 0} {
             break
        }
    }

    set base_n [list]

    for {set i [expr [llength $remainders] - 1]} {$i >= 0} {incr i -1} {
        lappend base_n [lindex $base [lindex $remainders $i]]
    }

    return [join $base_n ""]

}


proc ::util::shortline {text {leftIndex "100"} {rightIndex "30"}} {
    set length [string length $text]
    if { $leftIndex + $rightIndex > $length } {
	return $text
    } else {
	set prologue [string map {"\n" " " "\r" " "} [string range $text 0 $leftIndex]]
	set epilogue [string map {"\n" " " "\r" " "} [string range $text end-$rightIndex end]]
	return ${prologue}...${epilogue}
    }
}

# MUST we also change /web/share/ImageMagick/magic.xml
proc convert.string.to.hex str {
    binary scan $str H* hex
    return $hex
}


# used to be: convert.string.to.hex
proc ::util::string_to_hex str {
    binary scan $str H* hex
    return $hex
}

# used to be: convert.hex.to.string
proc ::util::hex_to_string hex {
    foreach c [split $hex ""] {
	if {![string is xdigit $c]} {
	    return "\#invalid $hex"
	}
    }
    binary format H* $hex
}


proc ::util::curr_dir {} {
    set current_script [uplevel {info script}]
    set dir [file dirname $current_script]
    return $dir
}

proc ::util::curr_file {} {
    return [uplevel {info script}]
}
