namespace eval ::tmpl {;} 

ad_proc ::tmpl::memoize {
    {-key ""}
    {-timeout "300"}
    script
} {
    @author Neophytos Demetriou
} {

    if { $key eq {} } {
	set key [ns_sha1 $script]
    }
    #::memoize::cache flush TEMPLATE:${key}
    set result [::memoize::cache get TEMPLATE:${key}]
    set node [tmpl::div]
    if { ${result} eq {} || ${result}==0 } {
	uplevel [list $node appendFromScript $script]
        ::memoize::cache set TEMPLATE:${key} [$node asHTML] ${timeout}
    } else {
	#$node setAttribute class cache
	$node appendFromScript {
	    nt $result
	}
    }
    
}


ad_proc tabs {
    {-selectedIndex ""}
    {-selectedKey ""}
    {-tabs ""}
} {
    @author Neophytos Demetriou
} {
    ::xo::html::add_style {
	#bchead {background:#eee;border-bottom:2px solid #ccc;font-family:sans-serif;margin-bottom:1em;padding:3px;}
	#tabs {margin-top:10px;font-size:12px;}
	#tabs a {-moz-border-radius:0.7em 0.7em 0 0;-webkit-border-radius:0.7em 0.7em 0 0;border-radius:0.7em 0.7em 0 0;border-top:2px solid #ccc;border-left:2px solid #ccc;border-right:2px solid #ccc;line-height:2em;padding:3px;white-space:nowrap;}
	#tabs a {text-decoration:none;padding-bottom:0.7em;border-bottom:none;}
	#tabs a.selectedtab {font-weight:bold;background:#fff;padding-bottom:0.9em;color:#000;}
    }
    div -id bchead {
	div -id tabs {
	    set i 0
	    foreach {key taburl tabname} ${tabs} {
		if {${i} == ${selectedIndex} || ${key} eq ${selectedKey} } {
		    a -class "selectedtab" -href "${taburl}" {
			nt ${tabname}
		    }
		} else {
		    a -class fl -href ${taburl} {
			nt ${tabname}
		    }
		}
		t " "
		incr i
	    }
	}
    }
}

ad_proc navTabs {
    {-selectedIndex "0"}
    {-tabs ""}
    {-cssId ""}
    {-cssSelectedTab "selectedTab"}
    {-cssNormalTab "normalTab"}
} {
    @author Neophytos Demetriou
} {

    ul -id $cssId {
	set i 0
	foreach {taburl tabname} ${tabs} {
	    if {${taburl} eq {}} {
		if {[ad_conn user_id] == 814} {
		    li { t ${tabname} }
		}
		continue
	    }
	    li -class [concat tabIndex${i} [::util::decode ${i} ${selectedIndex} $cssSelectedTab $cssNormalTab]] -onclick "javascript:top.location.href='$taburl';" {
			t ${tabname}
	    }
	    incr i
	}
    }
}



