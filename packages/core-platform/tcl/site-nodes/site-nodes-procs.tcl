ad_library {

    Site Nodes API

    @author Neophytos Demetriou (k2pts@phigita.net)
    @last_modified 2010-11-07
    @creation_date 2000-09-06
    @version $Id: site-nodes-procs.tcl,v 1.1.1.1 2002/11/22 09:47:32 nkd Exp $

}

namespace eval site_node {

    ad_proc -public new {
        {-name:required}
        {-parent_id:required}
        {-directory_p t}
        {-pattern_p t}
    } {
        create a new site node
    } {
        set extra_vars [ns_set create]
        ns_set put $extra_vars name [ns_urlencode $name]
        ns_set put $extra_vars parent_id $parent_id
        ns_set put $extra_vars directory_p $directory_p
        ns_set put $extra_vars pattern_p $pattern_p

        set node_id [package_instantiate_object -extra_vars $extra_vars site_node]

        update_cache -node_id $node_id

        return $node_id
    }

    ad_proc -public delete {
        {-node_id:required}
    } {
        delete the site node
    } {
        db_exec_plsql delete_site_node {
            select site_node__delete(:node_id);
	}
        update_cache -node_id $node_id
    }

    ad_proc -public mount {
        {-node_id:required}
        {-object_id:required}
    } {
        mount object at site node
    } {
        db_dml mount_object {}
        update_cache -node_id $node_id
    }

    ad_proc -public unmount {
        {-node_id:required}
    } {
        unmount an object from the site node
    } {
        db_dml unmount_object {}
        update_cache -node_id $node_id
    }

    ad_proc -private init_cache {} {
        initialize the site node cache
    } {
        nsv_array reset site_nodes [list]
        nsv_array reset site_node_urls [list]

        db_foreach select_site_nodes {
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
	} {
            set node(url) $url
            set node(node_id) $node_id
            set node(parent_id) $parent_id
            set node(directory_p) $directory_p
            set node(pattern_p) $pattern_p
            set node(object_id) $object_id
            set node(object_type) $object_type
	    set node(package_type_id) $package_type_id
            set node(package_key) $package_key
            set node(package_id) $package_id
	    set node(instance_name) $instance_name
	    set node(pageroot) $pageroot
	    set node(subsite_id) [site_node_closest_ancestor_package -url $node(url) "subsite"]
	    set node(host) $host

            nsv_set site_nodes $url [array get node]
            nsv_set site_node_urls $node_id $url
        }

    }

    ad_proc -private update_cache {
        {-node_id:required}
    } {
        if {[db_0or1row select_site_node {
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
	}]} {
            set node(url) $url
            set node(node_id) $node_id
            set node(parent_id) $parent_id
            set node(directory_p) $directory_p
            set node(pattern_p) $pattern_p
            set node(object_id) $object_id
            set node(object_type) $object_type
            set node(package_key) $package_key
            set node(package_id) $package_id
            set node(instance_name) $instance_name
            set node(pageroot) $pageroot

            nsv_set site_nodes $url [array get node]
            nsv_set site_node_urls $node_id $url

        } else {
            set url [get_url -node_id $node_id]

            if {[nsv_exists site_nodes $url]} {
                nsv_unset site_nodes $url
            }

            if {[nsv_exists site_node_urls $node_id]} {
                nsv_unset site_node_urls $node_id
            }
        }
    }

    ad_proc -public get {
        {-url ""}
        {-node_id ""}
    } {
        returns an array representing the site node that matches the given url

        either url or node_id is required, if both are passed url is ignored
    } {
        if {[empty_string_p $url] && [empty_string_p $node_id]} {
            error "site_node::get \"must pass in either url or node_id\""
        }

        if {![empty_string_p $node_id]} {
            return [get_from_node_id -node_id $node_id]
        }

        if {![empty_string_p $url]} {
            return [get_from_url -url $url]
        }

    }

    ad_proc -public get_from_node_id {
        {-node_id:required}
    } {
        returns an array representing the site node for the given node_id
    } {
        return [get_from_url -url [get_url -node_id $node_id]]
    }

    ad_proc -public get_from_url {
        {-url:required}
    } {
        returns an array representing the site node that matches the given url
    } {

        # attempt an exact match
        if {[nsv_exists site_nodes $url]} {
            return [nsv_get site_nodes ${url}]
        }

        # attempt adding a / to the end of the url if it doesn't already have
        # one
        if {![string equal [string index $url end] "/"]} {
            append url "/"
        }
	if {[nsv_exists site_nodes $url]} {
	    return [nsv_get site_nodes ${url}]
	}


        # chomp off part of the url and re-attempt
        while {![empty_string_p $url]} {
            set url [string trimright $url /]
            set url [string range $url 0 [string last / $url]]

            if {[nsv_exists site_nodes $url]} {
                array set node [nsv_get site_nodes ${url}]

                if {[string equal $node(pattern_p) t] && ![empty_string_p $node(object_id)]} {
                    return [array get node]
                }
            }
        }

        error "site node not found at url $url"
    }

