source [acs_root_dir]/packages/persistence/tcl/00-util-procs.tcl


#set url paremvasi.wordpress.com/feed/
#set url http://whitefireandgreatsword.blogspot.com/2006/12/blog-post_23.
set url http://eglima.blogspot.com/feeds/posts/default

set o [::uri::Request new -url ${url}]
${o} feed_p yes
${o} volatile
${o} perform


set r [[$o dom_obj] documentElement]

#doc_return 200 text/html [ad_quotehtml [$r asXML]]

set tags ""
set nodes [${r} selectNodes {//*[local-name()='entry']}]

set content ""
foreach e $nodes {

    lappend content $e
    foreach tagNode [${e} selectNodes {*[local-name()='content']}] {
	lappend content [::util::dequotehtml [$tagNode asHTML]]
    }

}

doc_return 200 text/html $content
return
