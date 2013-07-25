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
                   nodes.instance_name,
		   nm.host
            from (site_nodes s left join apm_packages pkg on s.object_id = pkg.package_id) nodes left outer join host_node_map nm on (nodes.node_id=nm.node_id)
