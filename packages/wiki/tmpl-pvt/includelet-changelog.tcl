ad_page_contract {
    @author Neophytos Demetriou
} {
    id:integer,notnull
    live_revision_id:integer,notnull
}

set page_id $id


set user_id [ad_conn user_id]
set limit 4
set pathexp [list "User $user_id"]
set revdata [::db::Set new \
		  -select {page_id id title creation_user creation_date last_update} \
		  -pathexp ${pathexp} \
		  -type ::wiki::Page_Revision \
		  -where [list "page_id=[ns_dbquotevalue $page_id]"] \
		  -limit ${limit} \
		  -order "last_update desc"]
${revdata} load



::xo::html::add_style {
    .meta_bubble {background:#E5ECF9;border:1px solid #fff;font:12px arial,sans-serif;}
    .box_inner {padding: 0 13px;margin:0;}
}


div -class "meta_bubble" {
    div -class "box_inner" {
	div { t "Change log" }
	set o [$revdata head]
	ul {
	    li { 
		t "r[$o set id] by [$o set creation_user] on [$o set last_update]"
	    }
	}
    }
}
div -class "meta_bubble" {
    div -class "box_inner" {
	div { t "Older revisions" }
	ul {
	    foreach o [$revdata tail] {
		li {
		    t "r[$o set id] by [$o set creation_user] on [$o set last_update] "
		    a -href "diff?compare_revision_id=[$o set id]&revision_id=${live_revision_id}" { t "diff" }
		}
	    }
	}
	div {
	    a -class fl -href [export_vars -base "revisions" {page_id}] {
		t "All revisions of this file"
	    }
	}
    }
}

div -class "meta_bubble" {
    div -class "box_inner" {
	div { t "File info" }
	t "Size:"
	t "Lines:"
	a -href "view-raw-file" { t "view raw file" }
    }
}