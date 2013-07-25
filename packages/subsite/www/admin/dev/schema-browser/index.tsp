tmpl::master -title "Schema Browser" -context_bar [ad_context_bar "Schema Browser"] {

    ul {
	db_foreach get_all_namespaces {
	    select oid,nspname from pg_namespace
	} {
	    li {
		a -href "nsp-view?oid=${oid}" {
		    t ${nspname}
		}
	    }
	}
    }

}
