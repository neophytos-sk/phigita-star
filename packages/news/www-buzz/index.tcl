
ad_page_contract {
    @author Neophytos Demetriou
} {
    {output:trim "html"}
}

if { ${output} eq {html} || ${output} eq {rss} } {
    rp_internal_redirect /packages/news/tmpl-buzz/index-${output}
} else {
    rp_returnnotfound
}

