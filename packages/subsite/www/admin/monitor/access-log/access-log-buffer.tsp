set buffer [ns_accesslog buffer]


regsub -all {\n} ${buffer} {<p>} buffer

regsub -all {"(http://[^"]*)"} ${buffer} {<a href="\1">\1</a>} buffer 

tmpl::master -title "Access Log Buffer" -context_bar [ad_context_bar "Access Log Buffer"] {
    t -disableOutputEscaping ${buffer}
}
