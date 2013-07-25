#::xo::kit::pretend_user 814

ad_page_contract {
    @author Neophytos Demetriou
} {
    callback
    q
    t
}

if { ![::xo::kit::is_registered_p] } {
    set json "\[\]"
    doc_return 200 text/plain "${callback}('${t}',${json});"
    return
}

set user_id [ad_conn user_id]

set directive ""
set index [string first {:} ${q}]
if { -1 != $index } {
    set directive [string range $q 0 $index]
    set q [string range $q $index end]
} 


set results [list]
if {[catch {
    set pathexp [list "User $user_id"]
    set searchdata [::db::Set new \
			-pathexp $pathexp \
			-select {url title} \
			-type ::bm::Bookmark \
			-order "sticky_p desc, starred_p desc, cnt_clickthroughs desc, last_clickthrough desc" \
			-limit 10 -noinit]

    # HERE - HUGE HACK - FIX ME PLEASE - TODO
    set query_words [ns_dbquotevalue "%[join ${q} %]%"]
    $searchdata lappend where "(title ilike ${query_words} or url ilike ${query_words} or description ilike ${query_words})"

    if { ${directive} ne {} } {
	if { ${directive} eq {starred:} } {
	    $searchdata lappend where "starred_p"
	} elseif { $directive eq {sticky:} } {
	    $searchdata lappend where "sticky_p"	
	} elseif { $directive eq {public:} } {
	    $searchdata lappend where "shared_p"
	}
    }

    $searchdata load

    foreach o [$searchdata set result] {
	lappend results [list [$o set title] [$o set url]]
    }
} errmsg]} {
    ns_log notice "errmsg=$errmsg"
    # do nothing
}

set json [::util::list2json $results "L"]

doc_return 200 text/plain "${callback}('${t}',${json});"
