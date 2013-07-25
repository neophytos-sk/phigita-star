source /var/lib/naviserver/service-phgt-0/packages/persistence/pdl/ZZ-aggregators.tcl
ad_page_contract {
    @author Neophytos Demetriou
} {
    url:trim,notnull
    {guard:trim ""}
}

set o [::sw::agg::Url new -mixin db::Object -pool newsdb]
${o} url $url
${o} guard $guard
[${o} getConn] do [subst {
    update [$o info.db.table] set
         guard=[$o quoted guard]
    where 
        url=[$o quoted url]
}]


ad_returnredirect .