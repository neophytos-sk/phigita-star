source /var/lib/naviserver/service-phigita/packages/persistence/pdl/45-classification.tcl

ad_page_contract {
	@author Neophytos Demetriou
} {
    id:naturalnum,notnull
    prev_tree_sk:trim
    tree_sk:trim
}

set o [::classification::Class new -mixin db::Object -pool newsdb]
$o id $id
$o tree_sk $tree_sk

[$o getConn] beginTransaction
$o do self-update
[$o getConn] do [subst {
    update xo.xo__sw__agg__url set
        classification__tree_sk=[$o quoted tree_sk]
    where classification__tree_sk=[ns_dbquotevalue $prev_tree_sk]
}]
[$o getConn] endTransaction

ad_returnredirect .
