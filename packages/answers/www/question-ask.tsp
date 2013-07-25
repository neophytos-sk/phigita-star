ad_page_contract {

	@author Neophytos Demetriou

} {
	{title ""}
	{body ""}
}

ad_maybe_redirect_for_registration

set user_id [ad_conn user_id]


#script -type "text/javascript" -src "/js/spell-checker/spell-checker.js"
#script -type "text/javascript" {
#    c {
#        var SC = null;
#        function initEditor() {
#  
#            SC = new SpellChecker();
#            return false;
#        }
#    }
#}
#-onload "initEditor()"

tmpl::master -title "Ask Question" -context_bar [ad_context_bar "Ask Question"]  {
    table -width "100%" -border "0" -cellpadding "4" -cellspacing "0" {
        tr -bgcolor "#EEF3FB" {
            td -colspan "2" -align "left" {
                font -face "arial" -size "-1" {
                    t "Enter your question below."
                }
            }
        }
    }
    p
    small {
    div -style "background:#f0f0f0;width:600px;padding:10px;border:3px solid #e0e0e0;" {
	div -style "float:left;padding-left:10px;" {
	    b { t "How to phrase a question" }
	    dl {
		li { t "Break up multi-part questions" }
		li { t "Summarize your own findings" }
		li { t "Define the answer you want" }
		li { t "Provide as much detail as possible" }
		li { t "Recommended length is 75 to 300 words" }
	    }
	}
	div -style "margin-left:300px;" {
	    b { t "Refrain from asking questions that:" }
	    dl {
		li { t "Request private information about individuals" }
		li { t "Want assistance in conducting illegal activities" }
		li { t "Are meant to sell or advertise products" }
		li { t "Refer or relate to adult content" }
		li { t "Are homework or exam questions" }
	    }
	}
    }
	p
	form -action question-ask-2 -method POST {
	    b { t "Subject: " }
	    t "Enter the topic of your question (e.g. \"Hiking in New Mexico\")."
	    br
	    input -type "text" -name "subject" -value ${title} -maxlength "80" -size "80"	
	    p
	    b { t "Question: " }
	    t "The more details you provide, the better the results you'll receive."
	    br
	    b { a -href "" -style "text-decoration:none;font-variant: small-caps;" -class fl -onclick "SC.buttonPress('ta');return false;" { t \[[mc Spell_Check "Spell Check"]\] } }
	    t " "
                img -src /graphics/spell-check.gif -width 18 -height 18 -onclick "SC.buttonPress('ta')" -title [mc Spell_Check "Spell Check"]
            br
	    textarea -id "ta" -name "body" -rows "15" -cols "80" -wrap "soft" {
		t -disableOutputEscaping ${body}
}
	p
	b {
	  t "Author Identification:"
	}
	br
	    input -type "radio" -name "anonymous_p" -value "t" -id "anonymous_p:t" -checked "" 
		label -for "anonymous_p:t" {
			t "Anonymous"
		}
	   
	br
            input -type "radio" -name "anonymous_p" -value "f" -id "anonymous_p:f" 
                label -for "anonymous_p:f" {
                        t [db_string user_full_name "select first_names || ' ' || last_name from cc_users where user_id=:user_id"]
                }
            
	p

	    input -type "submit" -value "Preview"
#	    input -type "submit" -value "Save"
	    input -type "submit" -value "Cancel"
	}
    }

}
