ad_page_contract {
    @author Neophytos Demetriou
} {
    url_sha1
}

set o [db::One new -pool newsdb -type ::sw::agg::Url -where [list "url_sha1=[ns_dbquotevalue ${url_sha1}]"]]

tmpl::master -context_bar [ad_context_bar "Cached Story"] {

    h3 { a -href [$o get url] { t [$o get title] } }
    p
    blockquote {
	t -disableOutputEscaping [regsub -all -- {\n} [$o get last_crawl_content] {<br><br>}]
    }
}