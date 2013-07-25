

Class ::SpellChecker -parameter {
    {dictionary en}
    {encoding utf-8}
    {mode sgml}
}

::SpellChecker instproc init {} {
    my instvar dictionary encoding mode session_id
    set session_id [ns_aspell create ${dictionary} -encoding ${encoding}]
    ns_aspell setconfig ${session_id} encoding utf-8
    ns_aspell setconfig ${session_id} mode sgml
}

::SpellChecker instproc destroy {} {
    my instvar session_id
    if {[info exists session_id]} {
	ns_aspell destroy ${session_id}
    }
    next
}

::SpellChecker instproc checkWord {word} {
    my instvar session_id
    return [ns_aspell checkword ${session_id} ${word}]
}

::SpellChecker instproc suggestWord {word} {
    my instvar session_id
    return [ns_aspell suggestword ${session_id} ${word}]
}

::SpellChecker instproc suggestText {text} {
    my instvar session_id
    return [ns_aspell suggesttext ${session_id} ${text}]
}