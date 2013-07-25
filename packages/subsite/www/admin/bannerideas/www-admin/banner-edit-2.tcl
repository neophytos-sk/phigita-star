proc philg_url_valid_p {args} {return 1}
# /www/admin/bannerideas/banner-edit-2.tcl
ad_page_contract {
    Edit a banner idea, putting the stuff into the database.
    
    @author xxx
    @date unknown
    @cvs-id banner-edit-2.tcl,v 3.2.2.5 2000/07/26 18:59:54 bryanche Exp
} {
    intro:trim,notnull
    {more_url:trim ""}
    picture_html:trim,optional
    keywords:trim,optional
    idea_id:integer
}

# we were directed to return an error for more_url
if {[philg_url_valid_p $more_url] != 1} {
    ad_return_complaint 1 "<li>You appear to have entered an invalid url"
    return
}


if [catch {
    db_dml banner_edit_update_dml "
    update bannerideas 
      set intro = :intro, 
      more_url = :more_url, 
      picture_html = :picture_html, 
      keywords = :keywords
    where idea_id = :idea_id
    " -bind [ad_tcl_vars_to_ns_set intro more_url picture_html keywords idea_id]

} errmsg] {

# Oracle choked on the update
    ad_return_error "Error in update
    " "We were unable to do your update in the database.
    Here is the error that was returned:
    <p>
    <blockquote>
    <pre>
    $errmsg
    </pre>
    </blockquote>"
    return
}

db_release_unused_handles
ad_returnredirect ""
