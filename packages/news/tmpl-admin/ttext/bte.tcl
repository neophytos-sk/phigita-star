ad_page_contract {
    @author Neophytos Demetriou
} {
    url:trim,notnull
}

#source [acs_root_dir]/packages/core-platform/tcl/ttext/bte-procs.tcl
#source [acs_root_dir]/packages/news/tcl/20-buzz-procs.tcl

set o [::uri::Request new -url ${url}]


${o} volatile
${o} perform

set tt [::ttext::Worker new -volatile -init]
set tt1 [::ttext::Worker new -volatile -init]

set response_text [${tt} bte [${o} dom_obj]]

dom parse -keepEmpties -simple [regsub -all -- {\/\/[^\n]\n} [string tolower [encoding convertfrom utf-8 [$o set response_body]]] {}] doc
set root [${doc} documentElement]
$tt1 set maxf -100000000
$tt1 evaluateNode $root
set text [$tt1 getBody [$tt1 set maxNode]]

set tableNodes [$root childNodes]
foreach n $tableNodes {
    foreach n2 [$n childNodes] {
	catch {    $n2 setAttribute hello world }
    }
}

doc_return 200 text/html [subst {
    <html>
<body>
URL: <a href="$url">$url</a>
    <pre>
    ok
    tagValues=[${tt} array get tagValues]
    tagValues=[${tt} exists tagValues(b)]
    maxf=[${tt} maxf]
    maxStart=[${tt} maxStart]
    maxEnd=[${tt} maxEnd]
    nodeName=[[${tt} maxNode] nodeName]
    Anchors: [::util::getAnchorList [[$tt maxNode] asHTML]]
    Objects: [::util::getObjectList [[[$tt maxNode] parentNode] asHTML]]
    HTML:
    <textarea cols=80 rows=10>
    [[$tt maxNode] asHTML]
    </textarea>
    BTE:
    <textarea cols=80 rows=10>
    [ttext::unac utf-8 ${response_text}]
    </textarea>

<hr>
    ORIGINAL DOC
    [ad_quotehtml [[$o dom_obj] asXML]]
<hr>


    xml=[ad_quotehtml [[${o} dom_obj] asXML -indent 4]]
    </pre>
    <hr>
    <pre>
    [ad_quotehtml [$o set response_body]]
    </pre>
<hr>
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
<hr>

    $text
    <pre>[ad_quotehtml [$doc asXML -indent 4]]</pre>
<hr>
</body>
</html>
}]


