# /tcl/ad-navigation.tcl
#
# created by philg 11/5/98, adapted originally from 
# the Cognet server 
#
# edited February 28, 1999 by philg to include support for a 
# Yahoo-style navigation system (showing users where they are in a
# hierarchy)
#
# ad-navigation.tcl,v 3.2 2000/02/21 10:34:24 ron Exp
# -----------------------------------------------------------------------------


# a context bar, rooted at the workspace

proc_doc ad_context_bar_ws args "Returns a Yahoo-style hierarchical navbar, starting with a link to workspace." {
    set choices [list "<a href=\"[ad_pvt_home]\">Your Workspace</a>"]
    set index 0
    foreach arg $args {
	incr index
	if { $index == [llength $args] } {
	    lappend choices $arg
	} else {
	    lappend choices "<a href=\"[lindex $arg 0]\">[lindex $arg 1]</a>"
	}
    }
    return [join $choices " : "]
}

# a context bar, rooted at the workspace or index, depending on whether
# user is logged in

proc_doc ad_context_bar_ws_or_index args "Returns a Yahoo-style hierarchical navbar, starting with a link to either the workspace or /, depending on whether or not the user is logged in." {
    if { [ad_get_user_id] == 0 } {
	set choices [list "<a href=\"/\">[ad_system_name]</a>"] 
    } else {
	set choices [list "<a href=\"[ad_pvt_home]\">Your Workspace</a>"]
    }
    set index 0
    foreach arg $args {
	incr index
	if { $index == [llength $args] } {
	    lappend choices $arg
	} else {
	    lappend choices "<a href=\"[lindex $arg 0]\">[lindex $arg 1]</a>"
	}
    }
    return [join $choices " : "]
}

proc_doc ad_admin_context_bar args "Returns a Yahoo-style hierarchical navbar, starting with links to workspace and admin home.  Suitable for use in pages underneath /admin." {
    set choices [list "<a href=\"[ad_pvt_home]\">Your Workspace</a>" "<a href=\"/admin/\">Admin Home</a>"]
    set index 0
    foreach arg $args {
	incr index
	if { $index == [llength $args] } {
	    lappend choices $arg
	} else {
	    lappend choices "<a href=\"[lindex $arg 0]\">[lindex $arg 1]</a>"
	}
    }
    return [join $choices " : "]
}

proc_doc ad_navbar args "produces navigation bar. notice that navigation bar is different than context bar, which exploits a tree structure. navbar will just display a list of nicely formatted links." {
    set counter 0
    foreach arg $args {
	lappend link_list "<a href=\"[lindex $arg 0]\">[lindex $arg 1]</a>"
	incr counter
    }
    if { $counter > 0 } {
	return "\[[join $link_list " | "]\]"
    } else {
	return ""
    }
}

#  -- Cognet stuff 

# an automatically maintained navigation system
# the can show the user links to a document one level 
# up and/or links to other sections

# directories that should not receive links to move up one level

proc ad_no_uplevel_patterns {} {
    set regexp_patterns [list]
    lappend regexp_patterns "/pvt/home.tcl"
    # tcl files in the root directory
    lappend regexp_patterns "^/\[^/\]*\.tcl\$"
    lappend regexp_patterns "/admin*"
}

# list of the search sections that should appear in the the search block
 
proc pretty_search_sections {} {
    return {"All of Cognet" "Library" "HotScience" "Jobs" "The Forum" "Member Profiles" "Posters" "Almanac"}
}

# list of search values for the search block -- These pair up to 
# pretty_search_sections to make the search form and should also
# match the section variable that runs the menu

proc search_sections {} {
    return {"all" "library" "hotscience" "jobs" "forum" "member_profiles" "posters" "almanac"}
}


# list of menu items to be generated (in this order)

proc menu_items {} {
    return {"library" "hotscience" "jobs" "forum" "member_profiles" "seminar_manager" "your_workspace"}
}


# determines if java_script should be enabled
    
