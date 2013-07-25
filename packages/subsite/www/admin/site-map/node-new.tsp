ad_page_contract {
    @author Neophytos Demetriou
} {
    parent_id
}

tmpl::master -onload  {javascript:document.forms['node-form'].elements['node_name'].focus()} {

	form -name "node-form" -action "node-new-2" {
	    input -name "node_id"\
		-type "hidden" \
		-value "[db_nextval acs_object_id_seq]"

	    input -name "node_parent_id" \
		-type "hidden" \
		-value "${parent_id}"

	    t "Name:"
	    input -name "node_name" \
		-type "text"
	    
	    br
	    t "Type:"
	    select -name "node_directory_p" {
		option -value "t" { t "Folder" }
		option -value "f" { t "Page" }
	    }

	    br
	    t "Should urls that are logical children of this node be mapped to this node?"
	    select -name "node_pattern_p" {
		option -value "t" { t "Yes" }
		option -value "f" { t "No" }
	    }
 
	    input -type submit
	}
}
