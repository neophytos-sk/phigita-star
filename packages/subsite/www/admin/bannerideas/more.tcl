# /www/bannerideas/more.tcl
ad_page_contract {
    Redirects to another page and then logs a click.

    @author xxx
    @date unknown
    @cvs-id more.tcl,v 3.1.6.5 2000/07/21 03:58:33 ron Exp
} {
    idea_id:integer
    more_url
}

ad_returnredirect $more_url

ns_conn close 

# we're offline as far as the user is concerned but let's log the click

db_dml bannerideas_log_click_dml "update bannerideas 
set clickthroughs = clickthroughs + 1
where idea_id = :idea_id" -bind [ad_tcl_vars_to_ns_set idea_id]

db_release_unused_handles