proc java_script_capabilities {} {
    set user_agent ""
    set version 0
    set internet_explorer_p 0
    set netscape_p 0
	
    # get the version
    set user_agent [ns_set get [ns_conn headers] User-Agent]
    regexp -nocase "mozilla/(\[^\.\ \]*)" $user_agent match version

    # IE browsers have MSIE and Mozilla in their user-agent header
    set internet_explorer_p [regexp -nocase "msie" $user_agent match]

    # Netscape browser just have Mozilla in their user-agent header
    if {$internet_explorer_p == 0} {
	set netscape_p [regexp -nocase "mozilla" $user_agent match]
    }
   
    set java_script_p 0
 
    if { ($netscape_p && ($version >= 3)) || ($internet_explorer_p && ($version >= 4)) } {
	set java_script_p 1
    }

    return $java_script_p
}

# netscape3 browser has a different output

proc netscape3_browser {} {
    set user_agent ""
    set version 0
    set internet_explorer_p 0
    set netscape_p 0
    
    # get the version
    set user_agent [ns_set get [ns_conn headers] User-Agent]
    regexp -nocase "mozilla/(\[^\.\ \]*)" $user_agent match version
    
    # IE browsers have MSIE and Mozilla in their user-agent header
    set internet_explorer_p [regexp -nocase "msie" $user_agent match]
    
    # Netscape browser just have Mozilla in their user-agent header
    if {$internet_explorer_p == 0} {
	set netscape_p [regexp -nocase "mozilla" $user_agent match]
    }
 
    set netscape3_p 0
 
    if { ($netscape_p && ($version == 3))} {
	set netscape3_p 1
    }

    return $netscape3_p
}


proc bgcolor {}  {
    return "#FFFFFF"
}

proc table_background_1 {} {
    return "#CCCCCC"
}

proc table_background_2 {} {
    return "#606060"
}

proc font_face_lower_left {} {
    return "<FONT FACE=\"Helvetica, Ariel, Sans-Serif\">"
}

# determines the title gif by section

proc menu_title_gif {section} {
    switch $section {
	"almanac" {return "/graphics/academic_almanac_area.gif"}
	"library" {return "/graphics/library_area.gif"}
	"mitecs" {return "/graphics/mitecs_area.gif"}
	"cjtcs" {return "/graphics/cjtcs_area.gif"}
	"jocn" {return "/graphics/jocn_area.gif"}
	"li" {return "/graphics/li_area.gif"}
	"neco" {return "/graphics/neco_area.gif"}
	"vide" {return "/graphics/vide_area.gif"}
	"hotscience" {return "/graphics/hotscience_area.gif"}
	"jobs" {return "/graphics/jobs_area.gif"}
	"forum" {return "/graphics/forum_area.gif"}
	"member_profiles" {return "/graphics/member_profiles_area.gif"}
	"seminar_manager" {return "/graphics/seminar_manager_area.gif"}
	"your_workspace" {return "/graphics/your_workspace_area.gif"}
	"agent_glossary" {return "/graphics/agent_glossary_area.gif/"}

	"poster" { 
	    set organization [ns_queryget organization]
	    switch [string tolower $organization] {
		"cognitive neurosciences society" {return "/graphics/cns98_area.gif"}
		"cuny conference on human sentence processing" {return "/graphics/cuny98_area.gif"}
		"neural information processing systems foundation" {return "/graphics/nips10_area.gif"}
		default {return "/graphics/poster_sessions_area.gif"}
	    }
	}
	"proceeding" {
	    set organization [ns_queryget organization]
	    switch [string tolower $organization] {
		"cognitive neurosciences society" {return "/graphics/cns98_area.gif"}
		"cuny conference on human sentence processing" {return "/graphics/cuny98_area.gif"}
		"neural information processing systems foundation" {return "/graphics/nips10_area.gif"}
		default {return "/graphics/proceedings_area.gif"}
	    }
	}


	default {return "/graphics/1x1_blue.gif"}
    }
}

# determines the menu highlight by section

proc menu_highlight {section} {
    switch $section {
	"almanac" {return "library"}
	"agent_glossary" {return "library"}
	"mitecs" {return "library"}
	"poster" {return "library"}
	"proceeding" {return "library"}
	"cjtcs" {return "library"}
	"jocn" {return "library"}
	"li" {return "library"}
	"neco" {return "library"}
	"vide" {return "library"}
	default {return $section}
    }
}


# determins the menu highlight by section

