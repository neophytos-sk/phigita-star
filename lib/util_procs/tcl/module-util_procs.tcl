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

# ---------------------------------- files ------------------------------

namespace eval ::util::fs {;}

proc ::util::fs::ls {dir {types "d"}} {
    return [glob -nocomplain -tails -types ${types} -directory ${dir} -- "*"]
}

# TODO: move fs commands under ::util::fs


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


