ad_page_contract {
    @author Neophytos Demetriou
} {
    url:notnull,trim
    active_p:boolean,notnull
    {return_url:trim "feeds"}
}

set o [::buzz::Feed new \
	   -mixin ::db::Object \
	   -pool newsdb \
	   -active_p $active_p]

$o do self-update "url = [ns_dbquotevalue $url]"
ad_returnredirect $return_url