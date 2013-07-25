<?xml version="1.0"?>

<queryset>
    <rdbms><type>postgresql</type><version>7.1</version></rdbms>

    <fullquery name="site_node::delete.delete_site_node">
        <querytext>
            select site_node__delete(:node_id);
        </querytext>
    </fullquery>

    <fullquery name="site_node::init_cache.select_site_nodes">
        <querytext>
            select ltree2url(tree_sk) as url,
                   nodes.node_id,
                   nodes.parent_id,
                   nodes.directory_p,
                   nodes.pattern_p,
                   nodes.object_id,
                   nodes.pageroot,
                   (select acs_objects.object_type
                    from acs_objects
                    where acs_objects.object_id = nodes.object_id) as object_type,
                   nodes.package_key,
		   nodes.package_type_id,
                   nodes.package_id,
                   nodes.instance_name,
		   nm.host
            from (site_nodes s left join (select lhs.*, rhs.package_type_id from apm_packages lhs join apm_package_types rhs on (lhs.package_key=rhs.package_key)) pkg on s.object_id = pkg.package_id) nodes left outer join host_node_map nm on (nodes.node_id=nm.node_id)
        </querytext>
    </fullquery>

    <fullquery name="site_node::update_cache.select_site_node">
        <querytext>
            select ltree2url(tree_sk) as url,
                   nodes.node_id,
                   nodes.parent_id,
                   nodes.directory_p,
                   nodes.pattern_p,
                   nodes.object_id,
	           nodes.pageroot,
                   (select acs_objects.object_type
                    from acs_objects
                    where acs_objects.object_id = nodes.object_id) as object_type,
                   nodes.package_key,
                   nodes.package_id,
	           nodes.instance_name
            from (nodes s left join apm_packages pkg on s.object_id = pkg.package_id) nodes left outer join host_node_map nm on (nodes.node_id=nm.node_id)
           where nodes.node_id = :node_id
        </querytext>
    </fullquery>

    <fullquery name="site_node::get_url_from_object_id.select_url_from_object_id">
        <querytext>
            select ltree2url(tree_sk) as url
            from site_nodes
            where object_id = :object_id
        </querytext>
    </fullquery>

</queryset>
