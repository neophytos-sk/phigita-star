ad_page_contract {

    @author Neophytos Demetriou

} {
    id:integer,notnull
    {body:notnull,allhtml ""}
}

tmpl::master -title "Preview Entry" -context_bar [ad_context_bar "Preview Entry"] {

    small {
	t {
	    Your blog entry has not yet been saved. The text of your entry appears below. Click "Edit" to make changes to this text. Click "Save" when you're happy with what you've written. 
	}
    }

    p

    table -bgcolor "efefef" {
	tr {
	    td {
		table -bgcolor "ffffff" -width "600" {
		    tr {
			td {
			    t ${id}
			    p
			    t -disableOutputEscaping [stx_to_html [stx_from_input ${body}]]
			}
		    }
		}
	    }
	}
    }

p

    form -action comment-edit-3 -method POST {
	input -type "hidden" -name "id" -value ${id}
	input -type "hidden" -name "body" -value ${body}
	input -type "submit" -value "Save"
    }

}
