ad_page_contract {
    @author Neophytos Demetriou
} {
    url:trim,notnull
}

set input_url $url
set o1 [::uri::Request new]
$o1 volatile
${o1} configure -url ${url}
${o1} perform

set r [lindex [[${o1} dom_obj] documentElement] 0]


	set type ""
	set nodes ""
	switch -exact -- [${r} nodeName] {
	    html {
		#HTML
		set type html
		set channel_title ""
		set channel_link ""
		set channel_desc ""
		set nodes [${r} selectNodes {//*[local-name()='a' or local-name()='A']}]
		foreach e ${nodes} {

		    set href [string trim [::util::coalesce [${e} getAttribute href ""] [${e} getAttribute HREF ""]]]
		    if { ${href} eq {} || [string equal -length 11 javascript: [string tolower ${href}]]} {
			# ${e} hasAttribute onclick
			continue
		    }
		    set info(${e},link) [uri::resolve [::util::coalesce [${o1} set effective_url] ${input_url}] ${href}]
		    #ns_log notice "${input_url} +++++ $info(${e},link) ====> $info(${e},link)"
		    set info(${e},title) [string trim [string range [${e} asText] 0 255]]
		    set info(${e},description) ""
		    set info(${e},enclosure) ""
		    set info(${e},tags) ""
		    set info(${e},images) ""
		    set info(${e},objects) ""
		}
	    }
	    rdf:RDF -
	    channel -
	    rss {
		#RSS
		set type rss
		set channel_title [${r} selectNodes {returnstring(//*[local-name()='channel']/*[local-name()='title'])}]
		set channel_link  [${r} selectNodes {returnstring(//*[local-name()='channel']/*[local-name()='link'])}]
		set channel_desc  [${r} selectNodes {returnstring(//*[local-name()='channel']/*[local-name()='description'])}]
		set nodes [${r} selectNodes {//*[local-name()='item']}]
		foreach e ${nodes} {
		    set info(${e},title) [${e} selectNodes {returnstring(*[local-name()='title'])}]
		    set info(${e},link)  [${e} selectNodes {returnstring(*[local-name()='link'])}]
		    set info(${e},description)  [${e} selectNodes {returnstring(*[local-name()='description'])}]
		    set info(${e},enclosure)  [${e} selectNodes {returnstring(*[local-name()='enclosure'])}]
		    set info(${e},tags) ""
		    foreach tagNode [${e} selectNodes {*[local-name()='category']}] {
			set tag [string trim [string map {"\[" {} "\]" {} "<" {} ">" {}} [ns_striphtml [$tagNode text]]]]
			if { $tag ne {} } {
			    lappend info(${e},tags) $tag
			}
		    }
		    set info(${e},images) [::util::map "::util::wgetFile news/images" [::util::getImageList $info(${e},description)]]
		    set info(${e},objects) ""
		}
	    }
	    feed {
		#Atom
		set type atom
		set channel_title [${r} selectNodes {returnstring(//*[local-name()='feed']/*[local-name()='title'])}]
		set channel_link  [${r} selectNodes {values(//*[local-name()='feed']/*[local-name()='link' and @rel='alternate' and @type='text/html']/@href)}]
		set channel_desc  [${r} selectNodes {returnstring(//*[local-name()='feed']/*[local-name()='tagline'])}]
		set nodes [${r} selectNodes {//*[local-name()='entry']}]
		foreach e ${nodes} {
		    set info(${e},title) [${e} selectNodes {returnstring(*[local-name()='title'])}]
		    set info(${e},link)  [${e} selectNodes {values(*[local-name()='link' and @rel='alternate' and @type='text/html']/@href)}]
		    set info(${e},description)  [${e} selectNodes {returnstring(*[local-name()='summary' or local-name()='content'])}]
		    set info(${e},enclosure)  [${e} selectNodes {values(*[local-name()='link' and @rel='enclosure']/@url)}]
		    set info(${e},tags) ""
		    foreach tagNode [${e} selectNodes {*[local-name()='category']}] {
			set tag [string trim [$tagNode getAttribute term ""]]
			if { $tag ne {} } {
			    lappend info(${e},tags) $tag
			}
		    }
		    set info(${e},images) [::util::map "::util::wgetFile news/images" [::util::getImageList $info(${e},description)]]
		    set info(${e},objects) ""
		}
	    }
	    default {
		set r [lindex [[${o1} dom_obj] selectNodes {//*[local-name()='html' or local-name()='HTML']}] 0]
		if { ${r} eq {} } {
		    set r [[${o1} dom_obj] selectNodes {//*[local-name()='body' or local-name()='BODY']}]
		    if { ${r} eq {} } {
			ns_log notice "aggregator::refresh - not a feed (default): ${input_url}"
			continue
		    }
		}
		set type html
		set channel_title ""
		set channel_link ""
		set channel_desc ""
		set nodes [${r} selectNodes {//*[local-name()='a' or local-name()='A']}]
		foreach e ${nodes} {

		    set href [string trim [::util::coalesce [${e} getAttribute href ""] [${e} getAttribute HREF ""]]]
		    if { ${href} eq {} || [string equal -length 11 javascript: [string tolower ${href}]] } {
			#${e} hasAttribute onclick
			continue
		    }
		    set info(${e},link) [uri::resolve [::util::coalesce [${o1} set effective_url] ${input_url}] ${href}]
		    #ns_log notice "${input_url} +++++ $info(${e},link) ====> $info(${e},link)"
		    set info(${e},title) [string trim [${e} asText]]
		    set info(${e},description) ""
		    set info(${e},enclosure) ""
		    set info(${e},tags) ""
		    set info(${e},images) ""
		    set info(${e},objects) ""
		}
	    }
	}
$o1 destroy

doc_return 200 text/html [subst {

    <textarea>
$nodes
</textarea>
}]

