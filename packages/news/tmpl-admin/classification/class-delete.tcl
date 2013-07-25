source /var/lib/naviserver/service-phgt-0/packages/persistence/pdl/45-classification.tcl
ad_page_contract {
    @author Neophytos Demetriou
} {
    id:naturalnum,notnull
}

set o [::classification::Class new -mixin db::Object -pool newsdb]
${o} id $id
${o} do self-delete

ad_returnredirect .