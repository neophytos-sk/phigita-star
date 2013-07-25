ad_page_contract {

    @author Neophytos Demetriou

} {
    parent_id:notnull,integer
    {comment:notnull,allhtml ""}
}


set id [Blog_Item_Comment autovalue "User [ad_conn user_id]"]

tmpl::master -title "Preview Comment" -context_bar [ad_context_bar "Preview Comment"] {

    table -width "100%" -border "0" -cellpadding "4" -cellspacing "0" {
        tr -bgcolor "#EEF3FB" {
            td -colspan "2" -align "left" {
                font -face "arial" -size "-1" {
		    t -disableOutputEscaping { 
			Your comment has not yet been saved.
			The text of your comment appears below.
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
			    t ${id}
			    p
			    t -disableOutputEscaping [stx_to_html  [stx_from_input ${comment}] -root_of_hierarchy [User set id]-[ad_conn user_id]]
			}
		    }
		}
	    }
	}
    }

p

    form -action comment-add-3 -method POST {
	input -type "hidden" -name "id" -value ${id}
	input -type "hidden" -name "parent_id" -value ${parent_id}
	input -type "hidden" -name "comment" -value ${comment}
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
