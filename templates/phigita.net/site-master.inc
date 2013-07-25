set pvt_base "https://my.phigita.net"
set pvt_home_url ${pvt_base}/
set pvt_blog ${pvt_base}/blog/
set pvt_bookmarks ${pvt_base}/linklog/
set pvt_media ${pvt_base}/media/
set logout_url "https://www.phigita.net/accounts/logout"

val -id "localtime" -cache_timeout 60 { ::util::localtime }
val -id "registered_p" { ::xo::kit::is_registered_p }
val -id "copyright_year" -cache_timeout 3600 { clock format [clock seconds] -format %Y }

css -src "/www/resources/bootstrap/css/phigita.bootstrap.css"

::xo::structured_text::init_css_for_tweb

css {
    #search-form { margin-bottom:20px;}
    #search-form form {margin:0;}
    #footer {text-align:center;}
    #footer .info {color: #666;}
}

master -src "/templates/blank-master.inc" {

    div -class "container" {
	layout_row {
	    layout_col -class "span2" {
	    }
	    layout_col -class "span2" {
		a -href "http://www.phigita.net/" {
		    img -width 135 -height 40 -src //www.phigita.net/graphics/logo-v2.png
		}
	    }
	    layout_col -class "span7" {
		small {
		    tpl -if "@{registered_p}" {
			a -href ${pvt_home_url} { t "Your Workspace" }
			t " - "
			a -href ${logout_url} { t "Sign out" }
		    }
		    tpl -if "not @{registered_p}" {
			a -href "https://www.phigita.net/accounts/" { t "Sign in" }
		    }
		    t " | "
		    t @{localtime} 
		}
		div -id "search-form"
	    }
	}
	slave
	i -class "clearfix"
	hr
	div -id "footer" {
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
