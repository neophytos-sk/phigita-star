ad_page_contract {

    @author Neophytos Demetriou

} {
    id:integer,notnull
    ctx_uid:integer
    {debug_p:boolean "f"}
}



db_1row get_screen_name "select first_names || ' ' || last_name as full_name, screen_name from cc_users where user_id=:ctx_uid"


set pathexp [list "User ${ctx_uid}"]
set wo [::db::One new -pathexp ${pathexp} -type ::wiki::Page -where [list shared_p "id = [ns_dbquotevalue ${id}]"]]


if { ![${wo} exists_p] } {
    rp_returnnotfound
    return
}

set owner_p [expr { [ad_conn user_id] == ${ctx_uid} }]

tmpl::blank {

    if { ${owner_p} } {
	div -style "float:right;font-size:120%;font-weight:bold;" {
	    a -class "fl" -href "/my/wiki/page-edit?id=[${wo} get id]" {
		t "Edit Page"
	    }
	}
    }
    div -style "float:right;" {
	t "Submitted on: [lc_time_fmt [${wo} get creation_date] "%Y-%m-%d"]"
	br
	t "Last updated: [lc_time_fmt [${wo} get last_update] "%Y-%m-%d"]"
    }
    div {
	h2 {
	    t [${wo} get title]
	}
    }
    if { ${debug_p} } {
	code {
	    t -disableOutputEscaping [regsub -all {\n} [${wo} get content] {x}]
	}
    } else {
	blockquote {
	    t -disableOutputEscaping [stx_to_html [${wo} get content]] ;# -allow_href_p 0
	}
    }



}