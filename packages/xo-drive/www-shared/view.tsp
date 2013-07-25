#::xo::kit::require_registration

ad_maybe_redirect_for_registration

ad_page_contract {
    @author Neophytos Demetriou
} {
    id:integer,notnull
}



set pathexp [list "User [ad_conn ctx_uid]"]
set data [::db::Set new \
	      -pathexp $pathexp \
	      -select "1" \
	      -type ::Content_Item \
	      -where [list shared_p id=[ns_dbquotevalue ${id}]] \
	      -limit 1]

# ONLY IF ON DEVELOPMENT-SERVER
#$data where id=[ns_dbquotevalue $id]

$data load


if { [$data emptyset_p] } {
    rp_returnnotfound
    return
}

set list ""
foreach item $pathexp {
    foreach {className instance_id} $item break
    lappend list [$className set id]-${instance_id}
}

set directory /web/data/storage/
append directory [join $list .]/
append directory $id

##################################################################

js -src mediabox.reader {
        window.onload=function(){
	//Setup reader
	DR.init({
	    baseUrl: '${base}/media/view/',
	    docId: ${id},
	    size: ${size},
	    pages: ${pages},
	    currentPage: ${p}
	});
    };
}
