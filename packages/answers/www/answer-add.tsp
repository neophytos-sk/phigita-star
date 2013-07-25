ad_page_contract {
    @author Neophytos Demetriou
} {
    parent_id:notnull,integer
}

ad_maybe_redirect_for_registration

set question_obj [Question retrieve \
		      -pathexp [list Subsite [ad_conn subsite_id]] \
		      -output "*" \
		      -criteria "id = ${parent_id}"]

if {[string equal ${question_obj} ""]} {
    rp_returnnotfound
}

script -type "text/javascript" -src "/js/spell-checker/spell-checker.js"
  
script -type "text/javascript" {
    c {
        var SC = null;
        function initEditor() {
  
            SC = new SpellChecker();
            return false;
        }
    }
}


tmpl::master -title "Contribute an answer to [${question_obj} set subject]" -context_bar [ad_context_bar [list ${parent_id} "One Question"] "Contribute an answer"] -onload "initEditor()" {
    t -disableOutputEscaping {
        <table cellpadding="0" width="98%" cellspacing="0" border="0"> <tr> <td bgcolor="#49188f"><img src="/graphics/cleardot.gif" alt="" width="1" height="1"></td> </tr> <tr> <td bgcolor="#c2bddd"> <table cellpadding="2" width="100%" cellspacing="0" border="0"> <tr> <td> <b>Question</b> </td> <td align="right"> &nbsp;         </td> </tr> </table> </td> </tr> </table>
    }
    table -cellpadding "2" -width "98%" -cellspacing "0" -border "0" -class "" -bgcolor "#eeeeee" {
        tr -valign "top" {
            td -width "1%" -align "right" {
                font -size "-1" {
                    b { t "Subject: " }
                }
            }
            td -width "98%" -align "left" {
                font -size "-1" {
                    t [${question_obj} set subject]
                }
            }
        }
        tr -valign "top" {
            td -width "1%" -align "right" {
                font -size "-1" {
                    b { t "Date: " }
                }
            }
            td -width "98%" -align "left" {
                font -size "-1" {
                    t [lc_time_fmt [${question_obj} set creation_date] "%d-%b-%Y %r"]
                }
            }
        }
    }
    p
    t -disableOutputEscaping [stx_to_html [${question_obj} set body]]

    p
    small {

    div -style "background:#f0f0f0;width:600;padding:10;border:3px solid #e0e0e0;" {
        div -style "float:left;width:275;" {
            b { t "Do's" }
            dl {
                li { t "Provide accurate information" }
                li { t "Cross-check information whenever possible" }
                li { t "Be direct and detailed to the question asked" }
                li { t "Prioritize information by usefulness" }
		li { t "Use proper grammar and punctuation" }
		li { t "Be concise" }
		li { t "Proofread, proofread, proofread" }
            }
        }
        div -style "margin-left:300;" {
            b { t "Don'ts" }
            dl {
                li { t "Do not use copyrighted material without a citation" }
                li { t "Do not answer questions that:"
		    div -style "margin-left:15;" {
			t -disableOutputEscaping "&#183; "
			t "seek private information about individuals"
			br
			t -disableOutputEscaping "&#183; "
			t "seek assistance in conducting illegal activities"
			br
			t -disableOutputEscaping "&#183; "
			t "sell or advertise products"
			br
			t -disableOutputEscaping "&#183; "
			t "refer to adult content"
		    }
		}
                li { t "Do not answer if you are not (or cannot be)"
		    div -style "margin-left:15;" {
			t -disableOutputEscaping "&#183; "
			t "comfortable with the level of expertise required"
			br
			t -disableOutputEscaping "&#183; "
			t "objective due to a conflict of interest"
		    }
		}
		li { t "Do not use inappropriate language" }
            }
        }
    }
    p
	form -action answer-add-2 -method POST {
	    input -type hidden -name parent_id -value ${parent_id}
	    b { t "Enter your answer below:" }
	    br
	    b { a -href "" -style "text-decoration:none;font-variant: small-caps;" -class fl -onclick "SC.buttonPress('ta');return false;" { t \[[mc Spell_Check "Spell Check"]\] } }
	    t " "
                img -src /graphics/spell-check.gif -width 18 -height 18 -onclick "SC.buttonPress('ta')" -title [mc Spell_Check "Spell Check"]
            br
	    textarea -id "ta" -name "body" -rows "15" -cols "80" -wrap "soft"
	    p
	    input -type submit -value "Preview"
	}
    }
}
