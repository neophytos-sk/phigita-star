# /www/admin/bannerideas/index.tcl

ad_page_contract {
    Shows a list of banner ideas. It can't show the picture because it
    is usually an absolute URL and this page is accessed through HTTPS.

    @author xxx
    @date unknown
    @cvs-id index.tcl,v 3.2.2.4 2000/09/22 01:34:20 kevin Exp
} {

}


set page_content "[ad_admin_header "Banner Ideas" ]

<h2>Banner Ideas</h2>

[ad_admin_context_bar "Banner Ideas Administration"]

<hr>

Documentation:  <a href=\"/doc/bannerideas\">/doc/bannerideas.html</a>.

<h3>Banner ideas</h3>

<ul>
"

db_foreach banneridea_list_admin_query {
    select idea_id, intro, more_url, picture_html, clickthroughs
    from bannerideas
    order by idea_id
} {
    # can't show the picture because it is usually absolute URLs
    # and we're probably on HTTPS right now
    append page_content "<li>$intro &nbsp; &nbsp; 
    ...
    <br>
    <a href=\"$more_url\">more</a> ($clickthroughs clicks so far to $more_url) | 
    <a href=\"banner-edit?[export_url_vars  idea_id]\">Edit</a>
    <p>
    "
} if_no_rows {
    append page_content "<li>there are no ideas in the database right now"
}

append page_content "<p>

<li><a href=\"banner-add\">Add a banner idea</a>
</ul>

[ad_admin_footer]
"


doc_return  200 text/html $page_content