    ad_proc -public get_from_object_id {
        {-object_id:required}
    } {
        return the site node associated with the given object_id

        WARNING: Returns only the first site node associated with this object.
    } {
        return [get -url [lindex [get_url_from_object_id -object_id $object_id] 0]]
    }

    ad_proc -public get_all_from_object_id {
        {-object_id:required}
    } {
        return a list of site nodes associated with the given object_id
    } {
        set node_id_list [list]

        foreach url [get_url_from_object_id -object_id $object_id] {
            lappend node_id_list [get -url $url]
        }

        return $node_id_list
    }

    ad_proc -public get_url {
        {-node_id:required}
    } {
        return the url of this node_id
    } {
        set url ""
        if {[nsv_exists site_node_urls $node_id]} {
            set url [nsv_get site_node_urls $node_id]
        }

        return $url
    }

    ad_proc -public get_url_from_object_id {
        {-object_id:required}
    } {
        returns a list of urls for site_nodes that have the given object
        mounted or the empty list if there are none
    } {
        return [db_list select_url_from_object_id {
            select ltree2url(tree_sk) as url
            from site_nodes
            where object_id = :object_id	    
	}]
    }

    ad_proc -public get_node_id {
        {-url:required}
    } {
        return the node_id for this url
    } {
        array set node [get -url $url]
        return $node(node_id)
    }

    ad_proc -public get_node_id_from_object_id {
        {-object_id:required}
    } {
        return the site node id associated with the given object_id
    } {
        return [get_node_id -url [lindex [get_url_from_object_id -object_id $object_id] 0]]
    }

    ad_proc -public get_parent_id {
        {-node_id:required}
    } {
        return the parent_id of this node
    } {
        array set node [get -node_id $node_id]
        return $node(parent_id)
    }

    ad_proc -public get_parent {
        {-node_id:required}
    } {
        return the parent node of this node
    } {
        array set node [get -node_id $node_id]
        return [get -node_id $node(parent_id)]
    }

    ad_proc -public get_object_id {
        {-node_id:required}
    } {
        return the object_id for this node
    } {
        array set node [get -node_id $node_id]
        return $node(object_id)
    }

}

ad_proc -deprecated site_node_create {
    {-new_node_id ""}
    {-directory_p "t"}
    {-pattern_p "t"}
    parent_node_id
    name
} {
    Create a new site node.  Returns the node_id
    @see site_node::new
} {
    return [site_node::new \
        -name $name \
        -parent_id $parent_node_id \
        -directory_p $directory_p \
        -pattern_p $pattern_p \
    ]
}

ad_proc -deprecated site_node_create_package_instance {
    { -package_id 0 }
    { -sync_p "t" }
    node_id
    instance_name
    context_id
    package_key
} {
    Creates a new instance of the specified package and flushes the
    in-memory site map (if sync_p is t).

    DRB: I've modified this so it doesn't call the package's post instantiation proc until
    after the site node map is updated.   Delaying the call in this way allows the package to
    find itself in the map.   The code that mounts a subsite, in particular, needs to be able
    to do this so it can find the nearest parent node that defines an application group (the
    code in aD ACS 4.2 was flat-out broken).

    @author Michael Bryzek (mbryzek@arsdigita.com)
    @creation-date 2001-02-05

    @return The package_id of the newly mounted package
} {

    set package_id [apm_package_create_instance $instance_name $context_id $package_key]
    site_node::mount -node_id $node_id -object_id $package_id
    apm_package_call_post_instantiation_proc $package_id $package_key
    return $package_id
}

ad_proc -public site_node_delete_package_instance {
    {-node_id:required}
} {
    Wrapper for apm_package_instance_delete

    @author Arjun Sanyal (arjun@openforc.net)
    @creation-date 2002-05-02
} {
    db_transaction {
        set package_id [site_node::get_object_id -node_id $node_id]
        site_node::unmount -node_id $node_id
        apm_package_instance_delete $package_id
    }
}

