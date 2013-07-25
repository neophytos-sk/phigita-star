
namespace eval ::uri {;}

Class ::uri::Request -parameter {
    {feed_p no}
    {debug_p no}
    onreadystatechange 
    onload 
    onerror 
    open 
    send 
    readyState 
    status 
    statusText 
    url 
    effective_url
    response_code
    response_header
    response_body
    language 
    encoding 
    data 
    dom_obj
}

::uri::Request instproc setRequestHeader {name value} {
}

::uri::Request instproc init {args} {
    next
}

::uri::Request instproc configure {args} {

    my instvar url_handle url feed_p
    if {[info exists url_handle]} {
	#${url_handle} reset
	${url_handle} cleanup
    }
    set url_handle [curl::init]




#    set useragent [list {Mozilla/5.0 (X11; U; Linux i686; en-US;) Gecko/20050107 Firefox/1.0}]
    set useragent [list {Mozilla/5.0 (compatible; phigibot/0.1; http://www.phigita.net/bot.html)}]

    set followlocation [::util::boolean $feed_p]

    ${url_handle} configure -useragent ${useragent} -nosignal 1 -timeout 30 -connecttimeout 10 -encoding all -followlocation ${followlocation} -maxredirs 3 {*}${args}

    next

}

::uri::Request instproc destroy {args} {

    my instvar url_handle
    ${url_handle} cleanup
    next

}

::uri::Request instproc perform {} {

    my instvar dom_obj url_handle effective_url response_code response_header response_body feed_p response_text maxNode

    set effective_url ""
    set response_code ""
    set response_header ""
    set response_body ""
    set response_text ""
    set maxNode ""

    ${url_handle} configure -headervar response_header -bodyvar response_body 
    if { [catch { ${url_handle} perform } errmsg] } {
	ns_log notice "uri request errmsg $errmsg"
	error $errmsg
    }

    set effective_url [${url_handle} getinfo effectiveurl]
    set response_code [${url_handle} getinfo responsecode]
    set encoding [my detectEncoding]

    if { ${feed_p} } {
	set input_xml_p y
	set output_xml_p y
	set output_xhtml_p f
    } else {
	set input_xml_p n
	set output_xml_p n
	set output_xhtml_p y
    }

    if {[my debug_p]} { ns_log notice "[my info class] runtime point 0 - effective_url = $effective_url len=[string length $response_body]" }

    set __mapping__ {{option} {xo__option}}
    set response_body [string map $__mapping__ [encoding convertfrom ${encoding} ${response_body}]]

    if {[my debug_p]} { ns_log notice "[my info class] runtime point 1 - effective_url = $effective_url len=[string length $response_body]" }

    # regsub is used below to cover the situation in which the javascript code 
    # within a script element with no escaping (i.e. not enclosed in a comment or cdata)
    # uses a script tag kathimerini.gr (2006-01-04)

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
			   [regsub -all -- {('[^']*<)SCRIPT([^']*')} ${response_body} {\1SCR' + 'IPT\2}]]

    if {[my debug_p]} { ns_log notice "[my info class] runtime point 2 - effective_url = $effective_url len=[string length $response_body]" }

    # creates the DOM tree in memory, 
    # make a reference to the document object,
    # visible in Tcl as a document object command,
    # and assigns this new object name to the
    # variable doc. When doc gets freed,
    # the DOM tree and the associated Tcl
    # command object (document and all node
    # objects) are freed automatically.

    try {

    	dom parse \
	    -simple \
	    -keepEmpties \
	    ${response_body} \
	    dom_obj

	set response_body [encoding convertto identity [${dom_obj} asXML]]
	my detectEncoding

	if { !${feed_p} } {
	    if {[my debug_p]} { ns_log notice "[my info class] runtime point 3 - effective_url = $effective_url len=[string length $response_body]" }
	    set tt [::ttext::Worker new -volatile]
	    set response_text [${tt} bte ${dom_obj}]
	    set maxNode [$tt maxNode]
	    if {[my debug_p]} { ns_log notice "[my info class] runtime point 4 - effective_url = $effective_url maxNode=$maxNode" }
	    ${tt} destroy
	}

    } catch {*} {
	#do nothing
    }

    if {[my debug_p]} { ns_log notice "[my info class] runtime point 5 - effective_url = $effective_url len=[string length $response_body]" }

}

::uri::Request instproc detectEncoding {} {
    my instvar response_body language encoding 

    ### NOT USING\316 AND \317 IN THE GREEK_ASCII_RE TO AVOID (ISO-8859-7 AND CP1253) MATCHING OF UTF-8 SEQUENCES

    set WINDOWS_ALPHA_WITH_TONOS {\242}
    set ISO_ALPHA_WITH_TONOS {\266}
    set GREEK_UTF8_RE {(\316\261|\316\262|\316\263|\316\264|\316\265|\316\266|\316\267|\316\268|\316\269|\316\270|\316\271|\316\272|\316\273|\316\274|\316\275|\316\276|\316\277|\317\200|\317\201|\317\202|\317\203|\317\204|\317\205|\317\206|\317\207|\317\208|\317\209|\317\210|\317\211|\316\221|\316\222|\316\223|\316\224|\316\225|\316\226|\316\227|\316\228|\316\229|\316\230|\316\231|\316\232|\316\233|\316\234|\316\235|\316\236|\316\237|\316\238|\316\239|\316\240|\316\241|\316\242|\316\243|\316\244|\316\245|\316\246|\316\247|\316\248|\316\249|\316\250|\316\251|\316\254|\316\255|\316\256|\316\257|\317\214|\317\215|\317\216|\316\260|\316\220|\316\220|\316\206|\316\210|\316\211|\316\212|\316\214|\316\216|\316\217){5,25}}

    set GREEK_ASCII_RE {([\300-\314]|\315|\318|\319|[\320-\376]|[\237|[\270-\272]|[\274-\277]){5,25}}


    set greek_unicode_p [regexp -- ${GREEK_UTF8_RE} ${response_body}]
    set greek_ascii_p [regexp -- ${GREEK_ASCII_RE} ${response_body}]

    set encoding ""
    set language ""
    if {${greek_unicode_p}} {
	set language el
	set encoding utf-8
    } else {
	if {${greek_ascii_p}} {
	    set language el
	    if {[regexp -- ${WINDOWS_ALPHA_WITH_TONOS} ${response_body}]} {
		set encoding cp1253
	    } else {
		set encoding iso8859-7
	    }
	} else {
	    set language "en"
	    set encoding utf-8
	}
    }
    return ${encoding}
}
