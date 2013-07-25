source [acs_root_dir]/packages/news/tcl/00-xpathfunc-procs.tcl

set url paremvasi.wordpress.com/feed/
set url dizzydream.wordpress.com/feed/

set o [::uri::Request new -url ${url}]
${o} feed_p yes
${o} volatile
${o} perform


set r [[$o dom_obj] documentElement]

#doc_return 200 text/html [ad_quotehtml [$r asXML]]

set tags ""
set nodes [${r} selectNodes {//*[local-name()='item']}]

foreach e $nodes {

#    lappend tags [$e selectNodes {textvalues(*[local-name()='category'])}]

    lappend tags $e
    foreach tagNode [${e} selectNodes {*[local-name()='category']}] {
	lappend tags [ns_striphtml [$tagNode text]]
    }

}

doc_return 200 text/html $tags
return
