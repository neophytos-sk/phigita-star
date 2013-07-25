namespace eval ::ttext {;}

proc ::ttext::trigrams text {
    set res {}
    set last " "
    set prev [string index $text 0]
    foreach word [lrange [split $text  ""] 1 end] {
        lappend res ${last}${prev}${word}
        set last $prev
        set prev $word
    }
    set res
}
