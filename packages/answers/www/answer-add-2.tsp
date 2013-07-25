ad_page_contract {

    @author Neophytos Demetriou

} {
    parent_id:notnull,integer
    body:notnull,allhtml
}

ad_maybe_redirect_for_registration



tmpl::master -title "Preview Answer" -context_bar [ad_context_bar "Preview Answer"] {

    table -width "100%" -border "0" -cellpadding "4" -cellspacing "0" {
        tr -bgcolor "#EEF3FB" {
            td -colspan "2" -align "left" {
                font -face "arial" -size "-1" {
		    nt { 
			Your answer has not yet been saved.
			The text of your answer appears below.
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
			    #nt [stx_to_html  [stx_from_input ${body}]]
			    array set config [list root "[User set id]-[ad_conn user_id]" container_object_id ${parent_id} image_prefix "image/"]
			    ::xo::structured_text::stx_to_html config body html
			    nt $html
			}
		    }
		}
	    }
	}
    }

p

    form -action answer-add-3 -method POST {
	input -type "hidden" -name "parent_id" -value ${parent_id}
	input -type "hidden" -name "body" -value ${body}
	input -type "submit" -value "Save"
    }
p

#

    table -width "100%" -border "0" -cellpadding "4" -cellspacing "0" {
        tr -bgcolor "#EEF3FB" {
            td -colspan "2" -align "left" {
                font -face "arial" -size "-1" {
		    nt {
 			Click <b>Edit</b> to make changes to this text. 
			Click <b>Save</b> if you're happy with what you've written. 
		    }
                }
            }
        }
    }
}
