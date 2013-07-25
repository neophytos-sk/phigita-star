ad_page_contract {
    @author Neophytos Demetriou
} {
    oid:integer
}

tmpl::master -title "Schema Browser: Viewing a Class" -context_bar [ad_context_bar "Viewing a Class"] {

    db_foreach get_all_attributes {
	select * from pg_attribute where attrelid = :oid
    } {
	lappend attributes ${attname}
    }

    set relname [db_string getrelname "select relname from pg_class where oid = :oid"]
    set relnamespace [db_string getrelnamespace "select relnamespace from pg_class where oid = :oid"]
    set nspname [db_string getnspname "select nspname from pg_namespace where oid =:relnamespace"]

    ul {
	db_foreach get_all_rows "select tableoid,cmax,cmin,xmin,xmax,ctid,* from ${nspname}.${relname}" {
		foreach attname ${attributes} { 
		    li {
			t "${attname}: "
			t [set ${attname}]
		    }
		}
	    p
	    hr
	    p
	}
    }

}
