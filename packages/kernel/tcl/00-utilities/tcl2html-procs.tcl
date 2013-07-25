proc api_proc_url {tclproc} {

    return ?tclproc=$tclproc
}

ad_proc -public util_tcl_to_html {data} {

    Converts TCL code to HTML, including highlighting syntax in
    various colors.<BR>
    The inspiration for this proc was the tcl2html script created by Jeffrey Hobbs.
<P>
    Known Issues: 
<BR>
    Ideally, "set" in <CODE>for {set i 0}</CODE> would be highlighted as a TCL proc.
    But then we would have to also highlight it in some places we don't want to.
    I've tried to highlight less rather than more when there is a conflict.
<BR>
    When a proc inside a string has string arguments, they are not formatted.

    @author Jamie Rasmussen (jrasmuss@mle.ie)

    @param data TCL code to format in HTML with syntax highlighing

} {
    array set HTML {
        comment   {<EM><FONT color="#006600">}
        /comment  {</FONT></EM>}
        procs     {<FONT color="#0033CC">}
        /procs    {</FONT>}
        str       {<FONT color="#990000">}
        /str      {</FONT>}
        var       {<FONT color="#660066">}
        /var      {</FONT>}
    }

    set data "\n$data"
    regsub -all {&} $data {\&amp;} data
    regsub -all {<} $data {\&lt;} data
    regsub -all {>} $data {\&gt;} data

    set KEYWORDS [concat {if elseif else while foreach for switch default} {break continue return error catch} {upvar uplevel eval exec source} {set unset append global split join} {concat list lappend lindex linsert llength lrange lreplace lsearch lsort} {info incr expr regexp regsub} {string file array open close read cd pwd glob filename seek} {clock encoding proc rename subst} {gets puts format scan} ]

    set COMMANDS [info commands]

    set html ""
    set length [string length $data]

    set in_comment 0
    set in_quotes 0
    set special_chars {^\s*\#|\n\s*\#|;\s*\#|\"|\$|\\|\n|\[|\}}

    set max_lines 1000 ;# Was helpful when testing
    while {1 || [incr max_lines -1]} {
        if {[regexp -indices $special_chars $data match]} {
            set j [lindex $match 1]

            if {$j} {
                # Copy ordinary text directly to HTML
                append html [string range $data 0 [expr $j-1]]
                set data [string range $data $j $length]
                set j 0
            }
            set char [string index $data 0]

            switch $char {

            \#  {
                set in_comment 1
                if {$in_quotes} {
                    append html "#"
                } else {
                    append html $HTML(comment)
                    set eol [expr [string first \n $data $j] - 1]
                    append html [string range $data $j $eol]
                    append html $HTML(/comment)
                    set j $eol
                }
                }

            \n  {
                set start 0
                set proc_name ""
                set in_comment 0
                append html "\n"
                if {!$in_quotes} {
                    if {[regexp {^\n([\t ]*)(::)?([A-Za-z][:A-Za-z0-9_]+)[\s\;\{]} $data match space colons proc_name]} {
                        if {[lsearch -exact ${KEYWORDS} $proc_name] != -1} {
                            append html "${space}$HTML(procs)${colons}${proc_name}$HTML(/procs)"
                        } elseif {[string match "ns*" $proc_name]} {
                            append html "${space}<A style=\"text-decoration:none\" href=\"tcl-proc-view?tcl_proc=$proc_name\">$HTML(procs)${colons}${proc_name}$HTML(/procs)</A>"
                        } elseif {[string match "*__arg_parser" $proc_name]} {
                            append html "${space}$HTML(procs)${colons}${proc_name}$HTML(/procs)"
                        } elseif {[lsearch $COMMANDS $proc_name] != -1}  {
                            append html "${space}<A style=\"text-decoration:none\" href=\"[api_proc_url $proc_name]\">$HTML(procs)${colons}${proc_name}$HTML(/procs)</A>"
                        } else {
                            append html "${space}${colons}${proc_name}"
                        }

                        incr j [expr [string length $space] + [string length $colons] + [string length $proc_name] ]
                    }
                }
                }

            \[  {
                set proc_name ""
                append html "\["
                if {!$in_comment} {
                    if {[regexp {^\[(\s*)(::)?([A-Za-z][:A-Za-z0-9_]+)[\s\]]} $data match space colons proc_name]} {
                        if {[lsearch -exact ${KEYWORDS} $proc_name] != -1} {
                            append html "${space}$HTML(procs)${colons}${proc_name}$HTML(/procs)"
                        } elseif {[string match "ns*" $proc_name]} {
                            append html "${space}<A style=\"text-decoration:none\"  href=\"tcl-proc-view?tcl_proc=$proc_name\">$HTML(procs)${colons}${proc_name}$HTML(/procs)</A>"
                        } elseif {[string match "*__arg_parser" $proc_name]} {
                            append html "${space}$HTML(procs)${colons}${proc_name}$HTML(/procs)"
                        } elseif {[lsearch -exact $COMMANDS $proc_name] != -1}  {
                            append html "${space}<A style=\"text-decoration:none\" href=\"[api_proc_url $proc_name]\">$HTML(procs)${colons}${proc_name}$HTML(/procs)</A>"
                        } else {
                            append html "${space}${colons}${proc_name}"
                        }

                        incr j [expr [string length $space] + [string length $colons] + [string length $proc_name]]
                    }
                } 
                }

            \$  {
                if {[regexp {^\$(\{?)([A-Za-z0-9\(\)_/]+)(\}?)} $data match pre var_name post]} {
                    if {![empty_string_p $pre]} {
                        append html "$HTML(var)\$\{${var_name}\}$HTML(/var)"
                        incr j [expr [string length $var_name] + 2]
                    } else {
                        append html "$HTML(var)\$${var_name}$HTML(/var)"
                        incr j [expr [string length $var_name]]
                    }
                } else {
                    append html "\$"
                }
                }

            \"  {
                if {$in_quotes} {
                    append html \"$HTML(/str)
                    set in_quotes 0
                } else {
                    append html $HTML(str)\"
                    set in_quotes 1
                }
                }

            \} {
               if {[regexp {^(\}\s*)(else|elseif)(\s*\{)} $data match pre els post]} {
                   append html ${pre}$HTML(procs)${els}$HTML(/procs)${post}
                   incr j [expr [string length $pre] + [string length $els] + [string length $post] - 1]
               } else {
                   append html "\}"
               }
               }

            \\ {
                   append html [string range $data $j [incr j]]
               }
            }
            set data [string range $data [expr $j+1] $length]
        } else {
            append html $data
            break
        }
    }

    # We added a linefeed at the beginning to simplify processing
    return [string range $html 1 [string length $html]]
}