ad_proc ::tmpl::master {
    {-title ""}
    {-context_bar ""}
    {-onload ""}
    {-withPreferencesLink "yes"}
    {-withRegistrationLink "yes"}
    {-withSearchLink "yes"}
    {-searchQuery ""}
    {-rss_feed_url ""}
    {-role ""}
    {-return_url ""}
    {-refreshInterval ""}
    {-defaultSearchAction "http://www.phigita.net/search/"}
    {-searchButtonsScript {input -class sb -type "submit" -value [mc Search "Search"]}}
    {-meta_description ""}
    {-meta_keywords ""}
    {-docStyleId "doc"}
    {-docStyleClass "z-t7"}
    {-footerScript ""}
    slave
} {

    @author Neophytos Demetriou

} {

    set user_id [ad_conn user_id]

    if {[string equal ${return_url} ""]} {
	set return_url "[ns_urlencode http://[ad_host][ns_conn url]]"
	if { ![string equal [ad_conn query] ""] } {
	    append return_url "?[ns_conn query]"
	}
    }

    global __HEAD__
    set __HEAD__ [head {

	meta -http-equiv "content-type" -content "text/html; charset=UTF-8"
	# HTML5
	# meta -charset "UTF-8"
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


	script {
	    t {
		if (window != top )
		top.location.href = window.location.href;
	    }
	}

	set comment {
	    script -src "http://www.google-analytics.com/urchin.js" -type "text/javascript"
	    script -type "text/javascript" {
		c {
		    _uacct = "UA-57821-1";
		    _udn="phigita.net"; 
		    urchinTracker();
		}
	    }
	}


	if {![string equal ${rss_feed_url} ""]} {
	    nt [subst {<link rel="alternate" type="application/rss+xml" title="RSS" href=[::util::doublequote ${rss_feed_url}]>}]
	}
	title { t "${title}" }
    }]


    # h1,h2,h3,h4,h5,h6{font-size:100%;font-weight:normal;}
    # h1,h2,h3,h4,h5,h6,dl,dt,dd,ul,ol,li {margin:0,padding:0}


    ::xo::html::add_style { 
	a {color:#0044cc;}
	body,td,font,.p,a{font-family:Verdana,"Arial Unicode MS",Arial,sans-serif;font-size:12px;margin:0;padding:0;}
	img {border:0}
	.z-bold {font-weight:bold;}
	.z-italic {font-style:italic;}
	.z-highlight {background:#dee7ec;}
	.z-align-left {display:block;margin-right:auto;}
	.z-align-right {display:block;margin-left:auto;}
	.z-align-center {display:block;margin:0pt auto;}
	.z-image-caption {font-style:italic;color:#666666;}
	#z-bar{float:left;font-weight:bold;padding-left:2px;}
	#z-top{background:#f7f7f7;height:24px;}
	#z-bh{height:0;border-top:1px solid #c9d7f1;font-size:0;position:absolute;right:0;top:24px;width:200%}
	#z-bi{background:#fff;border:1px solid;border-color:#c9d7f1 #36c #36c #a2bae7;font-size:13px;top:24px;z-index:1000;}
	#z-bar,#z-user{font-size:13px;}
	.z-b1,.z-b3{height:22px;margin-right:.73em;vertical-align:top}
	#z-bi,.z-b2{display:none;position:absolute;width:8em;text-align:left;}
	.z-b2{z-index:1001}
	#z-bar a,#z-bar a:active,#z-bar a:visited{color:#7777cc;font-weight:normal}
	#z-user a,#z-user a:active,#z-user a:visited{color:#7777cc;font-weight:normal}
	.z-b2 a,.z-b3 a{text-decoration:none}
	.z-b2 a{display:block;padding:.2em .5em;width:100%;} 
	#z-bar .z-b2 a:hover{background:#36c;color:#fff}
	#z-user .z-b2 a:hover{background:#36c;color:#fff;}
	.z-bi-selected {color:black !important;font-weight:bold !important;}
	#breadcrumbs {clear:right;}
	ul.compact {padding:0px;margin:0px;}
	ul.compact li {
	    display:inline;
	    list-style-image:none;
	    list-style-position:outside;
	    list-style-type:none;
	}
	
	.f,.fl:link,.fl:active,.fl:visited{color:#7777CC;font-family:georgia;text-decoration:none;}
	.fl:hover {text-decoration:underline;}
	.q a:visited,.q a:link,.q a:active,.q {color: blue;}
	.t a:link {color:#0000cc;}
	.t a:visited {color:#551a8b;}
	.t a:active {color:#ff0000;}
	.z-pre {font-family:"Arial Unicode MS",Arial; padding: 1em; border: 1px solid #8cacbb; color: Black; background-color: #dee7ec;}
	.z-code {
	    background-color: #feffca;
	    border:1px dashed #999;
	    color: #333;
	    font-family: "Courier New", Courier, monospace;
	    margin: 1em 0 2em;
	    padding:0.5em;
	    overflow-x: auto;
	    white-space:pre-wrap;
	    white-space: -moz-pre-wrap !important;
	    white-space: -pre-wrap;
	    white-space: -o-pre-wrap;
	    width:99%;
	    word-wrap:break-word;
	}
	h1,h2,h3,h4{font-family:"Arial Unicode MS",Arial}
	input,select,textarea {
	    font-family:"Arial Unicode MS",Arial;
	}
	#gnav {font-family: Verdana, Arial, Helvetica, sans-serif; font-size: small; margin-top:1px;margin-bottom:5px; text-decoration: none; background-color: #ffffff;margin-left:auto;margin-right:auto;}
	#footer {font: 10px verdana, sans-serif;padding: 8px;clear: both;border-top: 1px solid #8c8e8c;margin-top:8px;}
	#sea {margin-left:auto;margin-right:auto;width:640px;padding:0;}
	#sf {margin:0;padding:0;}
	.sb {font-size:14px;vertical-align:top;padding:1px;}
	#lg {font-size:10px;color: #666666;}

	#custom-doc { width:48em;*width:46.84em;min-width:624px; margin:auto; text-align:left; } 

	html{color:#000;background:#FFF;}body,div,pre,code,form,fieldset,legend,input,button,textarea,blockquote,th,td{margin:0;padding:0;}table{border-collapse:collapse;border-spacing:0;}fieldset,img{border:0;}address,caption,cite,code,dfn,em,strong,th,var,optgroup{font-style:inherit;font-weight:inherit;}del,ins{text-decoration:none;}li{list-style:none;}caption,th{text-align:left;}q:before,q:after{content:'';}abbr,acronym{border:0;font-variant:normal;}sup{vertical-align:baseline;}sub{vertical-align:baseline;}legend{color:#000;}input,button,textarea,select,optgroup,option{font-family:inherit;font-size:inherit;font-style:inherit;font-weight:inherit;}input,button,textarea,select{*font-size:100%;}body{font:13px/1.231 arial,helvetica,clean,sans-serif;*font-size:small;*font:x-small;}select,input,button,textarea,button{font:99% arial,helvetica,clean,sans-serif;}table{font-size:inherit;font:100%;}pre,code,kbd,samp,tt{font-family:monospace;*font-size:108%;line-height:100%;}body{text-align:center;}#doc,#doc2,#doc3,#doc4,.yui-t1,.yui-t2,.yui-t3,.yui-t4,.yui-t5,.yui-t6,.yui-t7{margin:auto;text-align:left;width:57.69em;*width:56.25em;}#doc2{width:73.076em;*width:71.25em;}#doc3{margin:auto 10px;width:auto;}#doc4{width:74.923em;*width:73.05em;}.yui-b{position:relative;}.yui-b{_position:static;}#yui-main .yui-b{position:static;}#yui-main,.yui-g .yui-u .yui-g{width:100%;}.yui-t1 #yui-main,.yui-t2 #yui-main,.yui-t3 #yui-main{float:right;margin-left:-25em;}.yui-t4 #yui-main,.yui-t5 #yui-main,.yui-t6 #yui-main{float:left;margin-right:-25em;}.yui-t1 .yui-b{float:left;width:12.30769em;*width:12.00em;}.yui-t1 #yui-main .yui-b{margin-left:13.30769em;*margin-left:13.05em;}.yui-t2 .yui-b{float:left;width:13.8461em;*width:13.50em;}.yui-t2 #yui-main .yui-b{margin-left:14.8461em;*margin-left:14.55em;}.yui-t3 .yui-b{float:left;width:23.0769em;*width:22.50em;}.yui-t3 #yui-main .yui-b{margin-left:24.0769em;*margin-left:23.62em;}.yui-t4 .yui-b{float:right;width:13.8456em;*width:13.50em;}.yui-t4 #yui-main .yui-b{margin-right:14.8456em;*margin-right:14.55em;}.yui-t5 .yui-b{float:right;width:18.4615em;*width:18.00em;}.yui-t5 #yui-main .yui-b{margin-right:19.4615em;*margin-right:19.125em;}.yui-t6 .yui-b{float:right;width:23.0769em;*width:22.50em;}.yui-t6 #yui-main .yui-b{margin-right:24.0769em;*margin-right:23.62em;}.yui-t7 #yui-main .yui-b{display:block;margin:0 0 1em 0;}#yui-main .yui-b{float:none;width:auto;}.yui-gb .yui-u,.yui-g .yui-gb .yui-u,.yui-gb .yui-g,.yui-gb .yui-gb,.yui-gb .yui-gc,.yui-gb .yui-gd,.yui-gb .yui-ge,.yui-gb .yui-gf,.yui-gc .yui-u,.yui-gc .yui-g,.yui-gd .yui-u{float:left;}.yui-g .yui-u,.yui-g .yui-g,.yui-g .yui-gb,.yui-g .yui-gc,.yui-g .yui-gd,.yui-g .yui-ge,.yui-g .yui-gf,.yui-gc .yui-u,.yui-gd .yui-g,.yui-g .yui-gc .yui-u,.yui-ge .yui-u,.yui-ge .yui-g,.yui-gf .yui-g,.yui-gf .yui-u{float:right;}.yui-g div.first,.yui-gb div.first,.yui-gc div.first,.yui-gd div.first,.yui-ge div.first,.yui-gf div.first,.yui-g .yui-gc div.first,.yui-g .yui-ge div.first,.yui-gc div.first div.first{float:left;}.yui-g .yui-u,.yui-g .yui-g,.yui-g .yui-gb,.yui-g .yui-gc,.yui-g .yui-gd,.yui-g .yui-ge,.yui-g .yui-gf{width:49.1%;}.yui-gb .yui-u,.yui-g .yui-gb .yui-u,.yui-gb .yui-g,.yui-gb .yui-gb,.yui-gb .yui-gc,.yui-gb .yui-gd,.yui-gb .yui-ge,.yui-gb .yui-gf,.yui-gc .yui-u,.yui-gc .yui-g,.yui-gd .yui-u{width:32%;margin-left:1.99%;}.yui-gb .yui-u{*margin-left:1.9%;*width:31.9%;}.yui-gc div.first,.yui-gd .yui-u{width:66%;}.yui-gd div.first{width:32%;}.yui-ge div.first,.yui-gf .yui-u{width:74.2%;}.yui-ge .yui-u,.yui-gf div.first{width:24%;}.yui-g .yui-gb div.first,.yui-gb div.first,.yui-gc div.first,.yui-gd div.first{margin-left:0;}.yui-g .yui-g .yui-u,.yui-gb .yui-g .yui-u,.yui-gc .yui-g .yui-u,.yui-gd .yui-g .yui-u,.yui-ge .yui-g .yui-u,.yui-gf .yui-g .yui-u{width:49%;*width:48.1%;*margin-left:0;}.yui-g .yui-g .yui-u{width:48.1%;}.yui-g .yui-gb div.first,.yui-gb .yui-gb div.first{*margin-right:0;*width:32%;_width:31.7%;}.yui-g .yui-gc div.first,.yui-gd .yui-g{width:66%;}.yui-gb .yui-g div.first{*margin-right:4%;_margin-right:1.3%;}.yui-gb .yui-gc div.first,.yui-gb .yui-gd div.first{*margin-right:0;}.yui-gb .yui-gb .yui-u,.yui-gb .yui-gc .yui-u{*margin-left:1.8%;_margin-left:4%;}.yui-g .yui-gb .yui-u{_margin-left:1.0%;}.yui-gb .yui-gd .yui-u{*width:66%;_width:61.2%;}.yui-gb .yui-gd div.first{*width:31%;_width:29.5%;}.yui-g .yui-gc .yui-u,.yui-gb .yui-gc .yui-u{width:32%;_float:right;margin-right:0;_margin-left:0;}.yui-gb .yui-gc div.first{width:66%;*float:left;*margin-left:0;}.yui-gb .yui-ge .yui-u,.yui-gb .yui-gf .yui-u{margin:0;}.yui-gb .yui-gb .yui-u{_margin-left:.7%;}.yui-gb .yui-g div.first,.yui-gb .yui-gb div.first{*margin-left:0;}.yui-gc .yui-g .yui-u,.yui-gd .yui-g .yui-u{*width:48.1%;*margin-left:0;}.yui-gb .yui-gd div.first{width:32%;}.yui-g .yui-gd div.first{_width:29.9%;}.yui-ge .yui-g{width:24%;}.yui-gf .yui-g{width:74.2%;}.yui-gb .yui-ge div.yui-u,.yui-gb .yui-gf div.yui-u{float:right;}.yui-gb .yui-ge div.first,.yui-gb .yui-gf div.first{float:left;}.yui-gb .yui-ge .yui-u,.yui-gb .yui-gf div.first{*width:24%;_width:20%;}.yui-gb .yui-ge div.first,.yui-gb .yui-gf .yui-u{*width:73.5%;_width:65.5%;}.yui-ge div.first .yui-gd .yui-u{width:65%;}.yui-ge div.first .yui-gd div.first{width:32%;}#hd:after,#bd:after,#ft:after,.yui-g:after,.yui-gb:after,.yui-gc:after,.yui-gd:after,.yui-ge:after,.yui-gf:after{content:".";display:block;height:0;clear:both;visibility:hidden;}#hd,#bd,#ft,.yui-g,.yui-gb,.yui-gc,.yui-gd,.yui-ge,.yui-gf{zoom:1;}


	.sep {margin-top:15px;}
	#q_proxy {padding:1px;font-size:16px;font-weight:bold;}
    }

    ::xo::html::iuse {z-user z-bi z-b2 z-b3}
		    body -onload "${onload}" {

				   if { [ad_conn user_id] } {
				       script {
					   c {
					       window.zbar={};(function(){;var g=window.zbar,a,f,h;function m(b,e,d){b.display=b.display=="block"?"none":"block";b.left=e+"px";b.top=d+"px"};g.tg=function(b){var e=0,d,c,i,j=0,k=window.navExtra;!f&&(f=document.getElementById("z-user"));!h&&(h=f.getElementsByTagName("span"));(b||window.event).cancelBubble=true;if(!a){a=document.createElement(Array.every||window.createPopup?"iframe":"div");a.frameBorder="0";a.id="z-bi";a.scrolling="no";a.src="#";document.body.appendChild(a);if(k)for(var n in k){var l=document.createElement("span");l.appendChild(k[n]);l.className="z-b2";f.appendChild(l)};document.onclick=g.close};for(;h[j];j++) {c=h[j];i=c.className;if(i=="z-b3"){d=c.offsetLeft;while(c=c.offsetParent)d+=c.offsetLeft;m(a.style,d,24)} else if(i=="z-b2"){m(c.style,d+1,25+e);e+=20}}a.style.height=e+"px"};g.close=function(b){a&&a.style.display=="block"&&g.tg(b)};})();
					   }
				       }
				   }
				   dom createNodeCmd elementNode nobr
				   div -id z-top {
				       div -id z-bar {
					   switch -exact -- [ad_host] {
					       www.phigita.net {
						   set selectedKey 360
					       }
					       blogs.phigita.net {
						   set selectedKey Blogs
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
					       "[mc Books "Books"]"
					       "[mc Answers "Answers"]"
					   }] title [subst {
					       Homepage
					       "[mc write_about_your_passion_or_life "Write about your passion. Or life."]"
					       "Weigh and Consider"
					       "[mc ask_a_question_get_your_answer "Ask a question. Get your answer."]"
					       "[mc monitor_syndicated_content "Monitor Greek blogs"]"
					   }] href {
					       http://www.phigita.net/
					       http://blogs.phigita.net/
					       http://books.phigita.net/
					       http://answers.phigita.net/
					   } key {
					       360
					       Blogs
					       Books
					       Answers
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
				       div -id z-bh
				       div -id z-user -style "font-size:84%;padding:0 0 4px;text-align:right;" {
					   if { [ad_conn user_id] == 0 } {
					       span -class z-b1 {
						   a -href "https://www.phigita.net/accounts/?return_url=${return_url}" {
						       t [mc Registration_Message "Sign in"]
						   }
					       }
					   } else {
					       span -class z-b3 {
						   set extra_style ""
						   if { [ad_host] eq {my.phigita.net} } {
						       set extra_style "color:red;"
						   }
						   a -href "https://my.phigita.net/" -onclick "this.blur();zbar.tg(event);return false" {
						       u { t [mc Your_Zone "Your Zone"] }
						       span  -style "font-size:11px;${extra_style}" { 
							   nt "&nbsp;&#9660;"
						       }
						   }
					       }
					       foreach label [subst {
						   "[mc Blog "Blog"]"
						   "[mc Bookmarks "Bookmarks"]"
						   "[mc Messenger "Chat-IM"]"
						   "[mc MediaBox "MediaBox"]"
						   Wiki
						   "[mc Your_Workspace "Your Workspace"]"
						   "Your Profile"
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
						   https://my.phigita.net/
						   http://www.phigita.net/~[ad_conn screen_name]/
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
						   accounts::invitation_widget
					       }
					       span -class z-b1 {
						   a -href "http://www.phigita.net/accounts/logout" {
						       t [mc Logout "Sign out"]
						   }
					       }
					   }
				       }
				   }

				   div -id sea {
				       form -id "sf" -name "sf" -action ${defaultSearchAction} -method "GET" {

					   table -id "gnav" {
					       tr {
						   td {
						       div -style "text-align:right;" {
							   a -href "http://www.phigita.net/" -title "phigita.net" {
							       img -src "[ad_conn protocol]://www.phigita.net/graphics/logo-v2.png" -width "135" -height "40" -alt "phigita.net"
							   }
						       }
						   }
						   td -style "whitespace:nowrap;" {
						       div -style "text-align:left;" {

							   if {${withPreferencesLink}} {
							       a -class "fl" -href "http://www.phigita.net/preferences/?return_url=${return_url}" {
								   t [mc Preferences "Preferences"]
							       }
							   }
							   nt " | "
							   t [ClockMgr getLocalTime -format "%A, %d %B %Y, %H:%M %Z"]
							   if {${withSearchLink}} {
							       div -style "padding:2px;" {
								   input -name "q" -value ${searchQuery} -size "35" -autocomplete "off" -id q_proxy
								   eval $searchButtonsScript
							       }
							   }
						       }
						   }
					       }
					       if { [::xo::kit::is_registered_p] } {

						   ::xo::html::add_script3 -key XO.SUGGEST -deps {
						       kernel/lib/base.js
						       kernel/lib/event.js
						       kernel/lib/DomHelper.js
						       kernel/lib/SearchBox.js
						   } -names {
						       q_proxy suggest_results selected has_results
						   }

						   tr {
						       td
						       td {

							   ::xo::html::add_style {
							       #suggest_results {position:absolute; z-index:99;background:#fcfcfc;border:1px solid #000;margin:0;padding:2px 5px;width:350px;}
							       #suggest_results div {text-align:left;}
							       .selected {background:#6E95C2;color:white;cursor:default;}
							       .has_results {background:#dde5F5;}
							       .suggest-title {overflow:hidden;height:1.4em;font-size:1.2em;color:#000;margin-top:5px;}
							       .suggest-url {overflow:hidden;height:1.2em;font-size:1em;color:#04c;}
							       div.selected .suggest-title {color:#fff;}
							       div.selected .suggest-url {color:#fff;}
							   }
							   ::xo::html::iuse {selected has_results suggest-title suggest-url}
							   
							   div -id suggest_results

							   script -type text/javascript {
							       t "SearchBox.init({applyTo:'q_proxy',displayTo:'suggest_results'});"
							   }

						       }
						   }
					       }
					   }
				       }
				   }
				   div -id "$docStyleId" -class "$docStyleClass" {
				       if { $context_bar ne {} } {
					   nt $context_bar
				       }
				       uplevel ${slave}
				       if { $footerScript ne {} } {
					   div -id "ft" {
					       eval $footerScript
					   }
				       }
				   }
				   br
				   div -id footer {
				       div -id lg {
					   nt "Copyright &copy; 2000-[clock format [clock seconds] -format %Y] <b>phigita</b>. All rights reserved."
					   br
					   span -style "color:#666;" {
					       t "[mc Powered_By "Powered by the blood, sweat, and tears of the phigita.net community."]"
					   }
				       }
				   }

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


}


proc ::tmpl::navigation_bar {navigation_bar} {

    font -face "Arial" -size "-1" -color "#666666" {
	t {<trn key="You_Are_Here">You Are Here</trn>: }
    }
    nt ${navigation_bar}

}


proc ::tmpl::browsing_history {user_id} {

    table -border "0" -width "100%" -cellpadding "1" -cellspacing "0" -bgcolor "#999999" {
	tr {
	    td -width "100%" {
		table -width "100%" -border "0" -cellpadding "4" -cellspacing "0" -bgcolor "#999999" {
		    tr {
			td -bgcolor "#ffffee" -valign "top" -width "100%" {
			    b {
				t "Your Recent History"
			    }
			    br

			    a -href "learn-more" {
				t "Learn More"
			    }

			    br

			    table -width "100%" -border "0" -cellspacing "5" -cellpadding "5" -bgcolor "#ffffee" {
				tr {
				    td -width "33%" -valign "top" {
					b {
					    t "Recently Viewed Products"
					}

					table -border "0" {
					    tr -valign  "top" {
						td -width "24" {
						    img -src "http://g-images.amazon.com/images/G/01/icons/icon-books.gif" -width "22" -height "22" -align "absmiddle" -hspace "2" -vspace "2" -border "0" -alt "Icon"
						}

						td {
						    a -href "/exec/obidos/tg/detail/-/0451524934/ref=pd_rhf_p_1/104-2409444-5351140?v=glance&s=books" {
							i { t "1984" }
						    }
						    t " by George Orwell, Erich Fromm (Afterword)"
						}
					    }

					    tr -valign  "top" {
						td -width "24" {
						    img -src "http://g-images.amazon.com/images/G/01/icons/icon-books.gif" -width "22" -height "22" -align "absmiddle" -hspace "2" -vspace "2" -border "0" -alt "Icon"
						}

						td {
						    a -href "/exec/obidos/tg/detail/-/0451524934/ref=pd_rhf_p_1/104-2409444-5351140?v=glance&s=books" {
							i { t "Narcissus and Goldmund" }
						    }
							t " by Hermann Hesse, Ursule Molinaro (Translator)"
						}
					    }

					    tr -valign  "top" {
						td -width "24" {
						    img -src "http://g-images.amazon.com/images/G/01/icons/icon-books.gif" -width "22" -height "22" -align "absmiddle" -hspace "2" -vspace "2" -border "0" -alt "Icon"
						}

						td {
						    a -href "/exec/obidos/tg/detail/-/0451524934/ref=pd_rhf_p_1/104-2409444-5351140?v=glance&s=books" {
							i { t "The Glass Bead Game" }
						    }
						    t " by Hermann Hesse, et al"
						}
					    }
					}
				    }


				    td -width "33%" -valign "top" {

					b {
					    t "Recent Searches"
					}

					table -border "0" {
					    tr -valign "top" {
						td -align "center" -width "24" {
						    img -src "http://g-images.amazon.com/images/G/01/icons/icon-books.gif" -width "22" -height "22" -align "absmiddle" -hspace "2" -vspace "2" -border "0" -alt "Icon" 
						}

						td {

						    t "In books:" 
						    a -href "/exec/obidos/search-handle-url/index%3Dbooks%26field-keywords%3Dgreenspun/ref%3Dpd%5Frhf%5Fs%5F1/104-2409444-5351140" {
							t "greenspun"
						    }
						}
					    }
					}
				    }
				}
			    }
			}
		    }
		}
	    }
	}
    }
}


namespace eval portlet {;}

proc portlet::g11n {} {

    global i18n_msgs
    if { ![info exists i18n_msgs] } {
	return
    }


    
    a -href "http://www.phigita.net/admin/g11n/translator-mode-toggle" {
	t "Toggle translator mode to off"
    }

    p

    foreach msgdef ${i18n_msgs} {
	    
	lassign ${msgdef} action locale url key

	ul {
	    li {
		t "${action}"
		a -href ${url} {
		    t "${key}"
		}
	    }
	}
	
    }
}


proc ::tmpl::action_bar {actionCatalog} {

    table -bgcolor "#666666" -cellpadding "1" -cellspacing "0" -border "0" -width "100%" {
        tr {
	    td { 
		table -bgcolor "#eeeeee" -cellpadding "2" -cellspacing "0" -border "0" -width "100%" {
		    tr {
			td -bgcolor "#eeeeee" {
			    t -disableOutputEscaping "&nbsp;"
			    font -face "Arial" -size "-1" {

				set count 0
				foreach action [lrange ${actionCatalog} 0 end-1] {

				    if { ${count} > 0 } {t " - "}

				    lassign ${action} url key msg
				    a -href ${url} {
					b { t [mc ${key} ${msg}] }
				    }
				    incr count
				}
			    }
			}
			td -align "right" {
			    font -face "Arial" -size "-1" {
				
				set action [lindex ${actionCatalog} end]
				lassign ${action} url key msg
				
				a -href ${url} {
				    b { t [mc ${key} ${msg}] }
				}
			    }
			}
		    }
		}
	    }
	}
    }
}

proc ::tmpl::Vertical_Action_Bar {actionCatalog} {

    table -bgcolor "#eeeeee" -cellpadding "2" -cellspacing "0" -border "0" -width "100%" {
	foreach action ${actionCatalog} {

	    tr {
		td -bgcolor "#eeeeee" -align right {
		    t -disableOutputEscaping "&nbsp;"
		    font -face "Arial" -size "-1" {
			
			lassign ${action} url key msg
			a -href ${url} {
			    b { t [mc ${key} ${msg}] }
			}
		    }
		    t -disableOutputEscaping "&nbsp;"
		}
	    }
	}
    }
}

# tmpl::tree revfolders onenodeeval

ad_proc ::tmpl::tree {
    {-ds ""}
    {-startnode ""} 
    {-tsp ""}
} {

    if {![Object isobject ${startnode}]} {
	set startnode [Object new -volatile -set id "." -set parent_id "" -set level 0 -array set auxdots [list]]
    }

    set folders [list]

    set previous_obj ${startnode}

    foreach f ${ds} {

	foreach i [${previous_obj} array names auxdots] {
	    if {${i} < [${f} set level]} {
		${f} set auxdots(${i}) 1
	    }
	}
	${f} set auxdots([${f} set level]) 1

	set folders [concat ${f} ${folders}]
	set previous_obj ${f}
    }


    set previous_obj ${startnode}
    foreach f ${folders} {
	for {set i 1} {${i} < [${previous_obj} set level]} {incr i} {
	    if {[${previous_obj} exists auxdots(${i})]} {
		img -src /graphics/misc/dots -width 18 -height 19
	    } else {
		img -src /graphics/cleardot.gif -width 18 -height 19
	    }
	}
	if {[${previous_obj} set level] != 0} {
	    if {[${f} exists auxdots([${previous_obj} set level])]} {
		img -src /graphics/misc/dots_nt -width 18 -height 19
	    } else {
		img -src /graphics/misc/dots_nl -width 18 -height 19
	    }
	}
	uplevel [format ${tsp} ${previous_obj}]
	br
	set previous_obj ${f}
    }
    for {set i 1} {${i} < [${previous_obj} set level]} {incr i} {
	if {[${previous_obj} exists auxdots(${i})]} {
	    img -src /graphics/misc/dots -width 18 -height 19
	} else {
	    img -src /graphics/cleardot.gif -width 18 -height 19
	}
    }
    img -src /graphics/misc/dots_nl -width 18 -height 19
    uplevel [format ${tsp} ${previous_obj}]
}




ad_proc ::tmpl::month_calendar {
    {-date ""}
    {-tsp ""}
} {
    @author Neophytos Demetriou
} {
    # Write out the header and the days of the week

    table -cellpadding 2 -cellspacing 3 {
	tr {
	    td -colspan 7 -align center {
		font -size "+1" {
		    b {
			t [lc_time_fmt ${date} "%B %Y"] 
		    }
		}
	    }
	}
	tr {
	    foreach abday [nsv_get locale [ad_conn locale],abday] {
		td {
		    font -color "green" {
			div -style "font-size:small; font-variant:small-caps" {
			    t ${abday}
			}
		    }
		}
	    }
	}

###################
	set today_date [dt_sysdate]
	dt_get_info ${date}

	set day_of_week 1
	set julian_date $first_julian_date
	set day_number $first_day

	set today_ansi_list [dt_ansi_to_list $today_date]
	set today_julian_date [dt_ansi_to_julian [lindex $today_ansi_list 0] [lindex $today_ansi_list 1] [lindex $today_ansi_list 2]]

	while {1} {

	    if {$julian_date < $first_julian_date_of_month} {
		set before_month_p 1
		set after_month_p  0
	    } elseif {$julian_date > $last_julian_date_in_month} {
		set before_month_p 0
		set after_month_p  1
	    } else {
		set before_month_p 0
		set after_month_p  0
	    }

	    if {$julian_date == $first_julian_date_of_month} {
		set day_number 1
	    } elseif {$julian_date > $last_julian_date} {
		break
	    } elseif {$julian_date == [expr $last_julian_date_in_month+1]} {
		set day_number 1
	    }

	    if { $day_of_week == 1} {
		t -disableOutputEscaping "<tr>"
	    }

	    set skip_day 0

	    if {$before_month_p || $after_month_p} {
		td -valign "top" {
		    #{uplevel [format ${tsp} ${day_number}]}
		    t " "
		}
		
	    } else {

		td -valign "top" {
		    uplevel [format ${tsp} ${day_number} ${julian_date} ${today_julian_date}]
		}
	    }


	    incr day_of_week
	    incr julian_date
	    incr day_number

	    if { $day_of_week > 7 } {
		set day_of_week 1
		t -disableOutputEscaping "</tr>"
	    }
	}



    }

}



#####################



#####################






ad_proc ::tmpl::month_calendar2 {
    {-year ""}
    {-month ""}
    {-day ""}
    {-tsp ""}
} {
    @author Neophytos Demetriou
} {
    # Write out the header and the days of the week

    set date $year-$month-$day
    center {
	table -cellpadding 0 -cellspacing 1 -style "font-size: small;" {
	    tr {
		td -colspan 7 -align center -style "font-size: 12px; line-height: 16px; font-weight: normal; color: \#000000;" {
		    t [lindex [lc_get mon] [expr ${month}-1]] 
		    t " "
		    t ${year}
		}
	    }
	    tr {
		foreach abday [lc_get abday] {
		    td {
			font -color "green" {
			    div -style "font-size:x-small; font-variant:small-caps" {
				t ${abday}
			    }
			}
		    }
		}
	    }

	    ###################
	    set today_date [dt_sysdate]
	    dt_get_info ${year}-${month}-01

	    set day_of_week 1
	    set julian_date $first_julian_date
	    set day_number $first_day

	    set today_ansi_list [dt_ansi_to_list $today_date]
	    set today_julian_date [dt_ansi_to_julian [lindex $today_ansi_list 0] [lindex $today_ansi_list 1] [lindex $today_ansi_list 2]]

	    while {1} {

		if {$julian_date < $first_julian_date_of_month} {
		    set before_month_p 1
		    set after_month_p  0
		} elseif {$julian_date > $last_julian_date_in_month} {
		    set before_month_p 0
		    set after_month_p  1
		} else {
		    set before_month_p 0
		    set after_month_p  0
		}

		if {$julian_date == $first_julian_date_of_month} {
		    set day_number 1
		} elseif {$julian_date > $last_julian_date} {
		    break
		} elseif {$julian_date == [expr $last_julian_date_in_month+1]} {
		    set day_number 1
		}

		if { $day_of_week == 1} {
		    t -disableOutputEscaping "<tr>"
		}

		set skip_day 0

		if {$before_month_p || $after_month_p} {
		    td -valign "top" {
			#{ uplevel [format ${tsp} ${day_number}]}
			
		    }
		    
		} else {

		    td -valign "middle" -style "font-size:x-small" {
			uplevel [format ${tsp} ${day_number} ${julian_date} ${today_julian_date}]
		    }
		}


		incr day_of_week
		incr julian_date
		incr day_number

		if { $day_of_week > 7 } {
		    set day_of_week 1
		    t -disableOutputEscaping "</tr>"
		}
	    }


	}
    }
}



ad_proc ::tmpl::simple {
    {-title ""}
    {-onload ""}
    slave
} {
    @author Neophytos Demetriou
} {

    global __HEAD__
    set __HEAD__ [head {

	meta -http-equiv "content-type" -content "text/html; charset=UTF-8"

	title { t ${title} }
    }]

    ::xo::html::add_style { 
	.f,.fl:link,.fl:active,.fl:visited{color:#7777CC}	
	.t a:link {color:#0000cc;}
	.t a:visited {color:#551a8b;}
	.t a:active {color:#ff0000;}
	body,td,font,.p,a{font-family:"Arial Unicode MS",Arial,helvetica,sans-serif;}
	.q a:visited,.q a:link,.q a:active,.q {color: blue;}
	code {font-size: 120%; color: Black; background-color: #dee7ec;}
	pre {display: block; padding: 8px 8px .75em 8px;}
	.z-pre {font-family:"Arial Unicode MS",Arial; padding: 1em; border: 1px solid #8cacbb; color: Black; background-color: #dee7ec;}
	.z-code {
	    background-color: #feffca;
	    border:1px dashed #999;
	    color: #333;
	    font-family: "Courier New", Courier, monospace;
	    margin: 1em 0 2em;
	    padding:0.5em;
	    overflow-x: auto;
	    white-space:pre-wrap;
	    white-space: -moz-pre-wrap !important;
	    white-space: -pre-wrap;
	    white-space: -o-pre-wrap;
	    width:99%;
	    word-wrap:break-word;
	}
	h1,h2,h3,h4{font-family:"Arial Unicode MS",Arial}
	input {font-family:"Arial Unicode MS",Arial;}
	body {background:#fff;color:#000;margin:5 0 0 15;}
	#logo {float:left;padding-right:5px;background:#ffc;}
	#legal {font-size:10px;color:#666;text-align:center;}
	#title {font-weight:bold;background:#666; padding:5px;color:#fff;font-family: Arial, sans-serif;}
    }

    
	#-bgcolor "#ffffff" 
	#-text "#000000" 
	#-link "#0000cc" 
	#-vlink "#551a8b" 
        #-alink "#ff0000" 
	#-leftmargin "15" 
	#-topmargin "5" 
	#-marginwidth "15" 
	#-marginheight "5"

    set bodyEl [::tmpl::body]
    if { $onload ne {} } {
	$bodyEl setAttribute onload ${onload}
    }
    $bodyEl appendFromScript {

	div -id header {
	    div -id logo {
		a -href "http://www.phigita.net/" -title "phigita.net! Homepage" {
		    img -src "/graphics/logo-v2.png" -width "135" -height "40" -border "0" -alt "phigita homepage"
		}
	    }
	    div -id title {
		nt "&nbsp;${title}"
	    }
	}
	p
	uplevel ${slave}
	p

	br
	div -id legal {
	    nt "Copyright &copy; 2000-[clock format [clock seconds] -format %Y] phigita.net. All Rights Reserved."
	}
	p
	if { [lang::util::translator_mode_p] } {
	    portlet::g11n
	}

    }


}

ad_proc ::tmpl::blank {
    {-title ""}
    {-onload ""}
    slave
} {
    @author Neophytos Demetriou
} {

    global __HEAD__
    set __HEAD__ [head {
	meta -http-equiv "content-type" -content "text/html; charset=UTF-8"
	title { t "phigita.net! ${title}" }
    }]
  

    body \
	-bgcolor "#ffffff" \
	-text "#000000" \
	-link "#0000cc" \
	-vlink "#551a8b" \
        -alink "#ff0000" \
	-leftmargin "15" \
	-topmargin "5" \
	-marginwidth "15" \
	-marginheight "5" \
	-onload ${onload} {

	    uplevel ${slave}

	    if { [lang::util::translator_mode_p] } {
		portlet::g11n
	    }

	}
    
}






ad_proc ::tmpl::UserSharedMaster {
    {-title ""}
    {-context_bar ""}
    {-onload ""}
    {-withPreferencesLink "yes"}
    {-withRegistrationLink "yes"}
    {-withSearchLink "yes"}
    {-searchQuery ""}
    {-rss_feed_url ""}
    {-role ""}
    {-return_url ""}
    {-defaultSearchAction "http://www.phigita.net/search/"}
    {-searchButtonsScript {input -type "submit" -value [mc Search "Search"]}}
    {slave ""}
} {

    @author Neophytos Demetriou

} {

    set user_id [ad_conn user_id]
    set ctx_uid [ad_conn ctx_uid]
    if { $ctx_uid > 0 } {
	#set userdata [db::Set new \
	#		  -from "users u inner join persons p on (u.user_id=p.person_id)" \
	#		  -where "user_id=[ns_dbquotevalue $ctx_uid]"]
	#${userdata} load
	#set u [${userdata} head]
	set u [::xo::kit::get_user $ctx_uid]

    } else {
	rp_returnnotfound
	return
    }

    if {[string equal ${return_url} ""]} {
	set return_url "[ns_urlencode [ns_conn url]]"
	if { ![string equal [ad_conn query] ""] } {
	    append return_url "?[ns_conn query]"
	}
    }

    global __HEAD__
    set __HEAD__ [head {

	script {
	    t {
		if (window != top )
		top.location.href = window.location.href;
	    }
	}

	meta -http-equiv "content-type" -content "text/html; charset=UTF-8"
	#meta -name "ROBOTS" -content "NOARCHIVE"

	if {![string equal ${rss_feed_url} ""]} {
	    nt [subst {<link rel="alternate" type="application/rss+xml" title="RSS" href=[::util::doublequote ${rss_feed_url}]>}]
	}
 	#link -href "/resources/theme/azure.css" -media "all" -rel "Stylesheet" -type "text/css"
	#::xo::html::add_style_file /resources/theme/azureTEST.css
	::xo::html::include_style /resources/theme/azure.css
	
	title { t "${title}" }
    }]

    ::xo::html::add_style { 
	body {margin:0;padding:0;}
	img {border:0;}
	.z-bold {font-weight:bold;}
	.z-italic {font-style:italic;}
	.z-highlight {background:#dee7ec;}
	.z-align-left {display:block;margin-right:auto;}
	.z-align-right {display:block;margin-left:auto;}
	.z-align-center {display:block;margin:0pt auto;}
	.z-image-caption {font-style:italic;color:#666666;}

	.f,.fl:link,.fl:active,.fl:visited{color:#7777CC}	
	.t a:link {color:#0000cc;}
	.t a:visited {color:#551a8b;}
	.t a:active {color:#ff0000;}

	body,td,font,.p,a{font-family:"Arial Unicode MS",Arial,helvetica,sans-serif;}
	.q a:visited,.q a:link,.q a:active,.q {color: blue;}
	.z-pre {font-family:"Arial Unicode MS",Arial; padding: 1em; border: 1px solid #8cacbb; color: Black; background-color: #dee7ec;}
	.z-code {
	    background-color: #feffca;
	    border:1px dashed #999;
	    color: #333;
	    font-family: "Courier New", Courier, monospace;
	    margin: 1em 0 2em;
	    padding:0.5em;
	    overflow-x: auto;
	    white-space:pre-wrap;
	    white-space: -moz-pre-wrap !important;
	    white-space: -pre-wrap;
	    white-space: -o-pre-wrap;
	    width:99%;
	    word-wrap:break-word;
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
	#gnav {font-family: Verdana, Arial, Helvetica, sans-serif; font-size: small; color: #d5d5d5; padding-left: 1em; padding-right: 1em; margin-bottom:5px; text-decoration: none; border-bottom: 1px solid #8c8e8c; background-color: #ffffff;}
	#lg {color: #666666;}
	#footer {clear:both;}
	h2.post_title a {color:#00325B;text-decoration:none;}
	h2.post_title a:hover {color:#00325B;text-decoration:underline;}
	.post_content p {background-color: #FFFFFF;color: #333333;font-size: 16px;line-height: 24px;margin-bottom: 1em;}
	.post span.typo_date {color: #808080;font-size: 10px;}
    }
    

		 
    set bodyEl [::tmpl::body]
    if { $onload ne {} } {
	$bodyEl setAttribute onload ${onload}
    }
    $bodyEl appendFromScript {

	br
	div -id "container" -class "clearfix" {
	    #t -disableOutputEscaping $context_bar
	    div -id header {
		div -id logo {
		    h1 -id "sitename" { 
			a -href "/~[$u set screen_name]/" { 
			    t "[$u set first_names] [$u set last_name]" 
			    br
			    br
			    t "(~[$u set screen_name])"
			}
		    }
		}
	    }

	    div -id search {
		div -style "position:relative; top:10px;text-align:center;" {
			a -href "/" -title "phigita.net" -style "border:0;" {
			    img -src "/graphics/logo-v2.png" -width "135" -height "40" -alt "phigita homepage"
			}
		    }
		form -action "#" -id sform  -name sf -onsubmit "return false;" {
		    input -type text -id q_proxy -name q -value "" -size 15 -autocomplete off
		}	
		#a -href "#" -title "Close search results" -id "search-close" -onclick "closeSearch();return false;" -style "display:none;" {
		#t "Close search results"
		#}
		div -id "search-results"
	    }

	    if { ${slave} ne {} } {
		set domNodeId [uplevel ${slave}]
	    } else {
		set domNodeId [div]
	    }

	    ::xo::html::add_style {
		.ac {background:white;}
		.ac_b td {color:white; }
		.ac_c {overflow:hidden;padding-left:3px;text-align:left;white-space:nowrap; }
		.ac_d {color:green;font-size:10px;overflow:hidden;padding:0 3px;text-align:right;white-space:nowrap;}
		.ac_m {background:white none repeat scroll 0 0;border:1px solid black;cursor:default;font-size:13px;line-height:17px;margin:0;position:absolute;z-index:99;}
		.ac_mo {background:#ffffcc;cursor:pointer;}
	    }


	    set stub_url [::util::jsquotevalue /~[$u set screen_name]/blog/]
	    set livesearch_url [::util::jsquotevalue /~[$u set screen_name]/livesearch?q=]
	    
	    ::xo::html::iuse {ac_a ac_b ac_c ac_d ac_mo ac_m}
	    ::xo::html::add_script3 -key TMPL.SHARED.LIVESEARCH -deps {
		kernel/lib/base.js
		kernel/lib/event.js
		kernel/lib/DomHelper.js
		core-platform/lib/livesearch.js
	    } -names {
		q_proxy livesearch-results ac_a ac_b ac_c ac_d ac_mo ac_m
	    }

	    script -type text/javascript {
		t "livesearch_init({applyTo: 'q_proxy', stub_url:${stub_url}, livesearch_url: ${livesearch_url}});"
	    }


	    div -id footer {
		div -id legal {
		    nt "Copyright &copy; 2000-[clock format [clock seconds] -format %Y] <b>phigita</b>. All rights reserved."
		    div -style "color:#666;font-size:10px;" {
			t "[mc Powered_By "Powered by the blood, sweat, and tears of the phigita.net community."]"
		    }
		}
	    }
	}
    }

    return $domNodeId
}
