ad_page_contract {

    @author Neophytos Demetriou

} {
    {subject:notnull ""}
    {body:notnull,allhtml ""}
    {anonymous_p:notnull,trim "t"}	
}

ad_maybe_redirect_for_registration


tmpl::master -title "Preview Question" -context_bar [ad_context_bar "Preview Question"] {

    table -width "100%" -border "0" -cellpadding "4" -cellspacing "0" {
        tr -bgcolor "#EEF3FB" {
            td -colspan "2" -align "left" {
                font -face "arial" -size "-1" {
		    t -disableOutputEscaping { 
			Your question has not yet been saved.
			The text of your question appears below.
		    }
                }
            }
        }
    }
    p

### Be sure to click <b>Save</b> when you're happy with what you've written. 

    table -bgcolor "efefef" {
	tr {
	    td {
		table -bgcolor "ffffff" -width "600" {
		    tr {
			td {
			    t ${subject}
			    p
			    t -disableOutputEscaping [stx_to_html  [stx_from_input ${body}]]
			}
		    }
		}
	    }
	}
    }

p

    form -action question-ask-3 -method POST {
	input -type "hidden" -name "anonymous_p" -value ${anonymous_p}
	input -type "hidden" -name "subject" -value ${subject}
	input -type "hidden" -name "body" -value ${body}
	input -type "submit" -value "Save"
    }
p

#

    table -width "100%" -border "0" -cellpadding "4" -cellspacing "0" {
        tr -bgcolor "#EEF3FB" {
            td -colspan "2" -align "left" {
                font -face "arial" -size "-1" {
		    t -disableOutputEscaping {
 			Click <b>Edit</b> to make changes to this text. 
			Click <b>Save</b> if you're happy with what you've written. 
		    }
                }
            }
        }
    }
}