proc menu_search_highlight {section} {
    switch $section {
	"almanac" {return "almanac"}
	"mitecs" {return "library"}
	"poster" {return "library"}
	"proceeding" {return "library"}
	"agent_glossary" {return "library"}
	"cjtcs" {return "library"}
	"jocn" {return "library"}
	"li" {return "library"}
	"neco" {return "library"}
	"vide" {return "library"}
	default {return $section}
    }
}

# determines the URL for the menu buttons

proc menu_url {item} {
    switch $item {
	"library" {return "/library/index.tcl"}
	"hotscience" {return "/hotscience/index.tcl"} 
	"jobs" {return "/gc/domain-top.tcl?domain=Job%20Listings"} 
	"forum" {return "/bboard/index.tcl"}
	"member_profiles" {return "/profiles/index.tcl"} 
	"seminar_manager" {return "/lecture/index.tcl"} 
	"your_workspace" {
	    set user_id [ad_get_user_id]
	    if {$user_id == 0} {
		return "/"
	    } else {
		return "/pvt/home.tcl"
	    }
	}
    } 
}

# default search order to find an uplevel link
proc up_level_search_order {} {
    return [list index.adp index.tcl index.html index.htm home.tcl ]
}

# search order as determined by the section

proc menu_section_uplevel_list {section} {
    switch [string tolower $section] {
	"agent_glossary" {return [list index.html]}
	"almanac" {
	    set url [ns_conn url]
	    if {[string match *index.tcl $url]} {
		return [list ../library/index.tcl]
	    } else {
		return [list index.tcl]
	    }
	}
	"mitecs"  {
	    return [list index.html]
	}

	"jobs"  {
	    return [list domain-top.tcl]
	} 
	"poster" {
	    set url [ns_conn url]
	    if {[string match *index.tcl $url]} {
		return [list ../library/index.tcl]
	    } else {
		return [list index.tcl]
	    }
	}
	"proceeding" {
	    set url [ns_conn url]
	    if {[string match *index.tcl $url]} {
		return [list ../library/index.tcl]
	    } else {
		return [list index.tcl]
	    }
	}
	default {return [list index.tcl]}
    }
}


proc menu_uplevel {section  {uplevel_link ""}} {
    if {$uplevel_link != ""} {
	# if there was a uplevel link requested, honor it
	return $uplevel_link
    } else {
	set urlroot [file dirname [ns_conn url]]

	if {[file tail [ns_conn url]] == [lindex [menu_section_uplevel_list $section] 0]} {
	    # if you are what is considered root for that directory, move up a directory
	    set urlroot [file dirname $urlroot]
	    set fileroot [::xo::ns::pagedir]$urlroot
	} else {

	    #check at this level in the directory
   
	    set fileroot [::xo::ns::pagedir]$urlroot
	    
	    # see if we can find any files on the list for that section
	    
	    foreach filename [menu_section_uplevel_list $section] {
		if {[file exists $fileroot/$filename]} {	
		    return "[ns_conn location]$urlroot/$filename"
		}
	    }
	}
	while {$urlroot != "" || $urlroot != "."} {
	    foreach filename [up_level_search_order] {
		if {[file exists $fileroot/$filename]} {	
		    return "[ns_conn location]$urlroot/$filename"
		}
	    }
	    if {$urlroot == "/"} {
		break
	    } else {
		# move up a directory
		set urlroot [file dirname $urlroot]
		set fileroot [::xo::ns::pagedir]$urlroot
	    }
	}
	return "none"
    }
}



# creates the generic javascript/nonjavascript
# select box for the submenu

proc menu_submenu_select_list {items urls {highlight_url "" }} {
    set return_string ""
    set counter 0

    append return_string "<form name=submenu ACTION=/redir.tcl>
<select name=\"url\" onchange=\"go_to_url(this.options\[this.selectedIndex\].value)\">"

    foreach item $items {
	set url_stub [ns_conn url]

	# if the url matches the url you would redirect to, as determined
	# either by highlight_url, or if highlight_url is not set,
	# the current url then select it
	if {$highlight_url != "" && $highlight_url == [lindex $urls $counter]} {
 	    append return_string "<OPTION VALUE=\"[lindex $urls $counter]\" selected>$item"
	} elseif {$highlight_url == "" && [string match *$url_stub* [lindex $urls $counter]]} {
	    append return_string "<OPTION VALUE=\"[lindex $urls $counter]\" selected>$item"
	} else {
	    append return_string "<OPTION VALUE=\"[lindex $urls $counter]\">$item"
	}
	incr counter
    }
    
    append return_string "</select><br>
    <noscript><input type=\"Submit\" value=\"GO\">
    </noscript>
    </form>\n"
}