ad_proc -public site_node_mount_application {
    {-sync_p "t"}
    {-return "package_id"}
    parent_node_id
    instance_name
    package_key
    package_name
} {
    Creates a new instance of the specified package and mounts it
    beneath parent_node_id.

    @author Michael Bryzek (mbryzek@arsdigita.com)
    @creation-date 2001-02-05

    @param sync_p If "t", we flush the in-memory site map
    @param return You can specify what is returned: the package_id or node_id
           (now ignored, always return package_id)
    @param parent_node_id The node under which we are mounting this
           application
    @param instance_name The instance name for the new site node
    @param package_key The type of package we are mounting
    @param package_name The name we want to give the package we are
           mounting.
    @return The package id of the newly mounted package or the new
           node id, based on the value of $return

} {
    # if there is an object mounted at the parent_node_id then use that
    # object_id, instead of the parent_node_id, as the context_id
    array set node [site_node::get -node_id $parent_node_id]
    set context_id $node(object_id)

    if {[empty_string_p $context_id]} {
        set context_id $parent_node_id
    }

    return [site_node_apm_integration::new_site_node_and_package \
        -name $instance_name \
        -parent_id $parent_node_id \
        -package_key $package_key \
        -instance_name $package_name \
        -context_id $context_id \
    ]
}

ad_proc -public site_map_unmount_application {
    { -sync_p "t" }
    { -delete_p "f" }
    node_id
} {
    Unmounts the specified node.

    @author Michael Bryzek (mbryzek@arsdigita.com)
    @creation-date 2001-02-07

    @param sync_p If "t", we flush the in-memory site map
    @param delete_p If "t", we attempt to delete the site node. This
         will fail if you have not cleaned up child nodes
    @param node_id The node_id to unmount

} {
    db_transaction {
        site_node::unmount -node_id $node_id

        if {[string equal $delete_p t]} {
            site_node::delete -node_id $node_id
        }
    }
}

ad_proc -deprecated site_node {url} {
    Returns an array in the form of a list. This array contains
    url, node_id, directory_p, pattern_p, and object_id for the
    given url. If no node is found then this will throw an error.
} {
    return [site_node::get -url $url]
}

ad_proc -public site_node_id {url} {
    Returns the node_id of a site node. Throws an error if there is no
    matching node.
} {
    return [site_node::get_node_id -url $url]
}

ad_proc -public site_nodes_sync {args} {
    Brings the in memory copy of the url hierarchy in sync with the
    database version.
} {
    site_node::init_cache
}

ad_proc -public site_node::get_element {
    {-node_id ""}
    {-url ""}
    {-element:required}
} {
    returns an element from the array representing the site node that matches the given url

    either url or node_id is required, if both are passed url is ignored

    The array elements are: package_id, package_key, object_type, directory_p, 
    instance_name, pattern_p, parent_id, node_id, object_id, url.

    @see site_node::get
} {
    array set node [site_node::get -node_id $node_id -url $url]
    return $node($element)
}

ad_proc -public site_node::get_children {
    {-all:boolean}
    {-package_type {}}
    {-package_key {}}
    {-filters {}}
    {-element {}}
    {-node_id:required}
} {
    This proc gives answers to questions such as: What are all the package_id's 
    (or any of the other available elements) for all the instances of package_key or package_type mounted
    under node_id xxx?

    @param node_id       The node for which you want to find the children.

    @option all          Set this if you want all children, not just direct children
    
    @option package_type If specified, this will limit the returned nodes to those with an
                         package of the specified package type (normally apm_service or 
                         apm_application) mounted. Conflicts with the -package_key option.
    
    @param package_key   If specified, this will limit the returned nodes to those with a
                         package of the specified package key mounted. Conflicts with the
                         -package_type option.

    @param filters       Takes a list of { element value element value ... } for filtering 
                         the result list. Only nodes where element is value for each of the 
                         filters in the list will get included. For example: 
                         -filters { package_key "acs-subsite" }.
                     
    @param element       The element of the site node you wish returned. Defaults to url, but 
                         the following elements are available: object_type, url, object_id,
                         instance_name, package_type, package_id, name, node_id, directory_p.
    
    @return A list of URLs of the site_nodes immediately under this site node, or all children, 
    if the -all switch is specified.
    
    @author Lars Pind (lars@collaboraid.biz)
} {
    if { ![empty_string_p $package_type] && ![empty_string_p $package_key] } {
        error "You may specify either package_type, package_key, or filter_element, but not more than one."
    }

    if { ![empty_string_p $package_type] } {
        lappend filters package_type $package_type
    } elseif { ![empty_string_p $package_key] } {
        lappend filters package_key $package_key
    }

    set node_url [site_node::get_url -node_id $node_id]

    if { !$all_p } { 
        set child_urls [list]
        set s [string length "$node_url"]
        # find all child_urls who have only one path element below node_id
        # by clipping the node url and last character and seeing if there 
        # is a / in the string.  about 2x faster than the RE version.
        foreach child_url [nsv_array names site_nodes "${node_url}?*"] {
            if { [string first / [string range $child_url $s end-1]] < 0 } {
                lappend child_urls $child_url
            }
        }
    } else {
        set child_urls [nsv_array names site_nodes "${node_url}?*"]
    }


    if { [llength $filters] > 0 } {
        set return_val [list]
        foreach child_url $child_urls {
            array unset site_node
            if {![catch {array set site_node [nsv_get site_nodes $child_url]}]} {

                set passed_p 1
                foreach { elm val } $filters {
                    if { ![string equal $site_node($elm) $val] } {
                        set passed_p 0
                        break
                    }
                }
                if { $passed_p } {
                    if { ![empty_string_p $element] } {
                        lappend return_val $site_node($element)
                    } else {
                        lappend return_val $child_url
                    }
                }
            }
        }
    } elseif { ![empty_string_p $element] } {
        set return_val [list]
        foreach child_url $child_urls {
            array unset site_node
            if {![catch {array set site_node [nsv_get site_nodes $child_url]}]} {
                lappend return_val $site_node($element)
            }
        }
    }

    # if we had filters or were getting a particular element then we 
    # have our results in return_val otherwise it's just urls
    if { ![empty_string_p $element]
         || [llength $filters] > 0} {
        return $return_val
    } else {
        return $child_urls
    }
}



