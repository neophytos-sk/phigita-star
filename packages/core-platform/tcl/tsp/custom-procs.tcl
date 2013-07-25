namespace eval www.phigita.net {;}
namespace eval www.phigita.net::template {;}
namespace eval layout {;}

ad_proc layout::master {
    {-varname ""}
    {-context ""}
    {-title ""}
    {-onload {javascript:document.forms['sf'].elements['q'].focus()}}
    {-javascript ""}
} {


    if { ![string equal ${varname} ""] } { upvar ${varname} elementId }

    set . [${context} ownerDocument]

    bebop::HTML-Page ${context} leafage

    $leafage(head) appendFromScript { 
	title { t "phigita.net! ${title}" }
	if { ${javascript} != "" } {
	    script -language "javascript" { c ${javascript} }
	}
    }

    bebop::Simple-TMB-Layout $leafage(body) leafage

    set elementId $leafage(middle)

    set table0 [${.} createElement TABLE]
    $leafage(top) appendChild ${table0}
    bebop::MxN-Table ${table0} leafage 1x2
    $leafage(body) setAttribute bgcolor "ffffff" text "000000" leftmargin "15" topmargin "5" marginwidth "15" marginheight "5" onLoad ${onload}

    $leafage(head) appendFromScript {
	style { c {
body,td,font,.p,a{font-family:arial,sans-serif}
a,a:link{text-decoration:underline;color:#00c}
a:visited{color:#551a8b}
a:active,.fl a:active{color:#000}
.d,.d a:visited,.d a:link, .d
a:active{font-weight:bold;color:#000;text-decoration:none}
.f,.fl:link,.fl a:link{color:#666}
.g,.g a:visited,.g a:link,.g a:active{color:#000}
.h{color:#a03}
.l{line-height:9pt}
.k,.k a:visited,.k a:link, .k a:hover,.k a:active{font-weight:bold;color:#000;text-decoration:underline}
.p,.p:link,.p a:link{color:#008000}
.x a:visited,.x a:link,.x a:active,.x {text-decoration:none;color:#000}
.q a:visited,.q a:link,.q a:active,.q {text-decoration:none;color:#00c}
.w a:link,.w a:visited,.w {color:#009;text-decoration:none}
.w a:active,.w a:hover{color:#009;text-decoration:underline}
.y{font-weight:bold}
.z {visibility:hidden}
}}}

$leafage(${table0}-1-1) appendFromScript { 
    t -disableOutputEscaping "&nbsp;&nbsp;&nbsp;"
    a -href / { img -src /graphics/logo -width 173 -height 35 -border 0 }
 }

$leafage(${table0}-1-2) setAttribute nowrap ""

$leafage(${table0}-1-2) appendFromScript {
    table -border 0 -cellspacing 0 -cellpadding 0 -valign bottom {
	tr -border 0 {
	    td -width 7 { t -disableOutputEscaping "&nbsp;" }
	    td -align center {
		font -size -1 {
		    a -href /preferences/ {
			t "Preferences"
		    }
		    
		    
		    if { [ad_conn user_id] == 0 } {
			t -disableOutputEscaping "&nbsp;-&nbsp;" 
			a -href /register/ { 
			    b { t "Please login or register" }
			}
			t " "
			t "\["
			a -href /register/explain-why { t "why?" }
			t "\]"
		    } else {
			t -disableOutputEscaping "&nbsp;-&nbsp;" 
			a -href "/my/" {
			    font -size -1 {
				t "Your Account"
			    }
			}
			t -disableOutputEscaping "&nbsp;-&nbsp;"
			a -href "/register/logout" { t "Logout" }
		    }
		}
		td -width 7 { t -disableOutputEscaping "&nbsp;" }
	    }
	}
    }
}

$leafage(middle) appendFromScript { font -size -3 { br } }

bebop::Search-Form $leafage(${table0}-1-2) leafage sf

#set context_bar [ad_context_bar]
#$leafage(top) appendFromScript {
#    hr -size 1 -noshade ""
#    t -disableOutputEscaping ${context_bar}
#}
$leafage(bottom) appendFromScript {
    hr -size 1 -noshade ""
    a -href "mailto:k2pts@cytanet.com.cy" {t "k2pts@cytanet.com.cy"}
}
}
