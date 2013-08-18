#load /var/lib/naviserver/service-phigita/modules/ttext0.3/unix/libttext0.3.so

ad_page_contract {
    @author Neophytos Demetriou
} {
    url:trim,notnull
}

set url_handle [curl::init]
${url_handle} configure -headervar response_header -bodyvar response_body0 -timeout 10 -nosignal 1 -encoding identity -followlocation 1 -maxredirs 3 -url ${url}
catch { ${url_handle} perform }

set effective_url [${url_handle} getinfo effectiveurl]
set response_code [${url_handle} getinfo responsecode]
set encoding utf-8
#ns_log notice "BEFORE ::htmltidy::tidy ${effective_url}"

set input_xml_p n
set output_xml_p n
set output_xhtml_p y
set output_html_p n
set response_body1 [encoding convertfrom ${encoding} ${response_body0}]

set __mapping__ {{option} {xo_option}}
set response_body [htmltidy::tidy \
		       --force-output y \
		       --show-warnings n \
		       --show-errors 0 \
		       --input-xml ${input_xml_p} \
		       --output-xml ${output_xml_p} \
		       --output-xhtml ${output_xhtml_p} \
		       --output-html ${output_html_p} \
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
		       --assume-xml-procins n \
		       --numeric-entities y \
		       --drop-empty-paras 0 \
		       --drop-font-tags 0 \
		       --drop-proprietary-attributes 0 \
		       --wrap-asp n \
		       --wrap-jste n \
		       --wrap-php n \
		       --wrap-sections n \
		       --fix-bad-comments y \
		       --fix-uri n \
		       --clean y \
		       --new-blocklevel-tags xo_option \
		       --wrap-script-literals n \
		       [string map $__mapping__ $response_body1]]

#		       [regsub -all {option|OPTION} $response_body1 {option}]]
#		       [regsub -all -- {('[^']*<)SCRIPT([^']*')} ${response_body1} {\1SCR' + 'IPT\2}]]

doc_return 200 text/html <pre>[ad_quotehtml $response_body]</pre>
return 

set rb ""



set test ""
set xml ""
set docId [dom parse -simple -keepEmpties ${response_body}]
set root [${docId} documentElement]
set nodes [${root} selectNodes {//*[local-name()='a']}]
    

foreach e ${nodes} {
    if { [string match "*storyid=*" [$e getAttribute href ""]] } {
	lappend test [encoding convertfrom iso8859-7 [list [$e getAttribute href ""] [[lindex [[${e} parentNode] getElementsByTagName a] 0] getAttribute href ""] ]]
    }
}

doc_return 200 text/plain [subst {
    [join $test \n]
}]

set xml [encoding convertfrom iso8859-7 [ns_quotehtml [${root} asXML -indent 4 ]]]


doc_return 200 text/html [subst {
    <pre>${xml}</pre><hr>
    [ad_quotehtml $rb]
}]

set comment {

doc_return 200 text/html ${xml}
}
set comment {
    [ad_quotehtml [htmltidy::tidy --show-warnings n --quiet y "<html>Hello World</html>"]]<hr><p><hr><p><hr>[ad_quotehtml ${response_body}]<hr><hr><hr>
}