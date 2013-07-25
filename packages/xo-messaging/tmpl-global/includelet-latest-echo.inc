#::xo::kit::pretend_user 814
#::xo::kit::reload packages/xo-messaging/tcl/echo-procs.tcl

val -id registered_p { ::xo::kit::is_registered_p }
val -id where_clause { ::util::decode @{registered_p} 0 [list "public_p"] "true"}
val -id num_of_echo_posts { return 3 }
val -id current_location { util_current_location }
val -id user_id { ad_conn user_id }

datastore \
    -id echo_msgs \
    -cache "echo.top_messages-@{registered_p}" \
    -select {*} \
    -from_class [::db::Inner_Join new \
		     -lhs [::db::Set new \
			       -alias m \
			       -type ::echo::Message \
			       -order "creation_date desc" \
			       -where @{where_clause} \
			       -limit @{num_of_echo_posts}] \
		     -rhs [::db::Set new \
			       -select {
				   user_id
				   screen_name
				   first_names
				   last_name
			       } \
			       -type CC_Users \
			       -alias cc] \
		     -join_condition {cc.user_id=m.creation_user}] \
    -where @{where_clause} \
    -order "creation_date desc" \
    -limit @{num_of_echo_posts} \
    -extend {
	set content [::xo::structured_text::minitext_to_html $content]
	set creation_date [::util::age_pretty \
			       -timestamp_ansi $creation_date \
			       -sysdate_ansi [clock_to_ansi [clock seconds]]]

	set last_comment__content ""
	set last_comment__screen_name ""
	if { $last_comment ne {} } {
	    array set last_comment_arr $last_comment
	    set last_comment__content [::xo::structured_text::minitext_to_html \
					   $last_comment_arr(content)]
	    set last_comment__screen_name $last_comment_arr(screen_name)
	}
    }

