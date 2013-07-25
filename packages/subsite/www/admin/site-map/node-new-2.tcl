ad_page_contract {
    @author Neophytos Demetriou
} {
    node_id
    node_parent_id
    node_name
    {node_directory_p "f"}
    {node_pattern_p "f"}
}

set node_creation_user [ad_verify_and_get_user_id]
set node_ip_address [ad_conn peeraddr]

db_exec_plsql site_node__new { 
    select site_node__new(
			  :node_id, 
			  :node_parent_id, 
			  :node_name, 
			  null,
			  :node_directory_p, 
			  :node_pattern_p, 
			  :node_creation_user, 
			  :node_ip_address
			  );
}

ad_returnredirect "?parent_id=${node_parent_id}"
