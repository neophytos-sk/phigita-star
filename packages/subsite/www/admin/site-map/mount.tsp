ad_page_contract {
    @author Neophytos Demetriou
} {
    node_id
    {return_url "/"}
}

set package_id [db_nextval acs_object_id_seq]
set ds:packages [db_list_of_ns_sets all_packages "
        select package_key, pretty_name
        from apm_package_types
        where not (apm_package__singleton_p(package_key) = 1 and
              apm_package__num_instances(package_key) >= 1)
        order by pretty_name
"]

set ds:unmounted_instances [db_list_of_ns_sets unmounted_instances {

    select package_id, package_key,
           acs_object__name(package_id) as name,
           apm_package__singleton_p(package_key) as singleton_p,
           tree_sk as url
    from apm_packages left outer join site_nodes on (object_id = package_id)
    order by name

}]

tmpl::master -onload  {javascript:document.forms['package-mount'].elements['instance_name'].focus();document.forms['package-mount'].elements['instance_name'].select()} {

    form -name "package-mount" -action package-mount {
	input -name "return_url" -type "hidden" -value ${return_url}
	input -name "node_id" -type "hidden" -value ${node_id}
	input -name "package_id" -type "hidden" -value ${package_id}

	

	h2 { t "Create & Mount New Instance" }
	input -name "instance_name" -type "text" -value "Untitled"
	select -name "package_key" {
	    foreach setId ${ds:packages} {
		option -value [ns_set get ${setId} package_key] {
		    t [ns_set get ${setId} pretty_name]
		}
	    }
	}
	input -name "pageroot" -type "text" -value "www"
	input -type submit -value "New"

	p

	h2 { t "Existing Package Instances" }

	p

	table { 
	    tr {
		th { t "Instance Name" }
		th { t "Package Type" }
		th { t "URL" }
	    }
	    foreach setId ${ds:unmounted_instances} {
		tr {
		    td {
			a -href "instance-mount?package_id=[ns_set get ${setId} package_id]&node_id=${node_id}" {
			    t [ns_set get ${setId} name]
			}
		    }
		    td {
			t "[ns_set get ${setId} package_key]"
		    }
		    td {
			t "[ns_set get ${setId} url]"
		    }
		}
	    }
	}
    }
}