css { 
    .special_tag {color: #600;}
    #echo-header {color: #660;}
    #echo_file_0 {margin-top:5px;}
    #echo_file_0 a {color: #666; }
    .echo-message {margin: 0 0 7px;padding: 0 0 0 5px;font-size:small;background:#eee;}
    .echo-message small {
	display: block;
	line-height: 20px;
	color: #999999;
    }
    .echo-message small:before {
	content: '-- ';
    }
    .echo-message small a { color: #666; }
    .echo-comment {margin: 0 0 10px 20px;padding: 0 0 0 10px;border-left: 1px dashed #aaa;}
    .echo-comment a { color: #666; }
    .echo_action {
	width:40px;
    }
    #charcount {display:inline-block;}
    .ch-cnt-neg {color:red;}

}

js -deps {
    kernel/lib/base.js
    kernel/lib/event.js
    kernel/lib/dom.js
    kernel/lib/DomHelper.js
    xo-messaging/lib/echo2.js
} -names {
    ch-cnt-neg ch-cnt-pos
}

p

div {

    dataview {
	tpl -if "not @{val.registered_p}" {
	    div  -style "background:#efefd7;padding:2px 5px;" {
		b { t "echo" }
		t " "
		sup {
		    t " update your friends on the go."
		}
	    }
	}
    }

    dataview {
	div {
	    tpl -if "@{val.registered_p}" {

		div  -style "background:#efefd7;padding:2px 5px;" {

		    ### start of echo form
		    form \
			-class "form-inline" \
			-name "echo_frm" \
			-action [::echo::message_post_url] \
			-method "post" -style "margin:0;" {
			    div -style "float:right;" {
				span -id charcount { t "0" }
				t " "
				label -for public_p { 
				    input -type checkbox -name public_p -value t -id public_p
				    t " public"
				}
				t " "
				button -id update_btn -type "button" -class "btn btn-mini" -type submit -disabled "" { t "update" }
			    }

			    div -id "echo-header" { 
				b { t "echo" }
				t " "
				sup { t "update your friends on the go" }
			    }
			    
			    div -id echo_text {
				input -type hidden -name return_url -value "@{val.current_location}"
				::xo::html::iuse content
				textarea \
				    -id content \
				    -name content \
				    -rows 2 \
				    -wrap soft \
				    -style "width:97%;line-height:1.15em;overflow:hidden;font-size:1.15em;border:1px solid #aaa;"
			    }
			    if {0} {
				div -id echo_file_0 -style "display:block;" {
				    img -src "/graphics/paperclip.png" -align left -style "margin:5;" 
				    a -href "#" -onclick "return echo.toggleDisplay('echo_file')" { 
					t "Attach a file" 
				    }
				}
			    }
			}
		    ### end of echo form

		    if {0} {
			### start hidden attachment field
			div -id echo_file -style "display:none;margin-top:3;" {
			    iframe -id "upload_target" -name "upload_target" -src "" -style "width:0;height:0;border:0px solid #fff;"
			    form -id echo_attach_frm -name echo_attach_frm -action "/echo/attachment-add" -method "post" -enctype "multipart/form-data" -target "upload_target" {
				input -type hidden -name cb -value uploadSuccessFn
				img -src "/graphics/paperclip.png" -align left -style "margin:5;"
				input -id attachment_1 -type file -name upload_file -onchange "echo.bg_upload()"
				t " "
				a -href "" -class fl -onclick "return echo.toggleDisplay('echo_file')" { t "remove" }
			    }
			}
			### end of hidden attachment field
		    }

		}
		### end of header

	    }

	}
    }
    p

    dataview {
	tpl -for "echo_msgs" {
	    div -class "echo-message" {
	        nt @{content:noquote}
	        small {
		    a -href "//www.phigita.net/~@{screen_name}/" -title "@{first_names} @{last_name}" {
			t @{screen_name}
		    }
		    nt " &#183; "
		    a -href "/~@{screen_name}/echo/@{id}" {
			t "@{creation_date} via @{device}"
		    }
		    tpl -if "@{public_p}" {
			nt " &#183; "
			span -class "special_tag" {
			    t "#public"
			}
		    }
		    tpl -if "@{val.registered_p}" {
			nt " &#183; "
			a -href "#" -onclick "return echo.cbox(@{id})" {
			    t "comment"
			}
		    }
		    tpl -if "@{val.user_id} == @{creation_user}" {
			nt " &#183; "
			a -href "http://echo.phigita.net/message-remove?id=@{id}&return_url=http://www.phigita.net" -onclick "return confirm('Sure you want to delete this update? There is NO undo!');" {
			    t "remove"
			}
		    }
		}
	    }
	    tpl -if "@{cnt_comment}>0" {
		div -class "echo-comment" {
		    small {
			tpl -if "@{cnt_comment} == 1" { 
			    a -href "/~@{screen_name}/echo/@{id}" {
				t "@{cnt_comment} comment"
			    }
			    t ", by " 
			}
			tpl -if "@{cnt_comment} > 1" {
			    a -href "/~@{screen_name}/echo/@{id}" {
				t "@{cnt_comment} comments"
			    }
			    t ", last by " 
			}
			a -href "/~@{last_comment__screen_name}/" { 
			    t @{last_comment__screen_name}
			}
		    }
		    div {
			nt @{last_comment__content:noquote}
		    }
		}
	    }
	    span -id cbox_@{id}
	}
    }

    set action_comment_add "http://echo.phigita.net/comment-add"
    div -id echo_comment_box -style "display:none;" {
	form -action ${action_comment_add} -method "post" {
	    input -id echo_parent_id -type "hidden" -name parent_id -value ""
	    textarea -id echo_comment_text -name content -rows "2" -wrap soft  -style "width:95%;line-height:1.15em;overflow:hidden;font-size:1.15em;border:1px solid #aaa;"
	    div {
		button -type submit -style "font-size:10px;" { t "Add Comment" }
		t " "
		a -class "fl xs" -href "#" -title "Hide" -onclick "return echo.hide('echo_comment_box');" { 
		    t "\[x\]"
		}
	    }
	}
    }


    div {
	a -class "btn btn-link btn-mini" -href "http://echo.phigita.net/" {
	    t "More Echo"
	}
	if {0} {
	    # TODO: when new sim card is installed
	    if { [ad_conn user_id] > 0 } {
		a -class "btn btn-link btn-mini" -href http://my.phigita.net/settings/devices/ {
		    t "Setup SMS"
		}
	    }
	}
    }

    dataview {
	tpl -if @{val.registered_p} {
	    script -type text/javascript {
		# THIS GOES INSIDE THE TEXT NODE BELOW: echo.clearFileInputField(CSS['echo_file']);
		t { 
		    echo.init({applyTo:document['echo_frm'].content});
		}
	    }
	}
    }

}

