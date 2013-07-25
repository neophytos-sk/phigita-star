ad_page_contract {
    @author Neophytos Demetriou
} {
    id:integer,notnull
    title:trim,notnull
    content:trim,notnull,stx
    {return_url ""}
}

set pathexp [list "User [ad_conn user_id]"]
set r [::wiki::Page_Revision 0or1row -pathexp $pathexp -id $id]

set page_id [$r set page_id]

$r mixin ::db::Object
$r set id
$r set title $title
$r set content $content
$r do self-update

if { $return_url eq {} } {
    set return_url "page-revisions?page_id=$page_id"
}
ad_returnredirect $return_url
