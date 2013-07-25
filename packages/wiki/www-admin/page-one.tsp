ad_page_contract {

    @author Neophytos Demetriou

} {
    root_object_id:integer,notnull
    id:integer,notnull
    {debug_p:boolean "f"}
}


set ctx_uid ${root_object_id}
set screen_name [db_string get_screen_name "select screen_name from users where user_id=:ctx_uid"]


set pathexp [list "User $ctx_uid"]
set wo [::db::One new -pathexp ${pathexp} -type ::wiki::Page -where [list "id = [ns_dbquotevalue ${id}]"]]



tmpl::master -title [${wo} get title] -context_bar [ad_context_bar "One Page"] -onload "" {

    div -style "float:right;font-size:120%;font-weight:bold;" {
	a -class "fl" -href "page-edit?id=[${wo} get id]" {
	    t "Edit Page"
	}
	if { [${wo} get shared_p] } {
	    t " | "
	    a -class "fl" -href "/~${screen_name}/wiki/${id}" {
		t "Jump to Public View"
	    }
	}
    }
    h1 {
	t [${wo} get title]
    }


    if { ${debug_p} } {
	code {
	    t -disableOutputEscaping [regsub -all {\n} [${wo} get content] {x}]
	}
    } else {
	t -disableOutputEscaping [stx_to_html [${wo} get content] -allow_href_p 0]
    }


}