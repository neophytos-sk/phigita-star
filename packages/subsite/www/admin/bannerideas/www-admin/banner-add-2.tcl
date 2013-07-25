# /www/admin/bannerideas/banner-add-2.tcl
ad_page_contract {
    Enters the banner idea into the database.

    @author xxx
    @date unknown
    @cvs-id banner-add-2.tcl,v 3.2.2.6 2001/01/09 22:15:02 khy Exp
} {
    idea_id:verify,integer
    intro:trim,notnull
    {more_url:optional,trim ""}
    picture_html:optional,trim
    keywords:optional,trim
}


#Now check to see if the input is good as directed by the page designer

set exception_count 0
set exception_text ""

# we were directed to return an error for intro
if {![info exists intro] || [empty_string_p $intro]} {
	incr exception_count
	append exception_text "<li>Please enter an idea."
} 

proc philg_url_valid_p args {return 1}

# we were directed to return an error for more_url
if {![info exists more_url]} {
	incr exception_count
	append exception_text "Please enter a link to your URL."
} elseif {[philg_url_valid_p $more_url] != 1} {
    incr exception_count
    append exception_text "<li>You appear to have entered an invalid url"
}


if {[info exists intro] && [string length $intro] > 4000 } {
	incr exception_count
	append exception_text "<li>Please limit your idea to 4000 characters."
} 

if {[info exists picture_html] && [string length $picture_html] > 4000 } {
	incr exception_count
	append exception_text "<li>Please limit your picture url to 4000 characters."
} 

if {[info exists keywords] && [string length $keywords] > 4000 } {
	incr exception_count
	append exception_text "<li>Please limit your keywords 4000 characters."
}

if {$exception_count > 0} {
	ad_return_complaint $exception_count $exception_text
	return
}

# So the input is good --
# Now we'll do the insertion in the bannerideas table.

if [catch {
    db_dml bannerideas_insert_dml {
	insert into bannerideas
	(idea_id, intro, more_url, picture_html, keywords)
	values
	(:idea_id, :intro, :more_url, :picture_html, :keywords)
    }
} errmsg] {

    # Oracle choked on the insert
    if { [ db_string banner_idea_exists_p_query { 
	select count(*) from bannerideas where idea_id = :idea_id
    } ] == 0 } {

	# there was an error with the insert other than a duplication
	ad_return_error "Error in insert
	" "We were unable to do your insert in the database.
	Here is the error that was returned:
	<p>
	<blockquote>
	<pre>
	$errmsg
	</pre>
	</blockquote>"
	return
    }
}

db_release_unused_handles
ad_returnredirect ""









