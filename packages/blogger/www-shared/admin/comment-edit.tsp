ad_page_contract {

    @author Neophytos Demetriou

} {
    id:integer,notnull
}
 
set user_id [ad_conn ctx_uid]
set comment_obj [Blog_Item_Comment retrieve \
		     -pathexp "User ${user_id}" \
		   -output "*" \
		   -criteria "id = [ns_dbquotevalue ${id}]"]


tmpl::master -title "Edit Comment" -context_bar [ad_context_bar "Edit Comment"] {

    b { t "Edit the comment below" }
    p
    small {
	form -action comment-edit-2 -method POST {
	    input -name "id" -type "hidden" -value ${id}
	    
	    b { t "Comment: " }
	    br
	    textarea -name "body" -rows "15" -cols "80" -wrap "soft" {
		t -disableOutputEscaping [${comment_obj} set comment]
	    }	
	    p
	    input -type "submit" -value "Preview"
	    input -type "submit" -value "Cancel"
	}
    }
}

