
set base http://remarks.phigita.net

val -id num_of_links { return 5 }
val -id registered_p { ::xo::kit::is_registered_p }


datastore \
    -id linkdata \
    -cache "BOOKMARKS_TOP5_SHARED" \
    -select {
	bm.url
	bm.url_sha1
	bm.title
	bm.description
	bm.video_p
	bm.preview_p
	bm.last_update
	bm.cnt_comment
	bm.last_comment
	bm.extra
	{first_names || ' ' || cc.last_name as full_name}
	{cc.screen_name}
	{cc.user_id}
    } -from_class [db::Inner_Join new \
		       -lhs [::db::Set new -type ::sw::agg::Url \
				 -alias bm \
				 -where [list "cnt_shared > 0"] \
				 -order {max_sharing_start_date desc} \
				 -limit @{num_of_links}] \
		       -rhs [::db::Set new \
				 -select "status user_id first_names last_name screen_name" \
				 -from "users u inner join persons p on (u.user_id=p.person_id)" \
				 -alias cc] \
		       -join_condition {cc.user_id = bm.max_sharing_user_id}] \
    -order {max_sharing_start_date desc} \
    -extend {
	set description [::xo::structured_text::minitext_to_html $description]
	set age_pretty [::util::age_pretty -timestamp_ansi $last_update -sysdate_ansi [dt_systime]]

	if { $cnt_comment != 0 } {
	    set comment_screen_name [dict get $last_comment screen_name]
	    set commentContent [::xo::structured_text::minitext_to_html [dict get $last_comment content]]
	}

	if { $preview_p  } {
	    set jsImgArr [::bm::getJSImageArray [dict get $extra preview]]
	    set rownum [incr bm_counter]
	} else {
	    set jsImgArr \[\]
	}

	array set uri [::uri::split $url]
	set domain [::util::domain_from_host $uri(host)]
	set host $uri(host)

	if { $video_p } {
	    if { [catch {
		set video_id [dict get $extra video_id]
		set href http://video.phigita.net/${video_id}
	    } errMsg] } {
		set video_p 0
		ns_log notice "includelet-recent-shared-links: video_p check, possibly missing video_id in extra: errMsg=$errMsg"
	    }
	}
    }


js -deps {
   kernel/lib/base.js
} {
    function bmTP(el,id,imgArr){
	var pn = el.parentNode;
	if (!pn.render) {
	    var prEl = document.createElement('div');
	    prEl.id = id;
	    pn.insertBefore(prEl,el.nextSibling);
	    for(var i=0;i<imgArr.length;i++) 
	    {
	     var imgEl   = document.createElement('img');
	     imgEl.src   ='http://img.phigita.net/'+imgArr[i]['s'];
	     imgEl.width =imgArr[i]['w'];
	     imgEl.height=imgArr[i]['h'];
	     var divEl   = document.createElement('div');
	     divEl.setAttribute('class','bm_img');
	     prEl.appendChild(divEl);
	     divEl.appendChild(imgEl);
	 }
	    pn.render=1;
	} else {
	    var prEl = $(id);
	}
	if (prEl.style.display != 'block') {
	    prEl.style.display = 'block';
	} else {
	    prEl.style.display = 'none';
	}
    }
    window['bmTP']=bmTP;
}



css {

    .host_tag {color: #060;}

    .bm_details small {
	display: block;
	line-height: 20px;
	color: #999999;
    }

    .bm_details small a { color: #666; }
    .bm_details small:before {
	content: '-- ';
    }

    .bm_comment {
	margin: 0 0 10px 20px;
	padding: 0 0 0 10px;
	border-left: 1px dashed #aaa;
    }

    .bm_comment small {
	display: block;
	line-height: 20px;
	color: #999999;
    }

    .bm_comment small a { color: #666; }

    .bm_preview {
	display:inline-block;
	background:url(/graphics/bg_preview.png);
	width:10px;
	height:10px;
	margin:0 3px;
	cursor:pointer;
    }
    .bm_header {
	background:#f2dee5;padding:2px 0px;height:1.5em;
	color:#865A69;
    }
    .bm_header strong {
	font-size: 16px;
	margin-left:5px;
    }
    .bm_action {
	width:40px;
    }
}


div -id remark {

    # title is set for Internet Explorer 
    # (uses "remark" as title for the link instead of "post-it")
    a -class "btn btn-default btn-mini bm_action" -href [::bm::bookmarklet_href] -title "reMark" -style "float:right;" {
	t "reMark"
    }
    div -class "bm_header" {
	strong { t "reMark" }
	t " "
	sup { t "human judgment first" }
    }

    dataview {
	tpl -for "linkdata" {
	    dl {
		dt {
		    a -href "@{url}" -target _blank {
			t "@{title}"
		    }
		    tpl -if { @{video_p} } {
			a -href "@{href}" -style "text-decoration:none;border:0;" {
			    img -src "//www.phigita.net/graphics/icon_video.gif" -width 19 -height 12 -alt {video}
			}
		    }
		    tpl -if { @{preview_p} } {
			div -class "bm_preview" -onclick "bmTP(this,'bm_pr_{rownum}',@{jsImgArr});"
		    }
		}
		dd {
		    tpl -if { @{description} ne {} } {
			div -class bm_remark {
			    t "@{description:noquote}"
			}
		    }
		    div -class "bm_details" {
			small {
			    span -class user {
				a -href "/~@{screen_name}/" -title "@{full_name}" {
				    t "@{screen_name}"
				}
			    }
			    nt " &#183; "
			    a -class "permalink" -href "http://remarks.phigita.net/url/@{url_sha1}" {
				t "@{age_pretty}"
			    }
			    nt " &#183; "
			    a -class "host_tag" -href "${base}/host/@{host}" {
				    t "#@{domain}"
			    }
			    tpl -if @{val.registered_p} {
				nt " &#183; "
				span {
				    a -href "http://remarks.phigita.net/url/@{url_sha1}" {
					t "comment"
				    }
				}
			    }
			}
		    }
		    tpl -if @{cnt_comment} {
			div -class "bm_comment" {
			    small {
				a -href "http://remarks.phigita.net/url/@{url_sha1}" {
				    t @{cnt_comment}
				    t " "
				    tpl -if "@{cnt_comment} == 1" { t "comment" }
				    tpl -if "@{cnt_comment} > 1" { t "comments" }
				}
				tpl -if { @{cnt_comment} == 1 } { t " by " }
				tpl -if { @{cnt_comment} > 1 } { t ", last by " }
				span -class user {
				    a -href "/~@{comment_screen_name}/" { t @{comment_screen_name} }
				    t ": "
				}
			    }
			    div {
				t @{commentContent:noquote}
			    }
			}
		    }
		}
	    }
	}
    }

    a -class "btn btn-link btn-mini" -href "http://remarks.phigita.net/" {
	t "More reMark"
    }
    dataview {
	tpl -if @{val.registered_p} {
	    t " "
	    a -class "btn btn-link btn-mini" -href "https://my.phigita.net/bookmarks/" {
		t "Your Bookmarks"
	    }
	    t " "
	    a -class "btn btn-link btn-mini" -href "https://my.phigita.net/bookmarks/bookmark-howto" {
		t "How To Bookmark"
	    }
	}
    }

}

