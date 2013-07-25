set pvt_base "https://my.phigita.net"
set pvt_home_url ${pvt_base}/
set pvt_blog ${pvt_base}/blog/
set pvt_bookmarks ${pvt_base}/linklog/
set pvt_media ${pvt_base}/media/
set logout_url "https://www.phigita.net/accounts/logout"

val -id "localtime" -cache_timeout 60 { ::util::localtime }
val -id "registered_p" { ::xo::kit::is_registered_p }
val -id "copyright_year" -cache_timeout 3600 { clock format [clock seconds] -format %Y }

val -id context_user_id { return [ad_conn ctx_uid] }
val -id context_username { return [ad_conn context_username] }

datastore \
    -id userdata \
    -singleton true \
    -select {
	screen_name
	{first_names || ' ' || last_name as full_name}
    } \
    -from_class ::CC_Users \
    -where [list "user_id=:context_user_id"]



# --------------------------------------------------------------------------------------------

css -src "/www/resources/bootstrap/css/phigita.bootstrap.css"

css {
    body {
        background: #8ab3d1 url(/graphics/theme/azure/bg-tile.gif) repeat-x;
    }
    .header-body {
	padding-left:10px;
	margin-bottom:10px;
    }
    .header {
	font-family:"Arial Unicode MS",Arial,helvetica,sans-serif;
	background: #8ab3d1;
	text-align:center;
	color: #fff;
	border-radius:6px;
	margin-top:10px;
	margin-bottom:0px;
	margin-left:0px;
	margin-right:0px;
	padding-top:20px;
	height:120px;
    }
    .header a {
	font-weight:bold;
	color:#fff;
	text-decoration:none;
    }
    .logo_and_search {
	background:#d3e0ea;
	text-align:center;
	border-radius:6px;
	margin-top:10px;
	margin-bottom:0px;
	margin-left:-10px;
	margin-right:10px;
	padding-top:20px;
	height:120px;
    }
    .livesearch {
	padding-top:40px;
    }
    #q_proxy {
        font-size: 100%;
        width: 220px;
        color: #999;
        border: 1px solid #ddd;
        border-top-color: #aaa;
        border-left-color: #aaa;
        padding: 3px 5px 3px 20px;
        background: url(/graphics/bg_magnify.png) no-repeat 4px 50% #ffffff;
    }
    .container {
	margin-top:20px;
    }
    .master-body {
	background: #fff;
    }
    .slave-body {
	padding-left:10px;
	padding-right:0px;
    }
    #sidebar {
	background: #f8f2e5;
        min-height:700px;
    }
    .sidebar-heading {
	font-weight:bold;
	color: #D75A20;
	font-size:1em;
	font-variant:small-caps;
	margin-top:20px;
    }
    .legal {
	background: #d3e0ea;
	border-radius:0.7em;
	margin:15px;
	text-align:center;
    }
    .nearby li {
	margin-top:3px;
    }

}

css {
    #search-results { position:absolute; z-index:99; width:410px; table-layout:fixed; }
    .ac_b td {color:white; }
    .ac_c {padding-left:3px;text-align:left;white-space:nowrap;width:340px;overflow:hidden;}
    .ac_d {color:green;font-size:10px;padding:0 3px;text-align:right;white-space:nowrap;width:60px;}
    .ac_m {background:white none repeat scroll 0 0;border:1px solid black;cursor:default;font-size:13px;line-height:17px;margin:0;}
    .ac_mo {background:#ffffcc;cursor:pointer;}    
}

js -deps {
    kernel/lib/base.js
    kernel/lib/event.js
    kernel/lib/DomHelper.js
    kernel/lib/dom.js
    core-platform/lib/livesearch-for-tdp.js
} -names {
    ac_a ac_b ac_c ac_d ac_mo ac_m
} -tags {
    public
}

::xo::structured_text::init_css_for_tweb

master -src "/templates/blank-master.inc" {
    script {
	nt {
	    window.onload = function() {
		livesearch_init({'applyTo': 'q_proxy', 'stub_url':"/~@{context_username}/blog/", 'livesearch_url': "/~@{context_username}/livesearch?q="});;
	    }
	}
    }


    div -class "container" {
	layout_row -class row-fluid {
	    layout_col -class span1
	    layout_col -class "span11 master-body" {
		layout_row -class row-fluid {
		    layout_col -class "span8 header-body" {
			div -class "header" {
			    tpl -with userdata {
				h3 { 
				    a -href "/~@{screen_name}/" { 
					t "@{full_name}" 
					br
					t "(~@{screen_name})"
				    } 
				}
			    }
			}
		    }
		    layout_col -class "span4" {
			div -class "logo_and_search" {
			    a -href "http://www.phigita.net/" {
				img -width 135 -height 40 -src //www.phigita.net/graphics/logo-v2.png
			    }
			    div -class "livesearch" {
				form -action "#" -id sform  -name sf -onsubmit "return false;" {
				    input \
					-type text \
					-id q_proxy \
					-name q \
					-value "" \
					-size 15 \
					-autocomplete off
				}
			    }
			}
		    }
		}
		layout_row -class "row-fluid" {
		    layout_col -class span8 {
			div -class "slave-body" {
			    slave
			}
		    }
		    layout_col -class span4 -id sidebar -style "margin-left:10px;"
		}
		layout_row -class "row-fluid" {
		    layout_col -class "span12" {
			div -class "legal" {
			    small { nt "Copyright &copy; 2000-@{copyright_year} <strong>phigita</strong>. All rights reserved." }
			    div -class "info" { 
				small {
				    small {
					t "Powered by the blood, sweat, and tears of the phigita.net community." }
				}
			    }
			}
		    }
		}
	    }
	}
    }
}
