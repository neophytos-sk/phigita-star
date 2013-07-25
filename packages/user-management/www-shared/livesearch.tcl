require_html_procs
ad_page_contract {
    @author Neophytos Demetriou
} {
    {callback:trim ""}
    {q:trim ""}
    {t:trim,notnull ""}
}




set result ""
set tsQuery ""
if { [exists_and_not_null q] } {
    set q [string map {: { } ' {} | {} & {} ! {} ~ {}} ${q}]

    set blogdata [::db::Set new \
		      -select "id title {ts_rank(ts_vector,q) as rank} {to_char(entry_date,'YYYY-mm-dd') as entry_date}" \
		      -from [subst {
			  xo__u[ad_conn ctx_uid].xo__blog_item b
			  , to_tsquery('[default_text_search_config]',[ns_dbquotevalue [join ${q} {&}]]) q}] \
		      -where [list shared_p "ts_vector @@ q"] \
		      -order "rank desc" \
		      -limit 10 \
		      -noinit]

    set conn [${blogdata} getConn]
    set tsQuery [${conn} getvalue "select to_tsquery('[default_text_search_config]',[ns_dbquotevalue [join ${q} {&}]])"]

    if { ${tsQuery} ne {} } {
	catch { $blogdata load }
    }
    set result [$blogdata set result]
}




###$o set id

set tmplist ""
foreach o $result {
    lappend tmplist "\[[::util::jsquotevalue [$o set id]],[::util::jsquotevalue [$o set title]],[::util::jsquotevalue [$o set entry_date]]\]"
}
set data \[[join $tmplist {,}]\]


doc_return 200 text/plain ${callback}([::util::jsquotevalue $q],${data});


