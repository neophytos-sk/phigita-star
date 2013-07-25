ad_page_contract {
    @author Neophytos Demetriou
} {
    id:integer,notnull
    {return_url:trim,notnull "."}
}

set o [::bboard::Message new -mixin ::db::Object]
$o set id $id
$o set __update(live_p) "NOT live_p"
$o do self-update
ad_returnredirect $return_url