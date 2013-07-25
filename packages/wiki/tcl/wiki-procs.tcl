proc html_diff {doc1 doc2} {
    set out ""
    set i 0
    set j 0
    
    #set lines1 [split $doc1 "\n"]
    #set lines2 [split $doc2 "\n"]
    
    regsub -all \n $doc1 " <br />" doc1
    regsub -all \n $doc2 " <br />" doc2
    set lines1 [split $doc1 " "]
    set lines2 [split $doc2 " "]
    
    foreach { x1 x2 } [list::longestCommonSubsequence $lines1 $lines2] {
	foreach p $x1 q $x2 {
	    while { $i < $p } {
		set l [lindex $lines1 $i]
		incr i
		#puts "R\t$i\t\t$l"
		append out "<span class='removed'>$l</span>\n"
	    }
	    while { $j < $q } {
		set m [lindex $lines2 $j]
		incr j
		#puts "A\t\t$j\t$m"
		append out "<span class='added'>$m</span>\n"
	    }
	    set l [lindex $lines1 $i]
	    incr i; incr j
	    #puts "B\t$i\t$j\t$l"
	    append out "$l\n"
	}
    }
    while { $i < [llength $lines1] } {
	set l [lindex $lines1 $i]
	incr i
	#puts "$i\t\t$l"
	append out "<span class='removed'>$l</span>\n"
    }
    while { $j < [llength $lines2] } {
	set m [lindex $lines2 $j]
	incr j
	#puts "\t$j\t$m"
	append out "<span class='added'>$m</span>\n"
    }
    return $out
}


proc get_header_size {str} {
    set len [string len $str]
    return [expr {(5 - $len)}]
    
}

proc chr {c} {
    binary scan $c c1 v
    if ![info exists v] {
	return  -009090
    }
    return $v
}


proc util_cleanup_string {text} {
    regsub -all {[ \]\[\$]} $text {_} text
    return $text
}


proc wiki_parse_link {
    text
} {
    set label $text
    regexp {([^\|]+)\|([^\|]+)} $text match text label

    if {[regexp {^(http:|mailto:|ftp:|gopher:|server:|wiki:)(.+)} $text match proto arg]} {
	switch $proto {
	    server: {
		return "<a href=\"$arg\">$label</a>"  		
	    }
	    wiki: {
		return "<a href=\"/wiki/$arg\">$label</a>"  

	    }
	    default {
		return "<a href=\"$text\">$label</a>"  
	    }
	}
    }

    set text [util_cleanup_string $text]
    return "<a href=\"[wiki_serve_url $text]\">$label</a>"  
}

proc wiki_serve_url {
    page
} {
    return "index?page_url=[ad_urlencode $page]" 
}



proc show_ascii {text} {
    set lst ""
    regsub -all {(.)} $text {[lappend lst "\1" [chr "\1"]]} text 
    set text [subst $text]

    set html "Common Escape Sequences <Pre>
n = [chr "\n"]
r = [chr "\r"]
f = [chr "\f"]
t = [chr "\t"]
</pre>
<table cellspacing=0 cellpadding=3 border=1>"
    set chr_html "<tr>"
    set code_html "<tr>"
    foreach {chr code} $lst {
	append chr_html "<td><b>$chr</b></td>"
	append code_html "<td>$code</td>"
    }

    append chr_html "</tr>"
    append code_html "</tr>"
    
    append html "$chr_html$code_html</table>"
    return $html
}

