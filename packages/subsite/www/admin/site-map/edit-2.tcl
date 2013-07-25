ad_page_contract {

    @author Neophytos Demetriou

} {
    package_id:integer
    node_id:integer
    instance_name:trim
    {return_url ""}
}

db_dml update_pkg_instance_info "update apm_packages set instance_name=:instance_name where package_id=:package_id"

site_node::update_cache -node_id $node_id


ad_returnredirect $return_url