ad_proc -public site_node_closest_ancestor_package {
    { -default "" }
    { -url "" }
    package_key
} {
    Finds the package id of a package of specified type that is
    closest to the node id represented by url (or by ad_conn url).Note
    that closest means the nearest ancestor node of the specified
    type, or the current node if it is of the correct type.

    <p>

    Usage:

    <pre>
    # Pull out the package_id of the subsite closest to our current node
    set pkg_id [site_node_closest_ancestor_package "subsite"]
    </pre>

    @author Michael Bryzek (mbryzek@arsdigita.com)
    @creation-date 1/17/2001

    @param default The value to return if no package can be found
    @param current_node_id The node from which to start the search
    @param package_key The type of the package for which we are looking

    @return <code>package_id</code> of the nearest package of the
    specified type (<code>package_key</code>). Returns $default if no
    such package can be found.

} {


    if {[empty_string_p $url]} {
	set url [ad_conn url]
    }

    # Try the URL as is.
    if {[catch {nsv_get site_nodes $url} result] == 0} {
	array set node $result
	if { [string eq $node(package_key) $package_key] } {
	    return $node(package_id)
	}
    }

    # Add a trailing slash and try again.
    if {[string index $url end] != "/"} {
	append url "/"
	if {[catch {nsv_get site_nodes $url} result] == 0} {
	    array set node $result
	    if { [string eq $node(package_key) $package_key] } {
		return $node(package_id)
	    }
	}
    }

    # Try successively shorter prefixes.
    while {$url != ""} {
	# Chop off last component and try again.
	set url [string trimright $url /]
	set url [string range $url 0 [string last / $url]]
	
	if {[nsv_exists site_nodes ${url}]} {
	    array set node [nsv_get site_nodes ${url}]
	    if {$node(pattern_p) == "t" && $node(object_id) != "" && [string eq $node(package_key) $package_key] } {
		return $node(package_id)
	    }
	}
    }

    return $default
}

ad_proc -public site_node_closest_ancestor_package_url {
    { -default "" }
    { -package_key "subsite" }
} {
    Returns the url stub of the nearest application of the specified
    type.

    @author Michael Bryzek (mbryzek@arsdigita.com)
    @creation-date 2001-02-05

    @param package_key The type of package for which we're looking
    @param default The default value to return if no package of the
    specified type was found

} {
    set subsite_pkg_id [site_node_closest_ancestor_package $package_key]
    if {[empty_string_p $subsite_pkg_id]} {
	# No package was found... return the default
	return $default
    }

    return [lindex [site_node::get_url_from_object_id -object_id $subsite_pkg_id] 0]
}



proc site_node__get_from_url { url } {

    # attempt an exact match
    if {[nsv_exists site_nodes $url]} {
	return [nsv_get site_nodes ${url}]
    }

    # attempt adding a / to the end of the url if it doesn't already have
    # one
    if { [string index $url end] ne {/} } {
	append url "/"
    }
    if {[nsv_exists site_nodes $url]} {
	return [nsv_get site_nodes ${url}]
    }


    # chomp off part of the url and re-attempt
    while { ${url} ne {} } {
	set url [string trimright $url /]
	set url [string range $url 0 [string last {/} $url]]

	if {[nsv_exists site_nodes $url]} {
	    array set node [nsv_get site_nodes ${url}]

	    if { $node(pattern_p) eq {t} && $node(object_id) ne {} } {
		return [array get node]
	    }
	}
    }

    error "site node not found at url $url"
}
