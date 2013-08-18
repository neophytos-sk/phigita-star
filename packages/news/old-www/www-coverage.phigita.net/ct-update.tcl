ad_page_contract {
    @author Neophytos Demetriou
} {
    {s:trim,notnull}
    {url:trim,notnull}
}

ns_return 200 text/plain "ok"

if { [ns_sha1 $url] eq ${s} } {
    try {
	set connObject [DB_Connection new -pool newsdb]

	$connObject do [subst {
	    update xo.xo__sw__agg__url set
	    cnt_clickthroughs=cnt_clickthroughs+1
	    ,last_clickthrough=current_timestamp
	    where
	    url=[ns_dbquotevalue ${url}]
	}]
    } catch {*} {
	ns_log notice "IP=[ad_conn peeraddr] URL=$url Error: $trymsg"
    } finally {
	$connObject destroy
    } trymsg
}