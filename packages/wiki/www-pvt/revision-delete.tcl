ad_page_contract {
    @author Neophytos Demetriou
} {
    page_id:integer,notnull
    revision_id:integer,notnull
}

set return_url "page-revisions?page_id=$page_id"

set pathexp [list "User [ad_conn user_id]"]

set p [::wiki::Page 0or1row -pathexp ${pathexp} -id $page_id]

if { $revision_id eq [$p set live_revision_id] } {
    ad_returnredirect $return_url
}


set r [::wiki::Page_Revision new -pathexp ${pathexp} -mixin ::db::Object]
${r} set id ${revision_id}
${r} set page_id ${page_id}
${r} do self-delete

ad_returnredirect $return_url


