ad_page_contract {
    @author Neophytos Demetriou
} {
    {parent_id "[site_node::get_node_id_from_object_id -object_id [ad_conn package_id]]"}
}



set TSP ${root}

# FIX ME
append id "*.*{1}"

set ds:local_context_bar [db_list_of_ns_sets local_context_bar {
    select tree_sk
    from site_nodes
    where node_id = :parent_id
}]

set ds:site_map [db_list_of_ns_sets all_nodes {
    select p.package_id,
           p.package_id,
           p.instance_name,
           n.node_id,
           n.name,
           n.directory_p,
           n.pattern_p,
	   n.pageroot,
           n.tree_sk as url
    from apm_packages p join apm_package_types pt using (package_key) right outer join 
         (select node_id,
	         object_id,
	         name,
	         directory_p,
	         pattern_p,
	         pageroot,
	         tree_sk
	  from site_nodes
	  where parent_id = :parent_id) n
    on n.object_id = p.package_id
    order by directory_p desc, name
}]


set ds:services [db_list_of_ns_sets all_services {
	select * from apm_services, apm_packages where package_id=service_id
}]

layout::master \
    -varname "tsp:master" \
    -context ${TSP}


set script:local_context_bar {
    hr -size 1 -noshade ""
    set sofar "/"
    b { t "Site Nodes /" }
    foreach node_name [string map "_ - . { }" [ns_set get [lindex ${ds:local_context_bar} 0] tree_sk]] {
	append sofar ${node_name}/
	b {
	    a -href "?label=${sofar}" {
		t ${node_name}
	    }
	    t " / "
	}
    }
    br
    font -size -3 { br }
}

set script:action_bar_1 {
    table -bgcolor "#666666" -cellpadding "1" -cellspacing "0" -border "0" -width "100%" {
        tr {td { table -bgcolor "#eeeeee" -cellpadding "2" -cellspacing "0" -border "0" -width "100%" {
            tr {
                td -bgcolor "#eeeeee" {
                    t -disableOutputEscaping "&nbsp;"
                    font -face "Arial" -size "-1" {
                        a -href "node-new?parent_id=${parent_id}" {
                            b { t "New Node" }
                        }
                        t " - "
                        a -href "nodes-import" { 
                            b { t "Import Nodes" }
                        }
                        t " - "
                        a -href "nodes-export" {
                            b { t "Export Nodes" }
                        }
                    }
                }
                td -align "right" {
                    font -face "Arial" -size "-1" {
                        a -href "jump-to-folder" {
                            b {t "Jump To Folder" }
                        }
                    }
                }
            }
        }}}
    }
}

set script:action_bar_2 {
        table -border "0" -cellPadding "2" -cellSpacing "0" -width "100%" {
            tr { 
                td -bgColor "#dcdcdc" {
                    input -onClick "return channels_check(0)" -name ".delete" -type "submit" -value [g11n::gettext "Delete"]
                    font -face "Arial" -size "-1" {
                        t " - "
                        a -href "javascript:CheckAll(true)" { t "Check All" }
                        t " - "
                        a -href "javascript:CheckAll(false)" { t "Clear All" }
                    }
                }
                td -align "right" -bgColor "#dcdcdc" {
                    t -disableOutputEscaping "&nbsp;" 
                    input -onClick "return channels_check(1)" -name ".move" -type "submit" -value [g11n::gettext "Move To..."]
                    t -disableOutputEscaping "&nbsp;"
                }
            }
        }
}


${tsp:master} appendFromScript ${script:local_context_bar}
${tsp:master} appendFromScript ${script:action_bar_1}
${tsp:master} appendFromScript ${script:action_bar_2}

# improve/take a look at ad_table
bebop::activeTable \
    -context ${tsp:master} \
    -dataset ${ds:site_map} \
    -table  { table -width "100%" -bgcolor "#eeeeee" -cellspacing "1" -border "0"} \
    -header {

	tr -bgcolor "#ffffcc" {
	    foreach h {"Label" Title P "pageroot" Actions} {
		font -face "arial" -size "-1" {
		    td -align center -valign "top" { b { t ${h} } }
		}
	    }
	}

    } -onerow { 

	tr -bgcolor "#ffffff" {
	    td -nowrap "" { 
		input -type "checkbox" -name "site_nodes" -value "[ns_set get ${setId} node_id]"
		if { [string equal [ns_set get ${setId} directory_p] "t"] } {
		    img -src /graphics/misc/composite -width 16 -height 16
		    t -disableOutputEscaping "&nbsp;"
		}
		font -face "courier" -size -1 {
		    a -href "?parent_id=[ns_set get ${setId} node_id]" {
			t "[ns_set get ${setId} name]" 
		    } 
		}
		t -disableOutputEscaping "&nbsp;"
	    }
	    td -width "100%" { 
		font -face "courier" -size -1 { 
		    t -disableOutputEscaping "&nbsp;"
		    a -href "/[string map {_ - . /} [ns_set get ${setId} url]]/" {
			t "[ns_set get ${setId} instance_name]" 
		    }
		} 
	    }
	    td { t "[ns_set get ${setId} pattern_p]" }
	    td { t "[ns_set get ${setId} pageroot]" }
	    td -align right -nowrap "" { 
		font -face "courier" -size -1 {
		    if { [ns_set get ${setId} directory_p] } {
			if { [empty_string_p [ns_set get ${setId} package_id]] } {
			    a -href "mount?node_id=[ns_set get ${setId} node_id]" {
				t "mount"
			    }
			    t -disableOutputEscaping " &#183; "
			} else {
			    a -href "admin" {
				t "admin"
			    }
			    t -disableOutputEscaping " &#183; "
			    a -href "unmount?node_id=[ns_set get ${setId} node_id]" {
				t "unmount"
			    }
			    t -disableOutputEscaping " &#183; "
			}
		    }
		    a -href "/admin/permissions/one?object_id=[ns_set get ${setId} package_id]" {
			t "access control"
		    }
		    t -disableOutputEscaping " &#183; "
		    a -href "parameters/parameter-set?package_id=[ns_set get ${setId} package_id]" {
			t "set parameters"
		    }
		    t -disableOutputEscaping " &#183; "
		    a -href "logs" {
			t "logs"
		    }
		    t -disableOutputEscaping " &#183; "
		    a -href "edit?node_id=[ns_set get ${setId} node_id]&package_id=[ns_set get ${setId} package_id]&return_url=[ns_urlencode [ad_conn url]]?[ad_conn query]" {
			t "edit"
		    }
		}
	    }
	}

    }


${tsp:master} appendFromScript ${script:action_bar_2}
${tsp:master} appendFromScript ${script:action_bar_1}

${tsp:master} appendFromScript {

  h2 {
    t "Configurable Services"
  }

  ul {
	foreach setId ${ds:services} {	   
		li { 
		  t "[ns_set get ${setId} instance_name] ("
		  a -href "parameters/parameter-set?package_id=[ns_set get ${setId} package_id]" {
			t "set parameters"
 	     	  }
		  t ")"
		}
        }
   }
}
