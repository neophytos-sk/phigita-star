ad_page_contract {
    @author Neophytos Demetriou
} {
    oid:integer

}

tmpl::master -title "Schema Browser: Viewing a Namespace" -context_bar [ad_context_bar "Viewing a Namespace"] {

    ul {
	db_foreach get_all_classes {
	    select oid as class_oid,* from pg_class where relnamespace = :oid
	} {
	    li {
		a -href "class-view?oid=${class_oid}" {
		    t ${relname}
		}
	    }
	}
    }

}
