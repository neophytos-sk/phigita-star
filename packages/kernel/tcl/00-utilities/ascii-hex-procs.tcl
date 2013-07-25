proc hex2ascii {hexstring} {
    set len [string length $hexstring]
    regsub "^0x" $hexstring "" hexstring
    if {[expr $len % 2]} {
        alertnote "Error : odd number of digits in hexadecimal string."
        return ""
    }
    set res ""
    for {set i 0} {$i < $len} {incr i 2} {
        append res [format %c "0x[string range $hexstring $i [expr $i+1]]"]
    }
    return $res
}

proc ascii2hex {inString {prefix ""}} {
    set res ""
    set len [string length $inString]
    for {set i 0} {$i < $len} {incr i} {
        scan "[string range $inString $i [expr $i+1]]" %c num
        append res [format %x $num]
    }
    return "$prefix$res"
}


