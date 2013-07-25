set classes [Class allinstances]

tmpl::master -context_bar [ad_context_bar "XOTCL #objects per class"] {
    ul {
	foreach cl $classes {
	    li { t "${cl}: [llength [$cl allinstances]]" }
	}
    }
}