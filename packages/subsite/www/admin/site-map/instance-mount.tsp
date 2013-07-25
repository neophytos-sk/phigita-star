ad_page_contract {
  @author Neophytos Demetriou (k2pts@cytanet.com.cy)
} {
  package_id:naturalnum
  node_id:integer,notnull
}


db_transaction {
  db_dml mount {
    update site_nodes
    set object_id = :package_id
    where node_id = :node_id
    and object_id is null
  }

  site_nodes_sync
}


throw REDIRECT ""
