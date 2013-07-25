ad_page_contract {
    @author Neophytos Demetriou
} {
    url_sha1:trim,notnull
    buzz_p:boolean
    {return_url:trim ".."}
}

set o [::sw::agg::Url new -mixin ::db::Object -buzz_p ${buzz_p}]

${o} do self-update "url_sha1=[ns_dbquotevalue ${url_sha1}]"

ad_returnredirect ${return_url}