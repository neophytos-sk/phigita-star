namespace eval ::rss {;}

# to be mixed into an instance of ::db::Set

::my::Class ::rss::Channel -parameter {
    {title ""}
    {link ""}
    {description ""}
    {language "en"}
    {css_link ""}
}

::rss::Channel instproc asRSS {} {

    my instvar title description link language result css_link

    if {![info exists css_link]} {
	set css_link http://www.phigita.net/css/rss.css
    }

    dom setResultEncoding "utf-8"
    dom createDocument rss doc

    ${doc} documentElement doc_node
    ${doc_node} setAttribute version "2.0"

    set pi [${doc} createProcessingInstruction "xml-stylesheet" "type=\"text/css\" href=\"${css_link}\""]
    set root [${doc_node} selectNode {/}]
    ${root} insertBefore ${pi} ${doc_node}

    set channel_node [$doc createElement channel]
    ${doc_node} appendChild ${channel_node}

    set headers [list \
                     [list title ${title}] \
                     [list link ${link}] \
		     [list description ${description}] \
		     [list language ${language}] \
		     [list docs "This file is an RSS 2.0 file. It is intended to be viewed in a Newsreader or syndicated to another site."]]

    foreach header ${headers} {
        set node [${doc} createElement [lindex ${header} 0]]
        set text_node [${doc} createTextNode [lindex ${header} 1]]
        ${node} appendChild ${text_node}
        ${channel_node} appendChild ${node}
    }


    foreach o ${result} {

        set node [${doc} createElement item]
	foreach name {title link description pubDate guid} attlist {{} {} {} {} {isPermalink true}} {
	    set subnode [${doc} createElement ${name}]
	    set text_node [${doc} createTextNode [${o} set [string tolower ${name}]]]
	    ${subnode} appendChild ${text_node}

	    foreach {attname attvalue} ${attlist} {
		${subnode} setAttribute ${attname} ${attvalue}
	    }

	    ${node} appendChild ${subnode}
	}
	${channel_node} appendChild ${node}

    }

    return "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n[${doc} asXML]"

}
