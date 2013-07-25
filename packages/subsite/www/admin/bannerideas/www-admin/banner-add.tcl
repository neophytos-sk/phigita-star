# /www/admin/bannerideas/banner-add.tcl

ad_page_contract {
    @cvs-id banner-add.tcl,v 3.2.2.7 2001/01/09 22:14:33 khy Exp
} {
    
}

set idea_id [db_string idea_id_sequence_query "select nextval('idea_id_sequence')"]

set page_content "
[ad_admin_header "Add a banner idea"]

<h2>Add</h2>

[ad_admin_context_bar [list "index.tcl" "Banner Ideas Administration"] "Add One"]

<hr>

<form method=POST action=\"banner-add-2\">

[export_form_vars -sign idea_id]

<table>
<tr><th align=right valign=top>Idea:</th><td><textarea name=intro cols=60 rows=5 wrap=soft></textarea></td></tr>\n\n

<tr><th align=right valign=top>URL:</th><td><input type=text size=60 maxlength=200 name=more_url></td></tr>\n\n

<tr><th align=right valign=top>HTML for picture:</th><td><textarea name=picture_html cols=60 rows=5 wrap=soft></textarea></td></tr>\n\n

<tr><th align=right valign=top>Keywords:</th><td><textarea name=keywords cols=60 rows=5 wrap=soft></textarea></td></tr>\n\n
</table>
<p>
<center>
<input type=submit value=\"Proceed\">
</center>
</form>
<p>
[ad_admin_footer]"


doc_return  200 text/html $page_content
