namespace eval ::xo {;}
namespace eval ::xo::ui {;}

Class ::xo::ui::DefaultMaster


::xo::ui::Class ::xo::ui::PHIGITA_DEFAULT_MASTER -parameter {
    {title ""}
}

###::xo::ui::DefaultMaster instmixin {}
::xo::ui::DefaultMaster instmixin ::xo::ui::PHIGITA_DEFAULT_MASTER
;#-guard {[string match *.phigita.net [ad_host]] && ![string match /~* [ns_conn url]] }

::xo::ui::PHIGITA_DEFAULT_MASTER instproc render {visitor} {
    $visitor ensureNodeCmd elementNode script div meta title style ul li nobr span a u table tr td img br form input center tt b p

    ###ns_log notice "[self class] host=[ad_host] url=[ns_conn url]"

    my instvar title
    set context_bar ""
    set onload ""
    set withPreferencesLink "yes"
    set withRegistrationLink "yes"
    set withSearchLink "yes"
    set searchQuery ""
    set rss_feed_url ""
    set role ""
    set return_url ""
    set refreshInterval ""
    set defaultSearchAction "http://www.phigita.net/search/"
    set searchButtonsScript {input -class sb -type "submit" -value [mc Search "Search"]}
    set meta_description ""
    set meta_keywords ""
    set docStyleId "doc"
    set docStyleClass "z-t7"
    set footerScript ""



    set user_id [ad_conn user_id]

    if {[string equal ${return_url} ""]} {
	set return_url "[ns_urlencode http://[ad_host][ns_conn url]]"
	if { ![string equal [ad_conn query] ""] } {
	    append return_url "?[ns_conn query]"
	}
    }

    [$visitor head] appendFromScript {
	meta -http-equiv "CONTENT-TYPE" -content "text/html; charset=UTF-8"
	title { t $title }
    }
    $visitor inlineJavascript {
	if (window != top ) top.location.href = window.location.href;
    }


    if { [ad_conn user_id] } {
	$visitor inlineJavascript {
	    window.zbar={};(function(){;var g=window.zbar,a,f,h;function m(b,e,d){b.display=b.display=="block"?"none":"block";b.left=e+"px";b.top=d+"px"};g.tg=function(b){var e=0,d,c,i,j=0,k=window.navExtra;!f&&(f=document.getElementById("z-user"));!h&&(h=f.getElementsByTagName("span"));(b||window.event).cancelBubble=true;if(!a){a=document.createElement(Array.every||window.createPopup?"iframe":"div");a.frameBorder="0";a.id="z-bi";a.scrolling="no";a.src="#";document.body.appendChild(a);if(k)for(var n in k){var l=document.createElement("span");l.appendChild(k[n]);l.className="z-b2";f.appendChild(l)};document.onclick=g.close};for(;h[j];j++) {c=h[j];i=c.className;if(i=="z-b3"){d=c.offsetLeft;while(c=c.offsetParent)d+=c.offsetLeft;m(a.style,d,24)} else if(i=="z-b2"){m(c.style,d+1,25+e);e+=20}}a.style.height=e+"px"};g.close=function(b){a&&a.style.display=="block"&&g.tg(b)};})();
	}
    }


    $visitor inlineStyle {
	.z-align-left {display:block;margin-right:auto;}
	.z-align-right {display:block;margin-left:auto;}
	.z-align-center {display:block;margin-left:auto;margin-right:auto;}
	.z-image-caption {font-style:italic;color:#666666;}
	#z-bar{float:left;font-weight:bold;padding-left:2px;}
	#z-top{background:#f7f7f7;height:24px;}
	#z-bh{height:0;border-top:1px solid #c9d7f1;font-size:0;position:absolute;right:0;top:24px;width:200%}
	#z-bi{background:#fff;border:1px solid;border-color:#c9d7f1 #36c #36c #a2bae7;font-size:13px;top:24px;z-index:1000;}
	#z-bar,#z-user{font-size:13px;}
	@media all{.z-b1,.z-b3{height:22px;margin-right:.73em;vertical-align:top}}
	#z-bi,.z-b2{display:none;position:absolute;width:8em;text-align:left;}
	.z-b2{z-index:1001}
	#z-bar a,#z-bar a:active,#z-bar a:visited{color:#7777cc;font-weight:normal}
	#z-user a,#z-user a:active,#z-user a:visited{color:#7777cc;font-weight:normal}
	.z-b2 a,.z-b3 a{text-decoration:none}
	.z-b2 a{display:block;padding:.2em .5em;width:100%;} 
	#z-bar .z-b2 a:hover{background:#36c;color:#fff}
	#z-user .z-b2 a:hover{background:#36c;color:#fff;}
	.z-bi-selected {color:black !important;font-weight:bold !important;}
	    #gnav {font-family: Verdana, Arial, Helvetica, sans-serif; font-size: small; color: #d5d5d5; margin-top:1px;margin-bottom:5px; text-decoration: none; background-color: #ffffff;margin-left:auto;margin-right:auto;}
	#footer {font: 10px verdana, sans-serif;padding: 8px;clear: both;border-top: 1px solid #8c8e8c;margin-top:8px;}
        #sea {margin-left:auto;margin-right:auto;width:640px;padding:0;}
	    #sf {margin:0;padding:0;}
	.sb {font-size:14px;vertical-align:top;padding:1px;}
	#lg {font-size: 10px;color: #666666;}
	.f,.fl:link,.fl:active,.fl:visited{color:#7777CC;font-family:georgia;}
    }

    [$visitor content] appendFromScript {
	div -id z-top {
	    div -id z-bar {
		nobr {
		    switch -exact -- [ad_host] {
			www.phigita.net {
			    set selectedKey 360
			}
			blogs.phigita.net {
			    set selectedKey Blogs
			}
			buzz.phigita.net {
			    if { [string match {/video/*} [ns_conn url]] } {
				set selectedKey Video
			    } else {
				set selectedKey Buzz
			    }
			}
			books.phigita.net {
			    set selectedKey Books
			}
			answers.phigita.net {
			    set selectedKey Answers
			}
			agenda.phigita.net {
			    set selectedKey Agenda
			}
			my.phigita.net {
			    switch -glob -- [ns_conn url] {
				{/blog/*} {
				    set selectedKey "Blog"
				}
				{/linklog/*} {
				    set selectedKey "Bookmarks"
				}
				{/media/*} {
				    set selectedKey "MediaBox"
				}
				{/im/*} {
				    set selectedKey "Messenger"
				}
				{/wiki/*} {
				    set selectedKey "Wiki"
				}
				default {
				    set selectedKey "Workspace"
				}
			    }
			}
			default {
			    set selectedKey ""
			}
		    }
		    foreach label [subst {
			"360&#176;"
			"[mc Blogs "Blogs"]"
			"[mc Video "Video"]"
			"[mc Books "Books"]"
			"[mc Answers "Answers"]"
			Buzz
			"[mc Agenda "Agenda"]"
		    }] title [subst {
			Homepage
			"[mc write_about_your_passion_or_life "Write about your passion. Or life."]"
			Video
			"[mc Book_Search "Book Search"]"
			"[mc ask_a_question_get_your_answer "Ask a question. Get your answer."]"
			"[mc monitor_syndicated_content "Monitor Greek blogs"]"
			"[mc discover_events_in_your_area "Discover events in your area."]"
		    }] href {
			http://www.phigita.net/
			http://blogs.phigita.net/
			http://buzz.phigita.net/video/
			http://books.phigita.net/
			http://answers.phigita.net/
			http://buzz.phigita.net/
			http://agenda.phigita.net/
		    } key {
			360
			Blogs
			Video
			Books
			Answers
			Buzz
			Agenda
		    } {
			span -class z-b1 {
			    if { $key eq $selectedKey } {
				b { t -disableOutputEscaping $label }
			    } else {
				a -class "fl" -href ${href} -title $title {
				    t -disableOutputEscaping $label
				}
			    }
			}
		    }
		}
	    }

	    div -id z-bh
	    div -align right -id z-user -style "font-size:84%;padding:0 0 4px" -width 100% {
		nobr {
		    if { [ad_conn user_id] == 0 } {
			span -class z-b1 {
			    a -href "http://www.phigita.net/accounts/?return_url=${return_url}" {
				t [mc Registration_Message "Login"]
			    }
			}
		    } else {
			span -class z-b3 {
			    set extra_style ""
			    if { [ad_host] eq {my.phigita.net} } {
				set extra_style "color:red;"
			    }
			    a -href "http://my.phigita.net/" -onclick "this.blur();zbar.tg(event);return false" {
				u { t [mc Your_Zone "Your Zone"] }
				span  -style "font-size:11px;${extra_style}" { 
				    t -disableOutputEscaping "&nbsp;&#9660;"
				}
			    }
			}
			foreach label [subst {
			    "[mc Blog "Blog"]"
			    "[mc Bookmarks "Bookmarks"]"
			    "[mc Messenger "Chat-IM"]"
			    "[mc MediaBox "MediaBox"]"
			    Wiki
			    "[mc Your_Workspace "Your_Workspace"]"
			    "[mc Your_Profile "Your_Profile"]"
			}] title [subst {
			    "[mc write_about_your_passion_or_life "Write about your passion. Or life."]"
			    "Organize your bookmarks."
			    "Chat with friends on the Web."
			    "Organize your files."
			    "Create a knowledge Web."
			    "Your Workspace"
			    "Your Profile"
			}] href [subst {
			    http://my.phigita.net/blog/
			    http://my.phigita.net/linklog/
			    http://my.phigita.net/im/
			    http://my.phigita.net/media/
			    http://my.phigita.net/wiki/
			    http://my.phigita.net/
			    http://www.phigita.net/~[ad_conn screen_name]
			}] key {
			    Blog
			    Bookmarks
			    Messenger
			    MediaBox
			    Wiki
			    Workspace
			    Profile
			} {
			    span -class z-b2 {
				set className ""
				if { $key eq $selectedKey } {
				    set className z-bi-selected
				}
				a -class $className -href ${href} -title $title {
				    t -disableOutputEscaping $label
				}
			    }
			}
			span -class z-b1 {
			    require_html_procs
			    accounts::invitation_widget
			}
			span -class z-b1 {
			    a -href "http://www.phigita.net/accounts/logout" {
				t [mc Logout "Logout"]
			    }
			}
		    }
		}
	    }
	}

	div -id sea {
	    form -id "sf" -name "sf" -action ${defaultSearchAction} -method "GET" {

		table -id "gnav" {
		    tr {
			td -align right {
			    a -href "http://www.phigita.net/" -title "phigita.net! Homepage" {
				img -src "[ad_conn protocol]://www.phigita.net/graphics/logo-v2.png" -width "135" -height "40" -border "0" -alt "phigita.net! Homepage"
			    }
			}
			td -nowrap "" {
			    div {

				if {${withPreferencesLink}} {
				    a -class "fl" -href "http://www.phigita.net/preferences/?return_url=${return_url}" {
					t [mc Preferences "Preferences"]
				    }
				    t -disableOutputEscaping "&nbsp;|&nbsp;"
				    t [ClockMgr getLocalTime -format "%A, %d %B %Y, %H:%M %Z"]
				}
				if {${withSearchLink}} {
				    div -style "padding:2px;" {
					input -style "padding:1px;font-size:16px;font-weight:bold;" -type "text" -name "q" -value ${searchQuery} -size "35" -maxlength "2048"
					eval $searchButtonsScript
				    }
				}
			    }
			}
		    }
		    
		}
	    }
	}

	div -id "$docStyleId" -class "$docStyleClass" {
	    if { $context_bar ne {} } {
		t -disableOutputEscaping $context_bar
	    }
	    set innerNode [div]
	    if { $footerScript ne {} } {
		div -id "ft" {
		    ###eval $footerScript
		}
	    }
	}
	br -clear both
	div -id footer {
	    div -id lg {
		t -disableOutputEscaping "Copyright &copy; 2000-[clock format [clock seconds] -format %Y] <b>phigita</b>. All rights reserved."
		br
		div {
		    span -style "color:#d5d5d5;" {
			t "[mc Powered_By "Powered by the blood, sweat, and tears of the phigita.net community."]"
		    }
		}
	    }
	}
    }


    return $innerNode

    #########

    [$visitor head] appendFromScript {


	if { $meta_description ne {} } {
	    meta -name "description" -content $meta_description
	}
	if { $meta_keywords ne {} } {
	    meta -name "keywords" -content $meta_keywords
	}

	if { $refreshInterval ne {} } {
	    meta -http-equiv "refresh" -content "$refreshInterval"
	}

	#meta -name "ROBOTS" -content "NOARCHIVE"


	if {![string equal ${rss_feed_url} ""]} {
	    t -disableOutputEscaping [subst {<link rel="alternate" type="application/rss+xml" title="RSS" href=[::util::doublequote ${rss_feed_url}]>}]
	}
	title { t "${title}" }
	
	::xo::html::add_style { 
	    .bold {font-weight:bold;}
	    .italic {font-style:italic;}
	    .highlight {background:#dee7ec;}



	    #breadcrumbs {
	    clear:right;
	    }
	ul.compact {padding:0px;margin:0px;}
	    ul.compact li {
		display:inline;
		list-style-image:none;
		list-style-position:outside;
		list-style-type:none;
	    }

		.f,.fl:link,.fl:active,.fl:visited{color:#7777CC;font-family:georgia;}	
		    body,td,font,.p,a{font-family:Verdana,"Arial Unicode MS",Arial,helvetica,sans-serif;font-size:12px;}
		.q a:visited,.q a:link,.q a:active,.q {color: blue;}
		.t a:link {color:#0000cc;}
		.t a:visited {color:#551a8b;}
		.t a:active {color:#ff0000;}
		    code {font-size: 120%; color: Black; background-color: #dee7ec;white-space:pre; }
		    pre {
			font-family:"Arial Unicode MS",Arial;
			padding: 1em;
			border: 1px solid #8cacbb;
			color: black;
			background-color: #dee7ec;
			white-space:normal;
		    }

		    .pre {font-family:"Arial Unicode MS",Arial; padding: 1em; border: 1px solid #8cacbb; color: Black; background-color: #dee7ec;}
		    .code {
			background-color: #e0e0e0;
			color: #802020;
			font-weight: bold;
			font-family: monospace;
			font-size: 1.25em;
			white-space:pre;
			overflow: auto;
		    }
		h1,h2,h3,h4{font-family:"Arial Unicode MS",Arial}
	        input,select,textarea {
			font-family:"Arial Unicode MS",Arial;
		}
		.o {
			font-family: verdana, sans-serif;
			font-size: 10px;
			font-weight:bold;
			text-decoration:none;
			color: white;
			background-color: #F60;
			border:1px solid;
			border-color: #FC9 #630 #330 #F96;
			padding:0px 3px 0px 3px;
			margin:0px;
		    }
			#gnav {font-family: Verdana, Arial, Helvetica, sans-serif; font-size: small; color: #d5d5d5; padding-left: 1em; padding-right: 1em; margin-top:5px;margin-bottom:5px; text-decoration: none; background-color: #ffffff;}
			#footer {
			font: 10px verdana, sans-serif;
			padding: 8px;
			clear: both;
			border-top: 1px solid #8c8e8c;
			margin-top:8px;
		    }

			#sea {margin-left:auto;margin-right:auto;width:640px;padding-top:10px;padding-bottom:5px;}
			.sb {font-size:14px;vertical-align:top;padding:1px;}
			#lg {font-size: 10px;color: #666666;}



		    }
		}
		    
		    
		    switch -- $role {
			pvt {
			    set role_bordercolor "\#ff2040"
			    set role_bgcolor "\#ffc0d0"
			}
			default {
			    set role_bordercolor "\#ffffff"
			    set role_bgcolor "\#ffffff"
			}
		    }

[$visitor body] setAttribute bgcolor "#ffffff"
[$visitor body] setAttribute text "#000000"
[$visitor body] setAttribute topmargin "0"
[$visitor body] setAttribute leftmargin "0"
[$visitor body] setAttribute rightmargin "0"
[$visitor body] setAttribute marginheight "0"
[$visitor body] setAttribute onload "${onload}"

[$visitor body] appendFromScript {
	    p
	    set comment {

		t "About Us"; t " | "

		t "Site Map";  t " | "

		t "Contact Us"; t " | "

		t [mc Terms_of_Use "Terms of Use"];  t " | "

		t [mc Privacy "Privacy"];  t " | "

		t [mc Made_in_Cyprus "Made in Cyprus"]
	    }
	    p

	    if { [lang::util::translator_mode_p] } {
		portlet::g11n
	    }

	}

return $innerNode

}
