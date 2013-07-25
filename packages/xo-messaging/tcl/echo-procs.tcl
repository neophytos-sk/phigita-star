namespace eval ::util {;}

proc ::util::mask_phone {msisdn} {
    return [concat [string range $msisdn 0 end-6]***[string range $msisdn end-2 end]]
}



package require crc16

namespace eval ::echo {;}

if { [::xo::kit::performance_mode_p] } {
    proc ::echo::message_post_url {} { return "http://echo.phigita.net/message-post" }
} else {
    proc ::echo::message_post_url {} { return "http://localhost:8090/echo/message-post" }
}

proc ::echo::css_init {} {

    ::xo::html::cssList {echo_comment_box echo_parent_id}

    # render_message_list
    ::xo::html::cssList {echo_comment echo_comment_text}

    # render_message
    ::xo::html::cssList {msg msg_body user permalink} 
    ::xo::html::cssList {fl xs actions}
}

proc ::echo::css_default_style {} {
    ::xo::ns::once /global/templates/includelet_default_style.tcl

    ::xo::html::add_style {
	.user { }
	.permalink {font-size:9px;font-style:italic;color:#888;}
	a.permalink {text-decoration:none;}
	a.permalink:hover {text-decoration:underline;}
	.msg {margin-top:2px;padding:5px;}
	#charcount {font-family:georgia;font-size:medium;font-weight:bold;margin-right:5px;}
	.ch-cnt-neg {color:#800;}
	.ch-cnt-pos {color:#666;}
	.xs {font-size:10px;}
	.ue {font-size:10px;}
	a.ue {text-decoration:none;}
	a.ue:hover {text-decoration:underline;}
	.echo_comment {margin:5px 2px 2px 20px;padding:0px 5px 0px 5px;border-left:1px dashed #77c;}
	.echo_ft {font-size:8px;color:#888;font-style:italic;}
	.echo_ft a {color:#888;font-size:10px;text-decoration:none;}
	.echo_ft a:hover {text-decoration:underline;}
    }
}

proc ::echo::render_comment_box {{is_permalink_p "0"}} {
    if { ![::xo::kit::is_registered_p] } {
	return
    }

    ::xo::html::add_style {
	#echo_comment_box {margin:15px 20px 5px 20px;padding-left:5px;padding-right:5px;border-left:1px dashed #77c;}
    }

    if { $is_permalink_p } {
	set display block
    } else {
	set display none
    }

    ## COMMENT FORM
    ## set action_comment_add "http://localhost:8090/echo/comment-add"
    set action_comment_add "http://echo.phigita.net/comment-add"
    div -id echo_comment_box -style "display:${display};" {
	form -action ${action_comment_add} -method "post" {
	    input -id echo_parent_id -type "hidden" -name parent_id -value ""
	    textarea -id echo_comment_text -name content -rows "2" -wrap soft  -style "width:95%;line-height:1.15em;overflow:hidden;font-size:1.15em;border:1px solid #aaa;"
	    div {
		button -type submit -style "font-size:10px;" { t "Add Comment" }
		nt "&nbsp;"
		a -class "fl xs" -href "#" -title "Hide" -onclick "return echo.hide('echo_comment_box');" { 
		    t "\[x\]"
		}
	    }
	}
    }
}

proc ::echo::render_message_list {echo_msgs userArrVar} {

    upvar $userArrVar userArr

    foreach m [$echo_msgs set result] {
	::echo::render_message $m $userArr([$m set creation_user])
    }
    ::echo::render_comment_box ;# does check if user is_registered_p
}

proc ::echo::render_message {m u {show_user_p "true"} {is_permalink_p "0"}} {

    $u instvar screen_name first_names last_name

    set base ""
    if { [ad_host] ne {www.phigita.net} } {
	set base "http://www.phigita.net"
    }
    if { $m eq {} || $u eq {} } {
	error "no echo message object provided"
    }

    set rangeEnd 1024
    if { [$m set device] eq {web} } {
	set rangeEnd 250
    }
    set node [div -class "msg"]
    $node appendFromScript {
	div -class "msg_body" {
	    nt [::xo::structured_text::minitext_to_html [string range [$m set content] 0 $rangeEnd]]
	}
	if { [$m set attachment] ne {} } {
	    div -class "msg_attachments" {
		foreach object_id [$m set attachment] {

		    set image_url [::xo::media::preview_image_url \
				       -user_id [$m set creation_user] \
				       -object_id $object_id -size 120]

		    set token "my_secret_token" ;# TODO
		    set viewer_url "${base}/~${screen_name}/media/view?id=${object_id}&token=$token"
		    div -class "msg_attachment" -style "float:left;" {
			a -href ${viewer_url} -target _blank {
			    img -src $image_url -style "width:75px;"
			}
		    }
		}
	    }
	    br -clear both
	}
	if { ${show_user_p} } {
	    span -class user { 
		t "-- "
		a -href "${base}/~${screen_name}/" -title "${first_names} ${last_name}" { nt ${screen_name} }
	    }
	}
	a -class permalink -href "${base}/~${screen_name}/echo/[$m set id]" {
	    t "[::util::age_pretty -timestamp_ansi [$m set creation_date] -sysdate_ansi [clock_to_ansi [clock seconds]]]"
	    t " via [$m set device]"
	}
	if { [::util::boolean [$m set public_p]] } {
	    t " "
	    span -class "xs" -style "color:#600;" { nt "#public" }
	    t " "
	}
	if { [::xo::kit::is_registered_p] } {
	    span -class actions {
		nt " &#183; "
		a -class "fl xs" -href "#" -onclick "return echo.cbox([$m set id])" {
		    t "comment"
		}
		if { [$m set creation_user] eq [ad_conn user_id] } {
		    nt " &#183; "
		    a -class "fl xs" -href "http://echo.phigita.net/message-remove?id=[$m set id]&return_url=[util_current_location]" -onclick "return confirm('Sure you want to delete this update? There is NO undo!');" {
			t "remove"
		    }
		}
	    }
	}
	if { !$is_permalink_p } {
	    if { [$m set cnt_comment] } {
		::echo::render_message_comment [$m set last_comment] $m $u
	    }
	}
	span -id cbox_[$m set id]
	::xo::html::iexclude "cbox_[$m set id]"
    }
    return $node
}

proc ::echo::render_message_comment {commentDict m u {is_permalink_p "0"}} {
    $u instvar screen_name

    set base ""
    if { [ad_host] ne {www.phigita.net} } {
	set base "http://www.phigita.net"
    }
    div -class echo_comment {
	if { !$is_permalink_p } {
	    span -class "echo_ft" {
		a -href "${base}/~${screen_name}/echo/[$m set id]" {
		    t "[$m set cnt_comment] [ad_decode [${m} set cnt_comment] 1 comment comments]"
		}
		if { [$m set cnt_comment] == 1 } {
		    t " by "
		} else {
		    t ", last by "
		}
		set comment_screen_name [dict get $commentDict screen_name]
		span -class user {
		    a -href "${base}/~${comment_screen_name}/" { t $comment_screen_name }
		    t ": "
		}
	    }
	}
	div -class "comment_content" {
	    nt [::xo::structured_text::minitext_to_html [dict get $commentDict content]]
	    #::util::minitext_to_html
	}
	if { $is_permalink_p } {
	    span -class "echo_ft" {
		t " -- "
		set comment_screen_name [dict get $commentDict screen_name]
		span -class user {
		    a -href "${base}/~${comment_screen_name}/" { t $comment_screen_name }
		    nt " &nbsp; "
		}
		t "[::util::age_pretty -timestamp_ansi [dict get $commentDict creation_date] -sysdate_ansi [clock_to_ansi [clock seconds]]]"
	    }
	}
    }
}


proc ::echo::js_code {} {
    if { ![::xo::kit::is_registered_p] } {
	return
    }

    ::xo::html::add_script3 -key XO.ECHO -deps {
	kernel/lib/base.js
	kernel/lib/event.js
	kernel/lib/dom.js
	kernel/lib/DomHelper.js
	xo-messaging/lib/echo.js
    } -names_map "E_CSS" -names {
	charcount echo_attach_frm attachment_1 echo_file echo_file_0
	update_btn ch-cnt-neg ch-cnt-pos echo_comment_box echo_comment_text
	echo_parent_id
    }

}











proc ::echo::getDeviceToken {user_id device_guid} {
    set base10 [::crc::crc16 -seed [clock milliseconds] ${user_id}-${device_guid}]
    return [::util::decimal_to_base_n $base10 8 "a d g j m p t w"]
}

# css class ue stands for user echo
# It is needed to add (not parsed as html by tdom):
#    ::xo::html::iuse ue
#
proc ::echo::textToHtml {text {base ""}} {
    if { [ad_host] ne {www.phigita.net} } {
	set base http://www.phigita.net
    }
    set text [::util::quotehtml $text]
    regsub -nocase -all {(^|[^a-zA-Z0-9]+)(http://[^\(\)"<>\s]+[^\(\)\"<>\s\.,\*\':;?])} $text "\\1<a class=\"ni\" href=\"\\2\">\\2</a>" text
    regsub -nocase -all {(^|[^a-zA-Z0-9]+)@([a-zA-Z0-9]+)} $text "\\1<a class=\"ue\" href=\"${base}/~\\2/echo/\">@\\2</a>" text
    return $text
}
