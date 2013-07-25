#
# Structured Text Manipulation
#
# Copyright (C) 2003 Neophytos Demetriou
#

proc text_to_html { text } {
    set paragraphs [splitx [untabify ${text}] {(\r?\n *)+\r?\n}]
    set result ""
    foreach para $paragraphs {
	append result <p>[string map {\n <br>} [string trim [::util::quotehtml ${para}] \n]]</p>
    }
    return $result
}



proc stx_to_html  { str args } {
    ::xo::html::iuse {pre b i h code bold italic highlight}

    set image_prefix ""
    set root_of_hierarchy "NO_ROOT_OF_HIERARCHY"
    set edit_p 0
    set object_id X
    foreach {switch value} ${args} {
	if { [string equal ${switch} "-edit_p"] } {
	    set edit_p ${value}
	}
	if { [string equal ${switch} "-root_of_hierarchy"] } {
	    set root_of_hierarchy ${value}
	}
	if { [string equal ${switch} "-image_prefix"] } {
	    set image_prefix ${value}
	}
	if { [string equal ${switch} "-object_id"] } {
	    set object_id ${value}
	}
    }

    ## Paragraph divider 
    set paragraphs [splitx [untabify ${str}] {(\r?\n *)+\r?\n}]

    set depth 0
    set prev_indent_level -1
    set prev_real_indent_level -1
    set preformatted_p 0
    set stack_indent_levels "-1"
    set stack_close_tags "<empty>"
    set result ""
    set prev_preformatted_p 0
    set special_text ""
    foreach p ${paragraphs} {

	set p [string trimright ${p}]
	set this_indent_level [indent_level ${p}]
	set this_fake_indent_level ${this_indent_level}

	if {[regexp {^[ \t\n\r]*$} ${p}]} {
	    append result ${p}\n\n
	    continue
	}

	if {${preformatted_p} && ${prev_indent_level} < ${this_indent_level}} {

	    append special_text "${p}\n\n"

	    set prev_preformatted_p 1
	    continue
	} else {


	    set tag ""
	    if {[regexp {^[ \t\n]*([*o\-\#])([ \t\n]+[^\0]*)} ${p} match bullet p]} {
		switch -- ${bullet} {
		    "-"  -
		    "*"  -
		    "o"  { set tag "ul"; set otag "<ul>"; set ctag "</ul>" }
		    "\#" { set tag "ol"; set otag "<ol>"; set ctag "</ol>" }
		}
	    } else {
		if {${this_indent_level} == 0} {
		    set tag ""
		    set otag ""
		    set ctag "<empty>"
		} else {
		    set tag ""
		    set otag \x001\x001\x001
		    set ctag </div>
		    #set otag "<p,style=\"text-indent:5em;\">"
		    #set ctag "</p>"
		    #set otag <blockquote>
		    #set ctag </blockquote>
		}
	    }
	}


	if {${prev_preformatted_p}} {
	    append result [Special_Text_Handler ${special_text_handler} ${edit_p} ${special_text}]
	    set special_text ""
	    set prev_preformatted_p 0
	}


	set preformatted_p {HERE [regexp {^(.*)(::|%%|\$\$|##)[ \t\n\r]*$} ${p} __dummy__ p special_text_handler]}

	set preformatted_p [regexp {^(.*)(::|%%|##)[ \t\n\r]*$} ${p} __dummy__ p special_text_handler]

	if {${this_indent_level} > ${prev_indent_level}} {
	    ## Required in order to enable multi-paragraph bullet items.
	    switch -- ${tag} {
		"ul"    -
		"ol"    -
		"dl"    {
		    incr depth
		    append result ${otag}
		    lappend stack_indent_levels ${this_indent_level}
		    append result "<li>[eval "decorate -image_prefix [list $image_prefix] -root_of_hierarchy $root_of_hierarchy -object_id [list ${object_id}] -str [list ${p}] -depth ${depth} $args"]</li>" 
		}
		default { 
		    if {${this_indent_level} <= ${prev_real_indent_level}} {
# prev_real_indent_level == -1
			#set tag ""
			#set this_indent_level ${prev_indent_level}
			set ctag <empty>
			set this_fake_indent_level ${prev_real_indent_level}
			### HERE: Remove below
			set this_indent_level ${prev_indent_level}
			#lappend stack_indent_levels ${this_indent_level}
		    } else {
			incr depth
			append result ${otag}
			lappend stack_indent_levels ${this_indent_level}
		    }
		    append result "<p>[eval "decorate -image_prefix [list $image_prefix] -root_of_hierarchy $root_of_hierarchy -object_id [list ${object_id}] -str [list ${p}] -depth ${depth} $args"]</p>" 
		}
	    }
	    set stack_close_tags [concat "${ctag} ${stack_close_tags}"]

	} else {
	    ## If the indent level has gone negative. We need to close the tags
	    set include_otag_p 0
	    set depth 0
	    set indent_level 0
	    foreach indent_level ${stack_indent_levels} {
		if {${this_indent_level} > ${indent_level}} {
		    incr depth
		} else {
		    break
		}
	    }

	 

	    set top_ctag [lindex ${stack_close_tags} end-${depth}]
	    if {![string equal ${top_ctag} ${ctag}]} {
		if {![string equal ${tag} ""]} {
		    set include_otag_p 1
		    set pivot [expr ${depth}-1]
		} else {
		    set include_otag_p 0
		    set pivot [expr ${depth}-1] ;#why depth alone is not more correct, check it out
		    if {${this_indent_level} < ${indent_level}} {
			set this_indent_level ${indent_level}
		    }
		}
	    } else {
####		append result HERE:${prev_real_indent_level}-${prev_indent_level}-${this_indent_level}-${this_fake_indent_level}-[ad_quotehtml ${ctag}-${top_ctag}]-${indent_level}
		set include_otag_p 0
		set pivot ${depth}
		#below: for subparagraphs to work ok
		# if {${indent_level} == ${this_indent_level}} {
# 		    incr pivot
# 		    append result here
# 		}
		if {${this_indent_level} < ${indent_level}} {
		    set this_indent_level ${indent_level}
		}
	    }
####	    append result [ad_quotehtml before:${stack_close_tags}]-----
####	    append result [ad_quotehtml [lrange ${stack_close_tags} 0 end-[expr ${pivot}+1]]]
	    append result [lrange ${stack_close_tags} 0 end-[expr ${pivot}+1]]

	    set stack_indent_levels [lrange ${stack_indent_levels} 0 ${depth}]
	    set stack_close_tags [lrange ${stack_close_tags} end-${pivot} end]

#####	    append result ====[ad_quotehtml after:${stack_close_tags}]


	    if {${include_otag_p}} {
		append result ${otag}
		#lappend stack_indent_levels ${this_indent_level}
		set stack_close_tags [concat "${ctag} ${stack_close_tags}"]
	    }


	    switch -- ${tag} {
		"ul"    -
		"ol"    -
		"dl"    { append result "<li>[eval "decorate -image_prefix [list $image_prefix] -root_of_hierarchy $root_of_hierarchy -object_id [list ${object_id}] -str [list ${p}] -depth ${depth} $args"]</li>" }
		default { append result "<p>[eval "decorate -image_prefix [list $image_prefix] -root_of_hierarchy $root_of_hierarchy -object_id [list ${object_id}] -str [list ${p}] -depth ${depth} $args"]</p>" }
	    }
	}

	switch -- ${tag} {
	    "ul"    -
	    "ol"    -
	    "dl"    { set prev_real_indent_level [expr 1+${this_indent_level}+[indent_level ${p}]] }
	    default { 
		set prev_real_indent_level ${this_fake_indent_level}
	    }
	}

	set prev_indent_level ${this_indent_level}
    }

    if {${prev_preformatted_p}} {
	append result [Special_Text_Handler ${special_text_handler} ${edit_p} ${special_text}]
	set prev_preformatted_p 0
    }

    append result [join ${stack_close_tags}]

    set result [string map {\x001\x001\x001 {<div style="margin-left: 2em;">}} ${result}]

    return ${result}

}

# check core-platform/tcl/00-utilities/00-tcl-documentation-procs.tcl
proc stx_from_input {str} {

    # U+20AC: Euro Sign
    # U+00A3: Pound Sign
    # U+20A4: Lira Sign
    # U+00A5: Yen Sign
    # U+20A3: French Franc Sign
    # U+00A2: Cent Sign
    # U+00A4: Currency Sign
    # U+00BC: Vulgar Fraction One Quarter
    # U+00BD: Vulgar Fraction One Half
    # U+00BE: Vulgar Fraction Three Quarters
    # U+00AB: Left-Pointing Double Angle Quotation Mark
    # U+00BB: Right-Pointing Double Angle Quotation Mark

    regsub -all -- \u2014 ${str} {---} str
    regsub -all -- \u2013 ${str} {--} str
    regsub -all -- \u2026 ${str} {...} str
    regsub -all -- \uae ${str} {(R)} str
    regsub -all -- \u2122 ${str} {(TM)} str
    regsub -all -- \ua9 ${str} {(C)} str

#    set regexp {[a-z0-9]+(?:\-[a-z]*)?(?:\'[a-z])?(?:_[a-z0-9]+(?:\-[a-z]*)?(?:\'[a-z])?)*}
#    regsub -all -nocase -- "http\:\/\/www\.phigita\.net\/wiki\/(${regexp})" ${str} ((\\1)) str

    return ${str}
}

proc stx_symbols_to_output {_str} {
    upvar ${_str} str

    # mdash = 8211
    # ndash = 8212
    # reg = 174
    # trade = 8482
    # copy = 169
    # hellip = 8230
    # HERE: remember to convert these strings into their text equivalent upon input from the user

    # NOTE THAT UPON CHANGING ENCODING WE WILL NEED TO CONVERT THE ACTUAL UTF-8 CHARACTER RATHER THAN THIS STRING OF CHARS!!!

    regsub -all -- {---} ${str} \u2014 str
    regsub -all -- {--} ${str} \u2013 str
    regsub -all {\.\.\.} ${str} \u2026 str
    regsub -nocase -all {\(R\)} ${str} \uae str
    regsub -nocase -all {\(TM\)} ${str} \u2122 str
    regsub -nocase -all {\(C\)} ${str} \ua9 str
    regsub -all -- {\&quot\;} ${str} \" str
    regsub -all -- {\&amp\;} ${str} {\&} str

    if { [string equal [ad_conn user_id] 0] } {
        regsub -all -- "\[^@<>\"\t ]+@\[^@<>\".\t ]+(\\.\[^@<>\".\n ]+)+" ${str} { <font color=red>\&lt;email protected\&gt</font> } str
    }

}

proc HREF_1 {_str} {

    upvar ${_str} str

    #{regsub -nocase -all {\"([^\x001\"]+)\":((http://|https://|ftp://|file://|mailto:|news:|about:)[^\(\)\"<>\s\x001]*[^\(\)\"<>\s.:;?\x001])} ${str} "\x001sTaRtUrL\\1\x001\\2eNdUrL\x001" str}

   # regsub -nocase -all {^(http://[^\(\)\"<>\s]*[^\(\)\"<>\s\.,\*\':;?])} ${str} "\x001sTaRtUrL\\1\x001\\1eNdUrL\x001" str

    regsub -nocase -all {\"\s*([^\"\x001\x002]+)\s*\":(http://|mailto:)([^\(\)\[\]\{\}\"\s\x001\x002]*[^\(\)\[\]\{\}\"\s\.,\*\':;?!\x001\x002]|[^\(\)\[\]\{\}\"\s\x001\x002]*\([^\(\)\[\]\{\}\"\s\x001\x002]*\)[^\(\)\[\]\{\}\"\s\.,\*\':;?!\x001\x002]*)} ${str} "\x001sTaRtUrL\x002\\1\x001\\3\x002eNdUrL\x001" str

    regsub -nocase -all {([^\x001\x002]|^)http://([^\(\)\"\s\x001]*[^\(\)\[\]\{\}\"\s\.,\*\':;?!\x001]|[^\(\)\[\]\{\}\"\s\x001]*\([^\(\)\[\]\{\}\"\s\x001]*\)[^\(\)\[\]\{\}\"\s\.,\*\':;?!\x001]*)} ${str} "\\1\x001sTaRtUrL\x002http://\\2\x001\\2\x002eNdUrL\x001" str
    


    regsub -nocase -all {\"([^\"]+)\":isbn:([0-9]{10})([^0-9])} ${str} "\x001sTaRtISBN\\1\x001\\2eNdISBN\x001\\3" str

}

proc HREF_2 {_str} {
    
    upvar ${_str} str

    regsub -all {\x001sTaRtUrL\x002([^\x001\x002]*)\x001(www.phigita.net/[^\x001\x002]*)\x002eNdUrL\x001} ${str} {<a href="http://\2" style="border-bottom: 1px dotted;">\1</a>} str  


    #set video_url_fmtstr {<center><object width="425" height="350"><param name="movie" value=http://www.youtube.com/v/\4 /><param name="wmode" value="transparent" /><embed src=http://www.youtube.com/v/\4 type="application/x-shockwave-flash" wmode="transparent" width="425" height="350" /></object></center>}
    #regsub -all {\x001sTaRtUrL\x002([^\x001\x002]*)\x001(www|uk)(.youtube.com/watch\?v=)([^?&\x001\x002]*)\x002eNdUrL\x001} ${str} $video_url_fmtstr str
    ;#{HERE:<a href="http://\2\3\4" style="border-bottom: 1px dotted;">\1</a>} str  

    regsub -all {\x001sTaRtUrL\x002([^\x001\x002]+)\x001([^\x001\x002]+)\x002eNdUrL\x001} ${str} {<a href="http://\2" style="text-decoration:none; border-bottom: 1px dotted;">\1</a>} str  

    #regsub -all {\x001sTaRtISBN([^\x001]*)\x001([^\x001]*)eNdISBN\x001} ${str} {<a href="http://www.phigita.net/ct?url=http://www.amazon.com/exec/obidos/ISBN=\2/phigitanet/">\1</a>} str 
    
    regsub -all {\x001sTaRtISBN([^\x001]*)\x001([^\x001]*)eNdISBN\x001} ${str} {<u title="ISBN: \2"><i>"\1"</i></u>} str 

}

proc MATH_EQUATION {_str regexp {allow_math_p 0} {allow_html_p 0} {before_html ""} {after_html ""}} {

    upvar ${_str} str

    set start 0
    while {[regexp -start $start -indices -- $regexp $str match submatch]} {
	lassign $submatch subStart subEnd
	lassign $match matchStart matchEnd

        incr matchStart -1
        incr matchEnd
        append tmpstr [string range $str $start $matchStart]
	append tmpstr " "
        if {$subStart >= $start} {
	    ## set auxstr [string map {{ } {}} [string range $str [expr $matchStart +1] [expr $matchEnd -1]]]
	    set auxstr [string trim [string range $str [expr $matchStart +1] [expr $matchEnd -1]]]
	    ## Removed ''if allow_html_p from here''
	    set math [ns_urlencode ${auxstr}]
	    set alt [ad_quotehtml [string map {{ } {}} ${auxstr}]]
	    
            append tmpstr ${before_html}
	    if {${allow_math_p}} {
		set signature [ns_sha1 "MaThSeCrEt-${auxstr}-83765md"]
		append tmpstr "<img src=\"/math/?eqn=${math}&s=${signature}\" title=\"${alt}\" />"
	    } else {
		append tmpstr "<code><b>${alt}</b></code>"
	    }
            append tmpstr ${after_html}
        }
        set start $matchEnd
	append tmpstr " "
    }
    append tmpstr [string range $str $start end]
    
    set str ${tmpstr}

}


ad_proc decorate {
    {-str ""}
    {-depth "0"}
    {-allow_html_p "0"}
    {-allow_href_p "1"}
    {-allow_image_p "0"}
    {-allow_style_p "1"}
    {-allow_images_p "1"}
    {-allow_heading_p "1"}
    {-allow_math_p "0"}
    {-allow_wiki_p "1"}
    {-start_depth "2"}
    {-edit_p "0"}
    {-image_prefix ""}
    {-object_id "X"}
    {-root_of_hierarchy "NO_ROOT_OF_HIERARCHY"}
} {
    @author Neophytos Demetriou (k2pts@phigita.net)
} {

    incr depth ${start_depth}

    if {[string equal ${str} ""]} { return "" }

    if {${allow_href_p}} {
	# Mark the links and emails before we quote the html tags
	HREF_1 str
    }

    if {!${allow_html_p}} {
	set str [ad_quotehtml ${str}]
    }

    if {${allow_href_p}} {
	# Dress the links and emails with a HREF
	HREF_2 str
    }

    if {${allow_wiki_p}} {
	WIKI str
    }

    set ctag_prefix {([\x00- \\(]|^)}
    set ctag_suffix {([\x00- ,.:;!?\\\)]|$)}
    set ctag_middle {[%1$s]([^\x00- %1$s][^%1$s]*[^\x00- %1$s]|[^%1$s])[%1$s]}
    set ctag_middl2 {[%1$s][%1$s]([^\x00- %1$s][^%1$s]*[^\x00- %1$s]|[^%1$s])[%1$s][%1$s]}

    # Displaymath -- The displaymath environment is for formulas that appear on their own line.
    MATH_EQUATION str ${ctag_prefix}[format ${ctag_middl2} {\$}]${ctag_suffix} ${allow_math_p} ${allow_html_p} "<center>" "</center>"

#	regsub -all -- ${ctag_prefix}[format ${ctag_middl2} {\$}]${ctag_suffix} ${str} {\1<strong>\2</strong>\3} str

    # Math -- The math environment is for formulas that appear right in the text.
    MATH_EQUATION str ${ctag_prefix}[format ${ctag_middle} {\$}]${ctag_suffix} ${allow_math_p} ${allow_html_p}
    

    if {${allow_style_p}} {

	    set para $str
	    set HEX06 \x06
	    set para [getHtmlForStxSymbol ${para} {**} {[*][*]} "${HEX06}bold\x15\\1\x16"]
	    set para [getHtmlForStxSymbol ${para} {''} {[\'][\']} "${HEX06}highlight\x15\\1\x16"]
	    set para [getHtmlForStxSymbol ${para} {*} {[*]} "${HEX06}italic\x15\\1\x16"]

	    regsub -all -- {\x15([^\x06\x15]+)\x16} $para "\x02\">\x16\\1\x16</span>\x16" para
	    regsub -all -- {(^|[^\x15])\x06([^\x02]+)\x02} $para "\\1\x06<span class=\"\\2" para
	    regsub -all -- {\x15\x06} $para { } para

    }

	if { ${allow_images_p} } {
	    set configDict [dict create image_prefix $image_prefix root_of_hierarchy $root_of_hierarchy object_id $object_id]
	    set para [getHtmlForStxItem para $configDict]
	}

	set str [string map {\xA0 "" \xAD "" \x02 "" \x05 "" \x06 "" \x15 "" \x16 ""} $para]

    if {${allow_heading_p}} {
	# Heading
	regsub -all ${ctag_prefix}[format ${ctag_middl2} ==]${ctag_suffix} ${str} \\1<h${depth}>\\2</h${depth}>\\3 str
    }


    regsub -all -- {-{5,}} ${str} {<p><center><table><tr><td><img src="" width="100" height="1" style="background-color:#000000;"></td><td align="center"><img src="/graphics/divider.png" width="55" height="12"></td><td><img src="/graphics/cleardot.gif" width="100" height="1" style="background-color:#000000;"></td></tr></table></center><p>} str

    regsub -all -- {={5,}} ${str} {<p><center><table><tr><td><img src="" width="100" height="1" style="background-color:#000000;"></td><td align="center"><img src="/graphics/divider.png" width="55" height="12"></td><td><img src="/graphics/cleardot.gif" width="100" height="1" style="background-color:#000000;"></td></tr></table></center><p>} str

    stx_symbols_to_output str

    return ${str}

    }


    proc getHtmlForStxItem=image {paraVar configDict} {
	upvar $paraVar para

	set tmpstr ""
	dict with configDict {
	    append tmpstr [string range $para $start $matchStart]
	    append tmpstr " "

	    set argv [string trim [string range $para $subStartArgs $subEndArgs]]
	    set argv_parts [split $argv {|}]

	    set item_id [string trim [string range $para $subStartIdentifier $subEndIdentifier]]
	    set time [clock seconds]
	    set secret_token [ns_sha1 sEcReT-iMaGe-${root_of_hierarchy}-${item_id}-${time}-${object_id}]
	    set item_url "${image_prefix}image/${item_id}-${secret_token}-${time}-${object_id}"
	    set item_alignment [string trim [lindex $argv_parts 0]]
	    set item_caption [string trim [lindex $argv_parts 1]]

	    if { -1 == [lsearch "left right center" [string trim $item_alignment]] } {
		set item_alignment "none"
	    }

	    if { $object_id ne {X} } {
		append tmpstr "<div style=\"text-align:center;\"><a href=\"${item_url}-s500\"><img class=\"z-align-${item_alignment}\" src=\"${item_url}-s240\" identifier=\"${item_id}\" border=0 /></a>"
	    } else {
		append tmpstr "<div style=\"text-align-center;\"><img class=\"z-align-${item_alignment}\" src=\"${item_url}-s240\" identifier=\"${item_id}\" />"
	    }

	    if { $item_caption ne {} } {
		append tmpstr "<div class=\"z-image-caption\" style=\"text-align:${item_alignment}\">${item_caption}</div>"
	    }
	    append tmpstr "</div>"

	    append tmpstr " "
	}
	set tmpstr
    }

    proc getHtmlForStxItem=video {paraVar configDict} {
	upvar $paraVar para
	set result ""
	dict with configDict {
	    set properties ""
	    set caption ""
	    set clip_id [string range $para $subStartIdentifier $subEndIdentifier]
	    set argv [string trim [string range $para $subStartArgs $subEndArgs]]
	    set argv_parts [split $argv {|}]
	    lassign $argv_parts properties caption

	    ns_log notice clip_id=$clip_id
	    append result [::xo::html::wrap_dom_script {
		::xo::media::embed_video $clip_id
	    }]
	    if { $caption ne {} } {
		append result "<div class=\"z-video-caption\" style=\"text-align:center\">${caption}</div>"
	    }
	    #set url http://www.youtube.com/v/
	    #append result [subst -nocommands -nobackslashes {<object width="425" height="350"><param name="movie" value="$url" /><param name="wmode" value="transparent" /><embed src="$url" type="application/x-shockwave-flash" wmode="transparent" width="425" height="350" /></object>}]
        }

	set result
    }

    proc getHtmlForStxItem {paraVar configDict} {
	upvar $paraVar para

	#Uncomment to enable videos
	set regexp {\{(image|video):([0-9a-z_.]+)\s*([^\{\}\r\n]*)\}}
	#set regexp {\{(image):([0-9]+)\s*([^\{\}\r\n]*)\}}
	set tmpstr ""
	set start 0
	while {[regexp -start $start -indices -nocase -- $regexp $para match subMatchFiletype subMatchIdentifier subMatchArgs]} {
	    lassign $subMatchIdentifier subStartIdentifier subEndIdentifier
	    lassign $subMatchArgs subStartArgs subEndArgs

	    lassign $subMatchFiletype subStartFiletype subEndFiletype
	    lassign $match matchStart matchEnd
	    incr matchStart -1

	    set filetype [string tolower [string range $para $subStartFiletype $subEndFiletype]]
	    
	    dict set configDict filetype $filetype
	    dict set configDict start $start 

	    dict set configDict match $match
	    dict set configDict matchStart $matchStart
	    dict set configDict matchEnd $matchEnd

	    dict set configDict subMatchIdentifier $subMatchIdentifier
	    dict set configDict subStartIdentifier $subStartIdentifier
	    dict set configDict subEndIdentifier $subEndIdentifier

	    dict set configDict subMatchArgs $subMatchArgs
	    dict set configDict subStartArgs $subStartArgs
	    dict set configDict subEndArgs $subEndArgs

	    append tmpstr [getHtmlForStxItem=$filetype para $configDict]
	    incr matchEnd
	    set start $matchEnd
	}
	append tmpstr [string range $para $start end]
	return $tmpstr
    }

    proc getHtmlForStxSymbol {para defaultString regexp newString} {
	regsub -all -- ${regexp} ${para} "\x05" para
	regsub -all -- "\x05(\[^\x05\]+)\x05" ${para} ${newString} para
	regsub -all -- "\x05" ${para} ${defaultString} para
	return $para
    };


proc Handler_Preformatted_Text {str} {
    
    set str [ad_quotehtml ${str}]
    #regsub -all -- \n ${str} {<br />} str
    #regsub -all -- \n\n ${str} {<p />} str
    regsub -all -- "  " ${str} {\&nbsp; } str
    return [subst -nobackslashes {<div class="pre">[decorate -str ${str}]</div>}]

}

proc Special_Text_Handler {handler edit_p str} {

    switch -exact -- ${handler} {
	{::} {
	    Special_Text_Handler=Preformatted ${edit_p} str
	}
	{%%} {
	    Special_Text_Handler=Code str
	}
	{$$} {
	    Special_Text_Handler=Math str
	}
	{||} {
	    Special_Text_Handler=Table str
	}
	{##} {
	    Special_Text_Handler=Data_Source str
	}
    }

}

proc Special_Text_Handler=Preformatted {edit_p _str} {
    upvar ${_str} str
    set str [decorate -str ${str}]
#    set str [ad_quotehtml ${str}]
    stx_symbols_to_output str
    set str [string map {"\n" {<br />}} ${str}]
    #regsub -all -- \n ${str} {<br />} str
    #regsub -all -- \n\n ${str} {<p />} str
    regsub -all -- "  " ${str} {\&nbsp; } str
    if { ${edit_p} } {
	return [subst -nobackslashes {<pre>${str}</pre>}]
    } else {
	return [subst -nobackslashes {<div class="pre">${str}</div>}]
    }

    ## {style="margin-left: 3em; padding-left: 0.5em;  border-left: 0.3em solid #99c; margin-bottom: 0; background-color: #efefef;"}
}

proc Special_Text_Handler=Code {_str} {
    upvar ${_str} str
    set str [ad_quotehtml ${str}]
#    regsub -all -- \n ${str} {<br />} str
#    regsub -all -- \n\n ${str} {<p />} str
    regsub -all -- "  " ${str} {\&nbsp; } str
    return [subst -nobackslashes {<div class="code">${str}</div>}]
}

proc Special_Text_Handler=Math {_str} {
    upvar ${_str} str
    set auxstr "\$\$[string trim ${str}]\$\$"
    set math [ns_urlencode ${auxstr}]
    set alt [ad_quotehtml [string map {{ } {}} ${str}]]
    set signature [ns_sha1 "MaThSeCrEt-${str}-83765md"]
    return "<div style=\"margin-left: 3em; padding-left: 0.5em;\"><img src=\"/math/?eqn=${math}&s=${signature}\" title=\"${alt}\" />hello</div>"

    ## The Math environment may have directives to be used for plotting the graph of the given equation.
}

proc Special_Text_Handler=Table {_str} {
    upvar ${_str} str
    # Allows images, links, etc

}

proc Special_Text_Handler=Data_Source {_str} {
    upvar ${_str} str

    # Just data, no images included, no links

    set tmpstr ""
    if {![string equal [string trim ${str}] ""]} {
	append tmpstr {<table border=1>}
	foreach row [split ${str} \n] {
	    append tmpstr {<tr>}
	    foreach column [split ${row} "|"] {
		append tmpstr "<td>${column}</td>"
	    }
	    append tmpstr {</tr>}
	}
	append tmpstr {</table>}
    }

    return ${tmpstr}
}

proc Special_Text_Handler=Graph {_str} {
    upvar ${_str} str

}

proc WIKI {_str} {
    upvar ${_str} str


    set regexp {(?:\"([^\"]+)\":)?\(\(([a-z0-9]+(?:\-[a-z]*)?(?:\'[a-z])?( [a-z0-9]+(?:\-[a-z]*)?(?:\'[a-z])?)*)\)\)}

    set tmpstr ""
    set start 0
    while {[regexp -start $start -indices -nocase -- $regexp $str match submatchtext submatchlink]} {
        lassign $submatchtext subStartText subEndText
        lassign $submatchlink subStartLink subEndLink
        lassign $match matchStart matchEnd
        incr matchStart -1

        append tmpstr [string range $str $start $matchStart]
	append tmpstr " "

        if { $subEndLink - $subStartLink <= 255 } {

	    set auxLink [string map {{ } _} [string range $str $subStartLink $subEndLink]]

	    if { $subStartText !=-1 && $subEndText !=-1 } {
		set auxText [string range $str $subStartText $subEndText]
	    } else {
		set auxText [string range $str $subStartLink $subEndLink]
	    }

	    append tmpstr "<a href=\"/wiki/${auxLink}\">${auxText}</a>"

        } else {

	    append tmpstr [string range $str $start $matchEnd]

	}

	append tmpstr " "
        incr matchEnd
        set start $matchEnd
    }
    append tmpstr [string range $str $start end]
    
    set str ${tmpstr}


}
