ad_page_contract {
    Displays last 100 requests in the system

    @author Gustaf Neumann 

    @cvs-id $id
} -query {
    {orderby:optional "time,desc"}
} -properties {
    title:onevalue
    context:onevalue
}

set title "Last 100 Requests"
set context [list "Last 100 Requests"]
set stat [list]
foreach {key value} [throttle last100] {lappend stat $value}

Class CustomField -volatile \
    -instproc render-data {row} {
      html::div -style {
	border: 1px solid #a1a5a9; padding: 0px 5px 0px 5px; background: #e2e2e2} {
	  html::t  [$row set [my name]] 
	}
    }

TableWidget t1 -volatile \
    -columns {
      Field time       -label "Time" -orderby time -mixin ::template::CustomField
      AnchorField user -label "Userid" -orderby user
      Field ms         -label "Ms" -orderby ms
      Field url        -label "URL" -orderby url
    }

foreach {att order} [split $orderby ,] break
t1 orderby -order [expr {$order eq "asc" ? "increasing" : "decreasing"}] $att

foreach l $stat {
  foreach {timestamp c url ms requestor} $l break
  if {[string first . $requestor] > 0} {
    set user_string $requestor
  } else {
    acs_user::get -user_id $requestor -array user
    set user_string "$user(first_names) $user(last_name)"
  }
  t1 add -time [clock format $timestamp -format "%H:%M:%S"] \
      -user $user_string \
      -user.href [export_vars -base last-requests {{request_key $requestor}}] \
      -ms $ms \
      -url $url
}



Object instproc asHTML {{-master defaultMaster} -page:switch} {
  require_html_procs
  dom createDocument html doc
  set root [$doc documentElement]
  if {!$page} {
    $root appendFromScript {my render}
    return [[$root childNode] asHTML]
  } else {
    set slave [$master decorate $root]
    $slave appendFromScript {my render}
    ns_return 200 text/html [$root asHTML]
  }
}

Object ::pageMaster -proc decorate {node} {
  $node appendFromScript {
    html::head {
      html::title {html::t "XOTcl Request Monitor"}
      html::link -rel stylesheet -type text/css -media all -href \
	  /resources/acs-developer-support/acs-developer-support.css 
      html::link -rel stylesheet -type text/css -media all -href \
	  /resources/acs-templating/lists.css
      html::link -rel stylesheet -type text/css -media all -href \
	  /resources/acs-templating/forms.css
      html::link -rel stylesheet -type text/css -media all -href \
	  /resources/acs-subsite/default-master.css
      html::link -rel stylesheet -type text/css -media all -href \
	  /resources/dotlrn/dotlrn-toolbar.css
      html::script -type "text/javascript" -src "/resources/acs-subsite/core.js" \
	  -language "javascript" {}
      html::link -rel "shortcut icon" \
	  -href "/resources/theme-selva/Selva/default/images/myicon.ico"
      html::link -rel "stylesheet" -type "text/css" \
	  -href "/resources/theme-selva/Selva/default/Selva.css" -media "all"
    }
    html::body {
      html::div -id wrapper {
	html::div -id header {
	  html::img -src /resources/theme-selva/Selva/images/dotLRN-logo.gif \
	      -alt Logo
	}
	html::br
	html::div -id site-header {
	  html::div -id breadcrumbs {
	    html::div -id context-bar {
	      html::a -href / {html::t "Main Site"}
	      html::t -disableOutputEscaping "&#187;\n"
	      html::a -href "/request-monitor" {html::t "XOTcl Request Monitor"}
	      html::t -disableOutputEscaping "&#187;\n"
	      html::t [my set context]
	      html::div -style "clear:both;"
	    }
	    html::div -id status {
	      html::div -class "action-list users-online" {
		html::a -href "/shared/whos-online" {
		  html::t "1 member online"
		} 
		html::t "|"
		html::a -href "/register/logout" \
		    -title "Von yourdomain Network abmelden" {
		      html::t Abmelden
		    }
	      }
	      html::div -class "user-greeting" {
		html::t "Willkommen, Gustaf Neumann!  |"
	      }
	    }
	  }
	} ;# end of site header
	html::div -id "youarehere" {
	  html::t [my set title]
	}
	html::br
	html::div -id "portal-navigation" {
	  html::ul {
	    html::li {html::a -href "/dotlrn/" {html::t "My Space"}}
	    html::li {html::a -href "/theme-selva/courses" {html::t "Courses"}}
	    html::li {html::a -href "/theme-selva/communities" {html::t "Communities"}}
	    html::li {html::a -href "/pvt/home" {html::t "Einstellungen"}}
	    html::li {html::a -href "/dotlrn/control-panel" {html::t "Tools"}}
	  }
	}

	html::div -id "portal-subnavigation" {
	  html::div -id "portal-subnavigation-links" {
	    html::ul {
	      html::li {
		html::a -href "/dotlrn/?page_num=0" {html::t "Eigene Startseite"}
	      }
	      html::li {
		html::a -href "/dotlrn/?page_num=1" {html::t "Eigener Kalender"}
	      }
	      html::li {
		html::a -href "/dotlrn/?page_num=2" {html::t "Eigene Dateien"}
	      }
	    }
	  }
	}

	html::div -id "portal" {
	  set slave [tmpl::div]
	}
      }
    }
    html::t "hello footer"
  }
  return $slave
}
pageMaster set title $title
pageMaster set context [lindex $context 0]

ns_log notice "render time [time {t1 asHTML -page -master ::pageMaster}]"