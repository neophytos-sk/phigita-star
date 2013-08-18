source /var/lib/naviserver/service-phigita/packages/persistence/pdl/45-classification.tcl
ad_page_contract {
    @author Neophytos Demetriou
} {
    url:trim,notnull
    {classification__edition_sk:trim ""}
}



set o [::sw::agg::Url new -mixin db::Object -pool newsdb]
${o} url $url
${o} set classification__edition_sk $classification__edition_sk
[$o getConn] beginTransaction
[${o} getConn] do [subst {
    update [$o info.db.table] set
         classification__edition_sk=[$o quoted classification__edition_sk]
    ,train_edition_p=[::util::decode $classification__edition_sk "" 'f' 't']
    where 
        url=[$o quoted url]
}]
[$o getConn] do [subst {
    update [$o info.db.table] set
        classification__edition_sk=[$o quoted classification__edition_sk]
    where
        channel_url_sha1=[ns_dbquotevalue [ns_sha1 ${url}]]
}]
[$o getConn] endTransaction

ad_returnredirect .