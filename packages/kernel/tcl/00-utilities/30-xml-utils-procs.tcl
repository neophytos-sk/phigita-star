# It would be nice if this could be used without the XOACS, so we're not
# using ad_proc constructs for this at this point.



#
# We need some very simple features here:
#    - parse
#    - get root node
#    - get first real node
#    - get children node
#    - get children node with a particular name
#    - get attribute
#    - get value
#

# Parse a document and return a doc_id
proc xml_parse args {

    if {[lindex $args 0] == "-persist"} {
	set docId [dom parse -simple [lindex $args 1]]
    } else {
	set docId [dom parse -simple [lindex $args 0]]
    }

    return $docId
}

proc xml_prepare_data {xml_data} {
        # remove comments
        regsub -all {<!--[^>]*-->} $xml_data "" new_xml_data
        return $new_xml_data
}


# Free the doc
proc xml_doc_free {docId} {
    $docId delete 
}

# Get root node
proc xml_doc_get_root_node {docId} {
    return [$docId documentElement]
}


# Get first node
proc xml_doc_get_first_node {docId} {

    set root [$docId documentElement]

    ns_log Notice $root

    return [$root firstChild]

}

# Get first node with a given name
proc xml_doc_get_first_node_by_name {docId name} {

    set firstNode [lindex [${docId} getElementsByTagName $name] 0]

    return $firstNode
}

# Get children nodes
proc xml_node_get_children {nodeObject} {
    return [$nodeObject childNodes]
}

# Find nodes of a parent that have a given name
proc xml_node_get_children_by_name {nodeObject name} {
    return [$nodeObject getElementsByTagName $name]
}

proc xml_node_get_first_child_by_name {nodeObject name} {
    return [lindex [$nodeObject getElementsByTagName $name] 0]
}

# Get Node Name
proc xml_node_get_name {nodeObject} {
    return [$nodeObject nodeName]
}

# Get Node Attribute
proc xml_node_get_attribute {nodeObject attributeName} {
    return [$nodeObject getAttribute $attributeName]
}

# Get Content
proc xml_node_get_content {nodeObject} {
    return [$nodeObject text]
}
