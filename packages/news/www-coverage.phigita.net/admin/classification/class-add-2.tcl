source /var/lib/naviserver/service-phgt-0/packages/persistence/pdl/45-classification.tcl
ad_page_contract {
    @author Neophytos Demetriou
} {
    {tree_sk:trim,notnull ""}
}

set o [::classification::Class new -mixin db::Object -pool newsdb]
${o} tree_sk ${tree_sk}
${o} do self-insert

ad_returnredirect .