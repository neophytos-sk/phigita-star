namespace eval ::xo {;}
namespace eval ::xo::ns {;}

proc ::xo::ns::printset {setId} {
    # This proc returns the size and contents of an ns_set.
    if {$setId == ""} {return ""}
    set size [ns_set size $setId]
    set retval "Size of ns_set [ns_set name $setId]: $size\n\n"
    for {set i 0} {$i < $size} {incr i} {
        append retval "key: [ns_set key $setId $i] value: [ns_set value $setId $i]\n"
    }
    return $retval
}

proc ::xo::ns::set2query {setId} {
    set result ""
    set size [ns_set size $setId]
    for {set i 0} {$i < $size} {incr i} {
	lappend result "[ns_set key $setId $i]=[ns_set value $setId $i]"
    }
    return [join $result {&}]
}

proc ::xo::ns::getform {} {
    set form [ns_getform]
    if { ${form} ne {} } {
        # It's there
        return ${form}
    } else {
        # It doesn't exist, create a new one

        # This is the magic global Tcl variable that AOLserver uses 
        # to store the ns_set that contains the query args or form.
        global _ns_form

        # Simply create a new ns_set and store it in the global _ns_set variable
        set _ns_form [ns_set create]
        return $_ns_form
    }
}

proc ::xo::ns::headers {} {
    return [ns_set copy [ns_conn headers]]
}


proc ::xo::ns::pagedir {{server ""}} {
    if { ${server} ne {} } {
	return [ns_server -server $server pagedir]
    } else {
	return [ns_server pagedir]
    }
}

proc ::xo::ns::htmltidy {html {input_xml_p 0} {output_xml_p 0} {output_xhtml_p 1}} {
    set response_body [htmltidy::tidy \
                           --force-output y \
                           --show-warnings n \
                           --show-errors 0 \
                           --input-xml ${input_xml_p} \
                           --output-xml ${output_xml_p} \
                           --output-xhtml ${output_xhtml_p} \
                           --quiet y \
                           --tidy-mark 0 \
                           --wrap 0 \
                           --indent no \
                           --escape-cdata y \
                           --input-encoding utf8 \
                           --output-encoding utf8 \
                           --ascii-chars n \
                           --ncr y \
                           --hide-comments y \
                           --assume-xml-procins y \
                           --numeric-entities y \
                           --drop-empty-paras 0 \
                           --fix-bad-comments y \
                           --fix-uri n \
                           --new-blocklevel-tags "xo__option" \
                           [regsub -all -- {('[^']*<)SCRIPT([^']*')} ${html} {\1SCR' + 'IPT\2}]]
}


proc ::xo::ns::reverse_proxy_mode_p {} "return [ns_config -bool ns/parameters ReverseProxyMode 0]"

namespace eval ::xo::ns::conn {;}


# question: what about ns_conn host?
proc ::xo::ns::conn::host {} {
    return [ns_set iget [ns_conn headers] "Host"]
}

if { ![::xo::ns::reverse_proxy_mode_p] } {

    ns_log notice "--->>> ReverseProxyMode=0"

    proc ::xo::ns::conn::peeraddr {} {
	return [ns_conn peeraddr]
    }

    proc ::xo::ns::conn::protocol {} {
	return [::util::coalesce [ns_conn protocol] {http}]
    }

} else {

    ns_log notice "--->>> ReverseProxyMode=1"

    #####
    #
    # ReverseProxyMode
    #
    #####

    proc ::xo::ns::conn::peeraddr {} {

	set headers [ns_conn headers]
        set addr [lindex [ns_set iget ${headers} x-forwarded-for] end]
        if { ${addr} eq {} } {
            set addr [ns_conn peeraddr]
        }

    }

    proc ::xo::ns::conn::protocol {} {
	return [::util::coalesce [lindex [ns_set iget [ns_conn headers] x-forwarded-proto] end] [ns_conn protocol] {http}]
    }

}
