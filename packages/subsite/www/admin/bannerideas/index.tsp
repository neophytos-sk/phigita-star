ad_page_contract {
    Main page for banner ideas.  Presents them.
    
    @author Neophytos Demetriou
}

tmpl::master -title "Banner Ideas" -context_bar [ad_context_bar] {

    t "\["
    a -href "www-admin" {
	t "Admin"
    }
    t "\]"


    db_foreach banner_idea_list_query "select idea_id, intro, more_url, picture_html from bannerideas" {
	t -disableOutputEscaping [bannerideas_present $idea_id $intro $more_url $picture_html]
    }

    hr -width 50%

    t -disableOutputEscaping [bannerideas_random]

}
