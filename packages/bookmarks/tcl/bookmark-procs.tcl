namespace eval ::bm {;}

proc ::bm::bookmarklet_href {} {
    return {javascript:try{var%20d=document;var%20e=d.createElement('script');e.setAttribute('src','http://www.phigita.net/bookmarklet/load.js');(d.getElementsByTagName('head')[0]||d.body).appendChild(e);}%20catch(z)%20{};void(0);}
}

proc ::bm::init_css {} {
    ::xo::html::cssList {linkmenu label bm_remark bm_comment bm_preview actions xs fl}
    ::xo::html::iuse bm_img
}

proc ::bm::init_js {} {
    ::xo::html::add_script3 -key BOOKMARKS.INIT {
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
		var prEl = document.getElementById(id);
	    }
	    if (prEl.style.display != 'block') {
		prEl.style.display = 'block';
	    } else {
		prEl.style.display = 'none';
	    }
	}
	window['bmTP']=bmTP;
    }

}

## if show_user_p is true, then object o must contain screen_name
## if show_comments_p is true, then object must contain last_comment and cnt_comment
proc render_bookmark {o {base ""} {show_user_p "1"} {show_comments_p "1"} {show_labels_p "0"}} {
    upvar __bm_counter bm_counter
    if { [ad_host] ne {remarks.phigita.net} } {
	set remarks_base http://remarks.phigita.net/
    } else {
	set remarks_base ""
    }

    if { [ad_host] ne [::util::coalesce $base "www.phigita.net"] } {
	set base "http://www.phigita.net"
    } else {
	set base ""
    }
    array set uri [::uri::split [${o} set url]]
    set domain [::util::domain_from_host $uri(host)]
    div -class "bm" {
	div -class "bm_bd" {
	    a -class ni_large -href [$o set url] -target _blank {
		t [${o} set title]
	    }
	    set video_p [$o set video_p]
	    if { $video_p } {
		if { [catch {
		    set video_id [dict get [$o set extra] video_id]
		    set href http://video.phigita.net/${video_id}
		} errMsg] } {
		    ns_log notice "render_bookmark: video_p=t but extra dict possibly missing video_id - CHECK: errMsg=$errMsg"
		    set video_p f
		}
	    }
	    if { $video_p } {
		t " "
		a -href $href -style "text-decoration:none;border:0;" {
		    img -src "http://www.phigita.net/graphics/icon_video.gif" -width 19 -height 12 -border 0 -alt {[video]}
		}
	    }
	    if { [$o set preview_p] } {
		$o instvar extra
		set imgArr [list]
		dict with extra {
		    foreach attachment $preview {
			lassign $attachment mediaType mediaUrl sha1 width height
			lappend imgArr "{s:'$sha1',w:${width},h:${height}}"
		    }
		}
		set jsImgArr "\[[join ${imgArr} {,}]\]"
		div -class "bm_preview" -onclick "bmTP(this,'bm_pr_[incr bm_counter]',${jsImgArr});"
	    }
	    if { [${o} set description] ne {} } {
		div -class bm_remark {
		    nt "[::xo::structured_text::minitext_to_html [${o} set description]]"
		}
	    }
	    div -class "bm_details" {
		if { $show_user_p } {
		    span -class user {
			t "-- "
			a -href "${base}/~[${o} set screen_name]/" -title "[${o} set full_name]" {
			    t [${o} set screen_name] 
			}
		    }
		}
		set age_pretty [::util::age_pretty -timestamp_ansi [$o set last_update] -sysdate_ansi [dt_systime]]
		if {0} {
		    a -class "permalink" -href "http://remarks.phigita.net/url/[${o} set url_sha1]" {
			t "$age_pretty"
		    }
		}
		t " "
		span -class "xs domain" {
		    a -href "${remarks_base}/host/$uri(host)" {
			t "#$domain"
		    }
		}

		## Labels
		## Requires label_id_arr, label_text_agg to be set in given object
		if { $show_labels_p } {
		    set label "" ;# check http parameters

		    set label_id_list [split [string trim [${o} set label_id_arr] "{}"] ","]
		    set label_text_list [split [${o} set label_text_agg] "|"]
		    set nlabels [llength ${label_id_list}]

		    set count 0
		    foreach label_id ${label_id_list} label_name ${label_text_list} {
			span -class label {
			    if {[string equal ${label} ${label_name}]} {
				b -style "color:black;" { t ${label_name} }
			    } else {
				set underscored_label_name [string map {" " _} ${label_name}]
				a -class label -href $underscored_label_name {
				    t "#${underscored_label_name}"
				}
			    }
			}
			incr count
			if {${count} < ${nlabels}} {
			    t ", "
			}
		    }
		}

		if { $show_comments_p && [::xo::kit::is_registered_p] } {
		    span -class "actions" {
			nt " &#183; "
			a -class "xs fl" -href "http://remarks.phigita.net/url/[${o} set url_sha1]" {
			    t "comment"
			}
		    }
		}
		if { $show_comments_p } {
		    if { [$o set cnt_comment] } {
			div -class bm_comment {
			    span -class "bm_ft" {
				set commentDict ""
				a -href "http://remarks.phigita.net/url/[${o} set url_sha1]" {
				    set commentDict [$o set last_comment]
				    t "[$o set cnt_comment] [ad_decode [${o} set cnt_comment] 1 comment comments]"
				}
				if { [$o set cnt_comment] == 1 } {
				    t " by "
				} else {
				    t ", last by "
				}
			    }
			    set comment_screen_name [dict get $commentDict screen_name]
			    span -class user {
				a -href "${base}/~${comment_screen_name}/" { t $comment_screen_name }
				t ": "
			    }
			    div {
				nt [::xo::structured_text::minitext_to_html [dict get $commentDict content]]
			    }
			}
		    }
		}
	    }
	}
    }
}



proc ::bm::getJSImageArray {preview} {
    set imgArr [list]
    foreach attachment $preview {
	lassign $attachment mediaType mediaUrl sha1 width height
	lappend imgArr "{s:'${sha1}',w:${width},h:${height}}"
    }
    set jsImgArr "\[[join ${imgArr} {,}]\]"
    return $jsImgArr
}
