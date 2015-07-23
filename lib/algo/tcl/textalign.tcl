#

package require core

namespace eval ::textalign {;}

proc ::textalign::lmin {arrVar} {
    upvar $arrVar arr
    
    set list [array names arr]
    set min [lindex $list 0]
    foreach value $list {
        if {$value < $min} {
            set min $value
        }
    }
    return $min
}

proc ::textalign::length {wordlengths i j} {
    set sum 0
    foreach len [lrange $wordlengths [expr { $i - 1 }] [expr { $j - 1 }]] {
        incr sum $len
    }
    return [expr { $sum + $j - $i + 1 }]
}


proc ::textalign::breakline {text L} {

    set words [split $text " \n\t\r"]

    # wl = lengths of words
    set wl [map w $words {string length $w}]

    # n = number of words in the text
    set n [llength $wl]

    # total badness of a text l_1 ... l_i
    array set m [list]
    # initialization
    set m(0) 0    

    # auxiliary array
    array set s [list]

    # the actual algorithm
    #
    # At the end m(n) denotes the total badness of the full text
    #
    # In the optimal splitting of text l_1, ..., l_i,
    # s(i) has the meaning that the last line starts with l_k.
    set max_penalty [expr { 2*pow($L,3) }]
    for {set i 1} { $i < $n + 1 } {incr i} {

        set m($i) $max_penalty
        set s($i) 1

        set k $i
        while { ([length $wl $k $i] <= $L) && ($k > 0) } {
            set penalty [expr { entier(pow(($L - [length $wl $k $i]),3) + $m([expr { $k - 1 }])) }]
            if { $penalty < $m($i) } {
                set m($i) $penalty
                set s($i) $k
            }
            incr k -1
        }
    }

    #printvars

    # actually do the splitting by working backwards
    set result ""
    set line 1
    while { $n > 1 } {
        set from [expr { $s($n) - 1 }]
        set to [expr { $n - 1 }]
        set result "[lrange $words $from $to] \n $result"
        set n $from
        incr line 1
    }

    return $result
}


proc ::textalign::adjust {text {L 80}} {
    set result ""
    set paragraphs [str splitx $text "\n\n"]
    foreach paragraph $paragraphs {
        set paragraph [string map {\x0a " " \xa0 " " \n " " \r " "} $paragraph]
        append result [breakline $paragraph $L] "\n"
    }
    return $result
}
