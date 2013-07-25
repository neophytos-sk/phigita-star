ad_page_contract {
  @author Neophytos Demetriou (k2pts@cytanet.com.cy)
} {
  package_id:naturalnum
  node_id:integer,notnull
  instance_name:notnull
  package_key:notnull
	pageroot:notnull
}

set context_id [ad_conn package_id]


db_transaction {
#    set package_id [site_node_create_package_instance -package_id ${package_id} ${node_id} ${instance_name} ${context_id} ${package_key}]
    set package_id [apm_package_create_instance $instance_name $context_id $package_key]
#    site_node::mount -node_id $node_id -object_id $package_id
#    apm_package_call_post_instantiation_proc $package_id $package_key
#    return $package_id

} on_error {
    if {![db_string package_new_doubleclick_ck {
            select case when count(*) = 0 then 0 else 1 end
            from apm_packages
            where package_id = :package_id
    } -default 0]} {
	ad_return_complaint "Error Creating Package" "The following error was generated
		when attempting to create the package
	<blockquote><pre>
		[ad_quotehtml $errmsg]
	</pre></blockquote>"
    }
}

db_dml update_site_node "update site_nodes set pageroot=:pageroot where node_id=:node_id"

throw REDIRECT ""
