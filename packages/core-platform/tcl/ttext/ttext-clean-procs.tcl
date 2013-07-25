namespace eval ::ttext {;}

proc ::ttext::ts_clean_text { text } {
    set regexp {([^ \-\.a-zA-Z0-9α-ωΑ-ΩΆΈΊΏΎΉΪΫήάέόώίύϋϊΐΰς])}
    return [regsub -all -- $regexp $text { }]
}