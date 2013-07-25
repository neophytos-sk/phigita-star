source [acs_root_dir]/packages/news/tcl/00-xpathfunc-procs.tcl

#set url paremvasi.wordpress.com/feed/
set url http://whitefireandgreatsword.blogspot.com/2006/12/blog-post_23.

set o [::uri::Request new -url ${url}]
${o} feed_p yes
${o} volatile
${o} perform


set r [[$o dom_obj] documentElement]

#doc_return 200 text/html [ad_quotehtml [$r asXML]]

set tags ""
set nodes [${r} selectNodes {//*[local-name()='item']}]

foreach e $nodes {

    lappend tags $e
    foreach tagNode [${e} selectNodes {*[local-name()='category']}] {
	lappend tags [$tagNode nodeValue]
    }

}

doc_return 200 text/html [$o set response_code]
return
