ad_page_contract {
    @author Neophytos Demetriou
} {
    node_id:integer
}


db_transaction {
  db_dml unmount {
    update site_nodes
    set object_id = null
    where node_id = :node_id
  }

  site_nodes_sync
}


ad_returnredirect ""
