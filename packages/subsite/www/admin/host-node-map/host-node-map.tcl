proc ::xo::ns::dump {} {
	set result ""
	append result [::xo::ns::printset [ns_getform]]
	set vars [uplevel info vars]
	if { $vars ne {} } {
		append result "\n== info vars =="
	}
	foreach varname $vars {
		append result "\n${varname}=[uplevel set $varname]"
	}
	return $result
}

ad_page_contract {
	@author Neophytos Demetriou
} {
	host:trim,notnull
	node_id:integer
}


set sql "INSERT INTO host_node_map (host,node_id) VALUES ([ns_dbquotevalue $host],[ns_dbquotevalue $node_id])"
set conn [DB_Connection new]
$conn do $sql

#doc_return 200 text/plain [::xo::ns::dump]
ad_returnredirect .