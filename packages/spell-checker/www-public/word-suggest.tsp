ad_page_contract {
    @author Neophytos Demetriou
} {
    q:trim,notnull
}

set base .
set maxlength 80


set word [string range ${q} 0 ${maxlength}]

if { [regexp -- {[a-zA-Z0-9\s]+} ${q}] } {
    set dictionary en
} else {
    set dictionary el
}


set encoding utf-8
set mode sgml
set o [::SpellChecker new -volatile  \
	   -dictionary ${dictionary} \
	   -encoding ${encoding}     \
	   -mode ${mode}] 

set correct_p [${o} checkWord ${word}]
set wordlist [${o} suggestWord ${word}]

tmpl::master -title "${word} - Spell Check" -context_bar [ad_context_bar "Suggested Words for \"${word}\""] {

    div -style "margin:25;padding:10;width:468;background:#f0f0f0;float:left;" {
	b {
	    if { ${correct_p} } {
		font -color "#006600" {
		    t "[::util::doublequote ${word}] is spelled correctly."
		}
	    } else {
		font -color "#990033" {
		    t "[::util::doublequote ${word}] is misspelled."
		}
	    }
	}
    
	p
	if { [llength ${wordlist}] } {
	    b { t "Here are some suggestions:" }
	    div {
		ol {
		    foreach suggested_word ${wordlist} {
			li {
			    if { ${dictionary} eq {en} } {
				a -href "http://www.google.com/search?ie=utf-8&oe=utf-8&q=define:${suggested_word}" {
				    t ${suggested_word}
				}
			    } else {
				t ${suggested_word}
			    }					
			}
		    }
		}
	    }
	}

	div {
	    ::xo::google::adsense::slot 2239820321 468 60
	}
    }

    div -class little -style "padding:8;margin-left:550;border-left: 1px solid #efefef;" {
	::xo::google::adsense::slot 2239820321 160 600
    }
}