proc wiki_text_2_html {text}  {

    ## First make the new line char platform neutral

    regsub -all {(\r\n|\r\r)} $text "\n" text




    ## Handle xmp code.

    set text [handle_block $text xmp wiki_xmp]

    ## Handle the block text

    set text [handle_block $text]

    set text [handle_block $text pre pre]

    set text [handle_block $text code wiki_code]


    ## Handle the preformatted text

    set lines [split $text "\n"]

    set text "" 
    set in_pre 0
    set pretext ""


    foreach line $lines {

	if {[regexp {^ (.*)} $line match _real_line ]} {

	    if {!$in_pre} {
		append text "<pre>"
		set in_pre 1
	    }
	    append pretext "$_real_line\n"
	    set line ""

	} else {

	    if {$in_pre} {
		append text "[ad_urlencode $pretext]</pre>\n"
		set pretext ""
		set in_pre 0
	    }

	    set line "$line\n"	    
	}
	append text "$line"
    }

    if {$in_pre} {
	append text "[ad_urlencode "$pretext"]</pre>"
    }


    ## Since the pre text is now safe we need to parse the urls and
    ## turn them into custom tags do some processing of the tags

    regsub -all {(<html>|<body>|</html>|</body>)} $text {} text    

    regsub -all {\[!([^!]+)!\]} $text {<a name="\1"></a>} text

    regsub -all {\[\[([^\]]+)\]\]} $text {<wiki_link \1>} text

    regsub -all {\[([^\]]+)\]} $text {<wiki_link \1>} text

    regsub -all {\[([^\]]+)\]} $text {<wiki_link \1>} text


    ## Handle the : to <dl> translation

    set lines [split $text "\n"]

    set text "" 
    set level 0
    set prev_empty_line_p 0

    foreach line $lines {

	if {[empty_string_p $line]} {

	    append text "\n"
	    continue

	} elseif {[regexp {^(:+)([^:]+)} $line match _ident _rest]} {
	    
	    set dl_depth [string length $_ident]
	    set dl_cnt [expr {$dl_depth - $level}]
	    
	    if {$dl_cnt < 0} {
		append text "[string repeat {</dl>} $level]"
		set dl_cnt $dl_depth
	    }

	    set new_line ""
	    if {$dl_cnt > 0} {
		set new_line "\n"
	    }
		
	    
	    set level [string length $_ident]
	    append text "$new_line[string repeat {<dl>} $dl_cnt]<dt><dd>$_rest"
	    set prev_empty_line_p 0

	} else {

	    append text "[string repeat {</dl>} $level]\n$line"
	    set level 0
	}
	
    }
    
    append text "[string repeat {</dl>} $level]"

    ## handle the * to ul translation

    set lines [split $text "\n"]

    set text "" 
    set level 0
    set prev_empty_line_p 0

    foreach line $lines {

	if {[empty_string_p $line]} {

	    append text "\n"
	    continue

	} elseif {[regexp {^(\*+)([^\*]+)} $line match _ident _rest]} {
	    
	    set dl_depth [string length $_ident]
	    set dl_cnt [expr {$dl_depth - $level}]
	    
	    
	    ## If the indent level has gone negative. We need to
	    ## close the tags
	    
	    if {$dl_cnt < 0} {
		set end [expr {$level - $dl_depth}]
		append text "[string repeat {</ul>} $end]"
		set dl_cnt 0
	    }

	    set new_line ""
	    if {$dl_cnt > 0} {
		set new_line "\n"
	    }

	    set level [string length $_ident]
	    append text "$new_line[string repeat {<ul>} $dl_cnt]<li>$_rest"
	    set prev_empty_line_p 0
	    
	} else {

	    append text "[string repeat {</ul>} $level]\n$line"
	    set level 0
	}
	
    }
    
    append text "[string repeat {</ul>} $level]"


    ## handle the # to ol translation

    set lines [split $text "\n"]

    set text "" 
    set level 0
    set prev_empty_line_p 0
    
    foreach line $lines {
	
	if {[empty_string_p $line]} {

	    append text "\n"
	    continue

	} elseif {[regexp {^(#+)([^#]+)} $line match _ident _rest]} {
	    
	    set dl_depth [string length $_ident]
	    set dl_cnt [expr {$dl_depth - $level}]
	    
	    
	    ## If the indent level has gone negative. We need to
	    ## close the tags
	    
	    if {$dl_cnt < 0} {
		set end [expr {$level - $dl_depth}]
		append text "[string repeat {</ol>} $end]"
		set dl_cnt 0
	    }

	    set new_line ""
	    if {$dl_cnt > 0} {
		set new_line "\n"
	    }
			    
	    set level [string length $_ident]
	    append text "$new_line[string repeat {<ol>} $dl_cnt]<li>$_rest"
	    set prev_empty_line_p 0
	    
	} else {

	    append text "[string repeat {</ol>} $level]\n$line"
	    set level 0
	}
	
    }
    
    append text "[string repeat {</ol>} $level]"


    ## Translate the newlines to line breaks

    regsub -all {\n\n} $text {<P>} text
    regsub -all {\n} $text {} text

    ## Now start parsing all the urls

    regsub -all {<wiki_link ([^>]+)>} $text {[wiki_parse_link {\1}]} text


    regsub -all {(\=\=+)([^\=]+)(\1)} $text {<H[string length {\1}]>\2</H[string length {\1}]>} text
        
    regsub -all {<pre>([^\<]+)</pre>} $text {<pre>[ns_urldecode {\1}]</pre>} text

    regsub -all {<wiki_xmp>([^\<]+)</wiki_xmp>} $text {<xmp>[ns_urldecode {\1}]</xmp>} text

    regsub -all {<wiki_code>([^\<]+)</wiki_code>} $text {<code>[ns_urldecode {\1}]</code>} text

    regsub -all {<wiki_block(.*?)>([^\<]+)</wiki_block>} $text {[wiki_text_2_html "[ns_urldecode {\2}]"]} text

    return "[subst $text]"
 
}


proc handle_block {text {tag block} {to_tag wiki_block}} {

    ## block level start and end tags should be on seperate lines 
    ## or they will not be handled correctly
    ## Next we handle and parse block level elements

    set start_match [format {(.*)<%1$s([^>]*)>(.*)} $tag]
    set end_match  [format {(.*)</%1$s>(.*)} $tag] 

    set lines [split $text "\n"]

    set text "" 
    set in_block 0
    set blocktext ""

    foreach line $lines {

	if {[regexp $start_match $line match _text _block_param _block_text]} {

	    if {!$in_block} {
		set param $_block_param
		append text "$_text"
		set blocktext "$_block_text\n"
	    } else {
		append blocktext "$line\n"

	    }	

	    set line ""	    
	    incr in_block
		
	} elseif {[regexp $end_match $line match _block_text _text]} {
	    append blocktext "$_block_text\n"

	    if {$in_block == 1} {
		append text "<$to_tag$param>[ad_urlencode $blocktext]</$to_tag>$_text\n"
		set in_block 0
	    } elseif {$in_block}  {
		append blocktext "$line\n"
		set in_block [expr {$in_block - 1}]
	    }

	    set line ""

	} else {

	    if {$in_block} {
		append blocktext "$line\n"
		set line ""
	    }  else {
		set line "$line\n"
	    }
	    
	}

	append text "$line"
    
    }
    return $text
}


proc my_wiki_2_html {text} {
    return [wiki_text_2_html $text]
}

proc debug {str} {
    set debug_p 1
    if $debug_p {
	ns_log Notice $str
    }
}
