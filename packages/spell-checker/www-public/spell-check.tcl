ad_page_contract {
    @author Neophytos Demetriou
} {
    {dictionary:trim "el"}
    {content:allhtml ""}
}



set quoted_content [ad_quotehtml ${content}]

set encoding utf-8
set mode sgml
set o [::SpellChecker new -volatile  \
           -dictionary ${dictionary} \
           -encoding ${encoding}     \
           -mode ${mode}]

set suggested_words [${o} suggestText ${content}]

set comment {
    set sid [ns_aspell create ${dictionary} -encoding utf-8]
    ns_aspell setconfig ${sid} encoding utf-8
    set suggested_words [ns_aspell suggesttext ${sid} ${content}]
    ns_aspell destroy ${sid}
}

# Temporary Hack until the Engligh dictionary is fixed. Problem with strip-accents in en.multi
if { [string equal ${dictionary} el] } {
    set dictionaries el,en
} else {
    set dictionaries en,el
}




set count 0
set js_suggested_words ""
foreach {word offset suggestions} ${suggested_words} {

    lappend js_suggested_words "\"${word}\":\"[join ${suggestions} ,]\""
    
    incr offset [expr ${count} * 41]

    set last [expr ${offset} + [string length ${word}] -1]
    set content [string replace ${content} ${offset} ${last} "<span class=\"HA-spellcheck-error\">${word}</span>"]
    incr count
}
set js_suggested_words [join ${js_suggested_words} ,]

doc_return 200 text/html  [subst -nobackslashes -nocommands {
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="stylesheet" type="text/css" media="all" href="spell-check-style.css"/>
<script type="text/javascript">
    var suggested_words = { $js_suggested_words }; 
</script>
</head><body style="font-family:Arial Unicode MS,Arial;" onload="window.parent.finishedSpellChecking();"><pre class="preformatted" wrap="soft">${content}</pre><div id="HA-spellcheck-dictionaries">${dictionaries}</div></body></html>
}]
