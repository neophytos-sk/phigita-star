ad_page_contract {
    @author Neophytos Demetriou
} {
    page_id:integer,notnull
    revision_id:integer,notnull
    {return_url ""}
}

set pathexp [list "User [ad_conn user_id]"]
set p [::wiki::Page 0or1row -pathexp $pathexp -id $page_id]
set r [::wiki::Page_Revision 0or1row -pathexp $pathexp -id $revision_id]

$p mixin ::db::Object
$p set id
$p set title [$r set title]
$p set content [$r set content]
$p set live_revision_id $revision_id
$p do self-update

if { $return_url eq {} } {
    set return_url "page-revisions?page_id=$page_id"
}
ad_returnredirect $return_url