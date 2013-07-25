ad_page_contract {
    @author Neophytos Demetriou
} {
    q:trim,optional
}


set base .
set maxlength 20000

if { ![info exists q] } {
    ad_returnredirect ${base}
}

set text [string range ${q} 0 ${maxlength}]

set dictionary en.multi
set encoding utf-8
set mode sgml
set o [::SpellChecker new -volatile  \
	   -dictionary ${dictionary} \
	   -encoding ${encoding}     \
	   -mode ${mode}] 

set result [${o} suggestText ${text}]

tmpl::master -title "Suggestions for " -context_bar [ad_context_bar] {

    t ${result}

}