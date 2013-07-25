ad_page_contract {
    @author Neophytos Demetriou
} {
    name
    {show_key:trim ""}
}

tmpl::blank -title "Cache: $name" {
    table {
	foreach key [ns_cache_keys $name] {
	    tr {
		td {
		    a -href "cache-one?show_key=$key" {
			t $key
		    }
		}
		td {
		    if { ${show_key} eq ${key} } {
			#t ns_cache_get $name $key
		    }
		}
	    }	
	}
    }
}