# determines the subnavigation by section

proc menu_subsection {section} {
    switch $section {
	"library" {
	    set url_stub [ns_conn url]
	    if [string match "/library/index.tcl" $url_stub] {
		return "<TR><TD>[ad_promo_message "library"]</TD></TR>"
	    } else {
		return "<TR><TD>[library_submenu]</TD></TR>
<TR><TD>[ad_promo_message "library"]</TD></TR>"
	    }  
	}
	"mitecs" {

	set items [list "Subsections" "Introduction" "Author Index" "Topic Index" "AI/Computer Science" "Human Sciences" "Linguistics" "Neuroscience" "Philosophy" "Psychology"] 

	set urls  [list "/library/MITECS/index.html" "/library/MITECS/introduction_r.html" "/library/MITECS/author_index_r.html" "/library/MITECS/title_index_r.html" "/library/MITECS/aicomp_r.html" "/library/MITECS/culture_r.html" "/library/MITECS/linguistics_r.html" "/library/MITECS/neurobiol_r.html" "/library/MITECS/philosophy_r.html" "/library/MITECS/psychology_r.html"]

	return  "<TR><TD bgcolor=\"[table_background_2]\" height=24><FONT color=\"[bgcolor]\" FACE=\"Arial, Helvetica, sans-serif\" SIZE=\"4\">MITECS</FONT></TD></TR>
	      <TR><TD> [font_face_lower_left]
	      <TR><TD> [menu_submenu_select_list $items $urls]</TD></TR>
	      <TR><TD>[ad_promo_message "mitecs"]</TD></TR>"
         }

	"almanac" {return "
	      <TR><TD bgcolor=\"[table_background_2]\" height=24><FONT color=\"[bgcolor]\" FACE=\"Arial, Helvetica, sans-serif\" SIZE=\"4\">ALMANAC</FONT></TD></TR>
	       <TR><TD>[font_face_lower_left][ad_promo_message "almanac"]</TD></TR>"
	}

	"poster" {
	    set url_stub [ns_conn url]
	    if [string match "/posters/index.tcl" $url_stub] {
		return "<TR><TD bgcolor=\"[table_background_2]\" height=24><FONT color=\"[bgcolor]\" FACE=\"Arial, Helvetica, sans-serif\" SIZE=\"4\">LIBRARY</FONT></TD></TR>
<TR><TD>[library_submenu]</TD></TR>     
<TR><TD>[font_face_lower_left][ad_promo_message "library"]</TD></TR>"
            } else  {
		return "<TR><TD bgcolor=\"[table_background_2]\" height=24><FONT color=\"[bgcolor]\" FACE=\"Arial, Helvetica, sans-serif\" SIZE=\"4\">POSTER SESSIONS</FONT></TD></TR>
<TR><TD>[poster_submenu $section]</TD></TR>     
<TR><TD>[font_face_lower_left][ad_promo_message "library"]</TD></TR>"
            }
	}
	"proceeding" {
	    set url_stub [ns_conn url]
	    if [string match "/posters/index.tcl" $url_stub] {
		return "<TR><TD bgcolor=\"[table_background_2]\" height=24><FONT color=\"[bgcolor]\" FACE=\"Arial, Helvetica, sans-serif\" SIZE=\"4\">LIBRARY</FONT></TD></TR>
<TR><TD>[library_submenu]</TD></TR>     
<TR><TD>[font_face_lower_left][ad_promo_message "library"]</TD></TR>"
            } else  {
		return "<TR><TD bgcolor=\"[table_background_2]\" height=24><FONT color=\"[bgcolor]\" FACE=\"Arial, Helvetica, sans-serif\" SIZE=\"4\">PROCEEDINGS</FONT></TD></TR>
<TR><TD>[poster_submenu $section]</TD></TR>     
<TR><TD>[font_face_lower_left][ad_promo_message "library"]</TD></TR>"
            }
	}


	"hotscience" {return "	      
	      <TR><TD> [font_face_lower_left][ad_promo_message "hotscience"]</TD></TR>"
	} 
	"jobs" {return "
	      <TR><TD>[font_face_lower_left][gc_submenu "Job Listings"]<p>[ad_promo_message "jobs"]</TD></TR>"
	} 
	"forum" {return "
	      <TR><TD>[font_face_lower_left][ad_promo_message "forum"]</TD></TR>"}
	"member_profiles" {return "
	      <TR><TD>[font_face_lower_left][ad_promo_message "member_profiles"]</TD></TR>"} 
	"seminar_manager" {return "
	      <TR><TD> [font_face_lower_left][ad_promo_message "seminar_manager"]</TD></TR>"} 
	"your_workspace" {return "
	      <TR><TD>[font_face_lower_left][ad_promo_message "your_workspace"]</TD></TR>"}
	"agent_glossary" {return "
	      <TR><TD>[font_face_lower_left][library_submenu]&nbsp;</TD></TR><TR><TD>[ad_promo_message "library"]</TD></TR>"}
	"cjtcs" {return "
	      <TR><TD>[font_face_lower_left][ad_promo_message "cjtcs"]</TD></TR><TR><TD>[ad_promo_message "library"]</TD></TR>"}
	"jflp" {return "
	      <TR><TD>[font_face_lower_left][ad_promo_message "jflp"]</TD></TR><TR><TD>[ad_promo_message "library"]</TD></TR>"}
	"neco" {return "
	      <TR><TD>[font_face_lower_left][ad_promo_message "neco"]</TD></TR><TR><TD>[ad_promo_message "library"]</TD></TR>"}
	"jocn" {return "
	      <TR><TD>[font_face_lower_left][ad_promo_message "jocn"]</TD></TR><TR><TD>[ad_promo_message "library"]</TD></TR>"}
	"li" {return "
	      <TR><TD>[font_face_lower_left][ad_promo_message "li"]</TD></TR><TR><TD>[ad_promo_message "library"]</TD></TR>"}
	default {return "<TR><TD>[font_face_lower_left]&nbsp;</TD></TR>"
	}
    }
}

# determines the help link URL by section

proc ad_help_link {section} {
    switch [string tolower $section] {
	"library" {return "/bboard/q-and-a-one-category.tcl?topic=[ns_urlencode "CogNet HELP"]&category=[ns_urlencode "Library"]"}
	"cjtcs" {return "/bboard/q-and-a-one-category.tcl?topic=[ns_urlencode "CogNet HELP"]&category=[ns_urlencode "Library"]"}
	"jocn" {return "/bboard/q-and-a-one-category.tcl?topic=[ns_urlencode "CogNet HELP"]&category=[ns_urlencode "Library"]"}
	"li" {return "/bboard/q-and-a-one-category.tcl?topic=[ns_urlencode "CogNet HELP"]&category=[ns_urlencode "Library"]"}
	"neco" {return "/bboard/q-and-a-one-category.tcl?topic=[ns_urlencode "CogNet HELP"]&category=[ns_urlencode "Library"]"}
	"vide" {return "/bboard/q-and-a-one-category.tcl?topic=[ns_urlencode "CogNet HELP"]&category=[ns_urlencode "Library"]"}
	"agent_glossary" {return "/bboard/q-and-a-one-category.tcl?topic=[ns_urlencode "CogNet HELP"]&category=[ns_urlencode "Library"]"}
	"poster" {return "/bboard/q-and-a-one-category.tcl?topic=[ns_urlencode "CogNet HELP"]&category=[ns_urlencode "Library"]"}
\	"proceeding" {return "/bboard/q-and-a-one-category.tcl?topic=[ns_urlencode "CogNet HELP"]&category=[ns_urlencode "Library"]"}
	"almanac" {return "/bboard/q-and-a-one-category.tcl?topic=[ns_urlencode "CogNet HELP"]&category=[ns_urlencode "Library"]"}
	"mitecs" {return "/bboard/q-and-a-one-category.tcl?topic=[ns_urlencode "CogNet HELP"]&category=[ns_urlencode "MITECS"]"}
	"hotscience" {return "/bboard/q-and-a-one-category.tcl?topic=[ns_urlencode "CogNet HELP"]&category=[ns_urlencode "HotScience"]"}
	"jobs" {return "/bboard/q-and-a-one-category.tcl?topic=[ns_urlencode "CogNet HELP"]&category=[ns_urlencode "Jobs"]"}
	"forum" {return "/bboard/q-and-a-one-category.tcl?topic=[ns_urlencode "CogNet HELP"]&category=[ns_urlencode "The Forum"]"}
	"seminar_manager" {return "/bboard/q-and-a-one-category.tcl?topic=[ns_urlencode "CogNet HELP"]&category=[ns_urlencode "Seminar Manager"]"}
	"your_workspace" {return "/bboard/q-and-a-one-category.tcl?topic=[ns_urlencode "CogNet HELP"]&category=[ns_urlencode "Your Workspace"]"}
	"mitecs" {return "/bboard/q-and-a-one-category.tcl?topic=[ns_urlencode "CogNet HELP"]&category=[ns_urlencode "MITECS"]"}
	"bibliographies" {return "/bboard/q-and-a-one-category.tcl?topic=[ns_urlencode "CogNet HELP"]&category=[ns_urlencode "Bibliographies"]"}
	"member_profiles" {return "/bboard/q-and-a-one-category.tcl?topic=[ns_urlencode "CogNet HELP"]&category=[ns_urlencode "Member Profiles"]"}
	default {return "/bboard/q-and-a.tcl?topic=[ns_urlencode "CogNet HELP"]"}
    }
}

# this incorporates HTML designed by Ben (not adida, some other guy)

proc ad_menu_header {{section ""} {uplink ""}} {
    
    set section [string tolower $section]

    # if it is an excluded directory, just return
    set url_stub [ns_conn url]
    set full_filename "[::xo::ns::pagedir]$url_stub"
   

    foreach naked_pattern [ad_naked_html_patterns] {
	if [string match $naked_pattern $url_stub] {
	    # want the global admins with no menu, but not the domain admin
	    return ""
        }
    }

    # title is the title for the title bar
    # section is the highlight for the menu

   
    set menu_items [menu_items] 
    set java_script_p [java_script_capabilities]
    
    # Ben has a different table structure for netscape 3
    set netscape3_p [netscape3_browser]
    set return_string ""

    if { $java_script_p } {
    	append return_string " 
	<script language=\"JavaScript\">
	//<!--
	
	go = new Image();
	go.src = \"/graphics/go.gif\";
	go_h = new Image();
	go_h.src = \"/graphics/go_h.gif\";
	
	up_one_level = new Image();
	up_one_level.src = \"/graphics/36_up_one_level.gif\";
	up_one_level_h = new Image();
	up_one_level_h.src = \"/graphics/36_up_one_level_h.gif\";
	
	back_to_top = new Image();
	back_to_top.src = \"/graphics/24_back_to_top.gif\";
	back_to_top_h = new Image();
	back_to_top_h.src = \"/graphics/24_back_to_top_h.gif\";

	help = new Image();
	help.src = \"/graphics/help.gif\";
	help_h = new Image();
	help_h.src = \"/graphics/help_h.gif\";

	rules = new Image();
	rules.src = \"/graphics/rules.gif\";
	rules_h = new Image();
	rules_h.src = \"/graphics/rules_h.gif\";"
	
	foreach item $menu_items {
	    if {  $item == [menu_highlight $section] } { 
		#this means the item was selected, so there are different gifs
		append return_string "
		  $item = new Image();
		  $item.src =  \"/graphics/[set item]_a.gif\";
		  [set item]_h = new Image();
		  [set item]_h.src =  \"/graphics/[set item]_ah.gif\";"
	    } else {
		append return_string "
		$item = new Image();
		$item.src =  \"/graphics/[set item].gif\";
		[set item]_h = new Image();
		[set item]_h.src =  \"/graphics/[set item]_h.gif\";"
	    }
	    
	}
 
	# javascipt enabled
	append return_string "
	
	function hiLite(imgObjName) \{
	    document \[imgObjName\].src = eval(imgObjName + \"_h\" + \".src\")
	\}

	function unhiLite(imgObjName) \{
	    document \[imgObjName\].src = eval(imgObjName + \".src\")
	\}

	function go_to_url(url) \{
		if (url \!= \"\") \{
			self.location=url;
		\}
		return;
	\}
	// -->
	</SCRIPT>"  
    } else {
	
	append return_string "

	<script language=\"JavaScript\">
	//<!--
	
	function hiLite(imgObjName) \{
	\}
		
	function unhiLite(imgObjName) \{
	\}

	function go_to_url(url) \{
	\}
	// -->
	</SCRIPT>"
    }		

    # We divide up the screen into 4 areas top to bottom:
    #  + The top table which is the cognet logo and search stuff.
    #  + The next table down is the CogNet name and area name.
    #  + The next area is either 1 large table with 2 sub-tables, or two tables (NS 3.0).
    #      The left table is the navigation table and the right one is the content.
    #  + Finally, the bottom table holds the bottom navigation bar.
    

    append return_string "[ad_body_tag]"
   
    
    if {$netscape3_p} {
	append return_string "<IMG src=\"/graphics/top_left_brand.gif\" width=124 height=87 border=0 align=left alt=\"Cognet\"> 
<TABLE border=0 cellpadding=3 cellspacing=0>"
    }  else {
	append return_string "
<TABLE border=0 cellpadding=0 cellspacing=0 height=87 width=\"100%\" cols=100>
    <TR><TD width=124 align=center><IMG src=\"/graphics/top_left_brand.gif\" width=124 height=87 border=0 alt=\"Cognet\"></TD>
        <TD colspan=99><TABLE border=0 cellpadding=3 cellspacing=0 width=\"100%\">"
    }

    append return_string "
        <TR><TD height=16></TD></TR>
        <TR valign=bottom><TD bgcolor=\"[table_background_1]\" align=left><FONT FACE=\"Arial, Helvetica, sans-serif\" size=5>Search</FONT></TD></TR>
        <TR bgcolor=\"[table_background_1]\"><TD align=left valign=center><FORM  action=\"/search-direct.tcl\" method=GET name=SearchDirect>
                <SELECT name=section>
                     [ad_generic_optionlist [pretty_search_sections] [search_sections] [menu_search_highlight $section]]     
                </SELECT>&nbsp;&nbsp;
                <INPUT type=text value=\"\" name=query_string>&nbsp;&nbsp;"


    if {$netscape3_p} {
	append return_string "<INPUT TYPE=submit VALUE=go>&nbsp;&nbsp;
             </FORM></TD></TR>
         </TABLE>"
    } else {
	append return_string "<A href=\"JavaScript: document.SearchDirect.submit();\" onMouseOver=\"hiLite('go')\" onMouseOut=\"unhiLite('go')\" alt=\"search\"><img name=\"go\" src=\"/graphics/go.gif\" border=0 width=32 height=24 align=top alt=\"go\"></A>
	</FORM></TD></TR>
         </TABLE></TD>
   </TR>
</TABLE>"
    }

    append return_string "
<TABLE bgcolor=\"#000066\" border=0 cellpadding=0 cellspacing=0 height=36 width=\"100%\">
    <TR><TD align=left><A HREF=\"/\"><IMG src=\"/graphics/cognet.gif\" width=200 height=36 align=left border=0></A><IMG SRC=\"[menu_title_gif $section]\" ALIGN=TOP WIDTH=\"222\" HEIGHT=\"36\" BORDER=\"0\" HSPACE=\"6\" alt=\"$section\"></TD>"

    set uplevel_string  "<TD align=right><A href=\"[menu_uplevel $section $uplink]\" onMouseOver=\"hiLite(\'up_one_level\')\" onMouseOut=\"unhiLite(\'up_one_level\')\"><img name=\"up_one_level\" src=\"/graphics/36_up_one_level.gif\" border=0 width=120 height=36 \" alt=\"Up\"></A></TD></TR>"

    foreach url_pattern [ad_no_uplevel_patterns] {
	if [regexp $url_pattern $url_stub match] {
	    set uplevel_string ""
	}
    }
    
    append return_string $uplevel_string 
    append return_string "</TABLE>"

    if  {$netscape3_p} {
	append return_string "<TABLE border=0 cellpadding=0 cellspacing=0 width=200 align=left>"
    } else {
	append return_string "<TABLE border=0 cellpadding=0 cellspacing=0 width=\"100%\" cols=100>
   <TR valign=top><TD width=200 bgcolor=\"[table_background_1]\">
       <TABLE border=0 cellpadding=0 cellspacing=0 width=200>"
    }


#  Navigation Table

    foreach item $menu_items {
	if {  $item == [menu_highlight $section] } { 
	    append return_string "<TR><TD valign=bottom height=25 width=200 bgcolor=\"#FFFFFF\"><A href=\"[menu_url $item]\" onMouseOver=\"hiLite('[set item]')\" onMouseOut=\"unhiLite('[set item]')\"><img name=\"[set item]\" src=\"/graphics/[set item]_a.gif\" border=0 width=200 height=25 alt=\"$item\"></A></TD></TR>"
	} else {
	    append return_string "<TR><TD valign=bottom height=25 width=200 bgcolor=\"#FFFFFF\"><A href=\"[menu_url $item]\" onMouseOver=\"hiLite('[set item]')\" onMouseOut=\"unhiLite('[set item]')\"><img name=\"[set item]\" src=\"/graphics/[set item].gif\" border=0 width=200 height=25 alt=\"$item\"></A></TD></TR>"
	}
    }


    append return_string "
       <TR bgcolor=\"[table_background_1]\" valign=top align=left><TD width=200>
           <TABLE border=0 cellpadding=4 cellspacing=0 width=200>
    <!-- NAVIGATION BAR CONTENT GOES AFTER THIS START COMMENT USING TABLE Row and Data open and close tags -->
	        [menu_subsection $section]
                <!-- NAVIGATION BAR CONTENT GOES BEFORE THIS END COMMENT -->
           </TABLE></TD></TR>
   </TABLE>"
    
   if {$netscape3_p} {
       append return_string "<TABLE border=0 cellpadding=4 cellspacing=12>"
   } else {
       append return_string "
       </TD><TD valign=top align=left colspan=99><TABLE border=0 cellpadding=4 cellspacing=12 width=\"100%\">"
   }
   append return_string "<TR><TD>"
}

proc ad_menu_footer {{section ""}} {
   
    # if it is an excluded directory, just return
    set url_stub [ns_conn url]
    set full_filename "[::xo::ns::pagedir]$url_stub"
   
    foreach naked_pattern [ad_naked_html_patterns] {
	if [string match $naked_pattern $url_stub] {
	    return ""
	}
    }

    set netscape3_p 0
	
    if {[netscape3_browser]} {
	set netscape3_p 1
    }

    append return_string "</TD></TR></TABLE>"
    
    # close up the table
    if {$netscape3_p != 1} {
	append return_string "</TD></TR>
       </TABLE>"
    }

    # bottom bar

    append return_string "
    <TABLE border=0 cellpadding=0 cellspacing=0 height=24 width=\"100%\">
       <TR bgcolor=\"#000066\"><TD align=left valign=bottom><A href=#top onMouseOver=\"hiLite('back_to_top')\" onMouseOut=\"unhiLite('back_to_top')\"><img name=\"back_to_top\" src=\"/graphics/24_back_to_top.gif\" border=0 width=200 height=24 alt=\"top\"></A></TD>
         <TD align=right valign=bottom><A href=\"[ad_parameter GlobalURLStub "" "/global"]/rules.tcl\" onMouseOver=\"hiLite('rules')\" onMouseOut=\"unhiLite('rules')\"><img name=\"rules\" src=\"/graphics/rules.gif\" border=0 width=96 height=24 valign=bottom alt=\"rules\"></A><A href=\"[ad_help_link $section]\" onMouseOver=\"hiLite('help')\" onMouseOut=\"unhiLite('help')\"><img name=\"help\" src=\"/graphics/help.gif\" border=0 width=30 height=24 align=bottom alt=\"help\"></A></TD></TR>
    </TABLE>"
    return $return_string
}




