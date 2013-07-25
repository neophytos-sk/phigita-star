
    # Browsing History Management
    set browsing_history_exists_p 0
    set browsing_history [list]

    if { ![string equal [ad_conn user_id] 0] } {

	set browsing_history_exists_p [nsv_exists browsing_history [ad_conn user_id]]

	if { $browsing_history_exists_p } {

	    set browsing_history [nsv_get browsing_history [ad_conn user_id]]

	    nsv_lappend browsing_history [ad_conn user_id] [list [ad_conn url]?[ad_conn query] $title]

	} else {

	    nsv_set browsing_history [ad_conn user_id] [ad_conn url]?[ad_conn query]

	}

    }

    set browsing_history_exists_p 0