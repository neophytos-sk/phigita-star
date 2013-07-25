ad_page_contract {
    @author Neophytos Demetriou
} {
    cluster_sk:trim,notnull
}


try {
    set connObject [DB_Connection new -pool newsdb]
    $connObject do "update xo.xo__clustering__class set live_p='f' where cluster_sk=[ns_dbquotevalue $cluster_sk]"
} catch {*} {
    ns_log notice "Error: Cluster disabling failed..."
} finally {
    $connObject destroy
}

ad_returnredirect ..