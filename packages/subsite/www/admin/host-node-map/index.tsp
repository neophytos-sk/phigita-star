set data [::db::Set new -select {host node_id {site_node__url(node_id) as url}} -from host_node_map]
$data load      

set nodes [::db::Set new -select {node_id {site_node__url(node_id) as url}} -from site_nodes -order url]
$nodes load      

tmpl::master -context_bar [ad_context_bar {.. "Sitewide Administration"} "Host Node Map"] {
	
    h3 { t "Registered hostname/URL pairs" }

    table {
	    foreach o [$data set result] {
		tr { 
			td { t [$o set node_id] }
			td { b { t [$o set host] } }
			td { t [$o set url] }
		}
	    }
    }
    h3 { t "Add another hostname/URL pair" }

	form -action "host-node-map" {
	
		foreach o [$nodes set result] {
			div {
				set node_id [$o set node_id]
				input -id ${node_id} -type radio -name node_id -value $node_id
				label -for ${node_id} { t [$o set url] }
				::xo::html::iexclude ${node_id}
			}
		}

		div -style "margin-top:20px;" {
			t "Host: "
			input -type text -name host -size 50
		}
		
		div -style "margin-top:20px;" {
			input -type submit -value "Add Host"
		}
	}
}