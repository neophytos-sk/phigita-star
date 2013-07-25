ad_page_contract {
    @author Neophytos Demetriou
} {
    id:integer,notnull
    {return_url "."}
}


set o [::bboard::Message new -mixin ::db::Object]
$o set id $id
$o do self-delete

ad_returnredirect $return_url