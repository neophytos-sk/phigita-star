proc render_blog_post {bi u root {is_permalink_page "true"}} {
    ::xo::html::cssList {post post_content auth typo_date meta label post_title}

    div -class post {

	h2 -class post_title {
	     a -href [${bi} set id] { t [${bi} set title] }
	}
	p -class auth {
	    t "Posted by "
	    a -href "/~[$u set screen_name]/" {
		t "[$u set first_names] [$u set last_name]"
	    }
	    t ", "
	    span -class "typo_date" -title [$bi set typo_date] {
		t [$bi set typo_date]
	    }
	}

	div -class post_content {
	    if { [catch {
		#nt [stx_to_html "\n [${bi} set body]" -root_of_hierarchy $root -object_id ${id}]
		$bi instvar {body post_content}
		array set config [list root ${root} container_object_id [${bi} set id] image_prefix "image/"]
		::xo::structured_text::stx_to_html config post_content html
		nt $html
	    } errmsg] } {
		nt "<span style=\"color:red;\">*</span>[$bi set body]"
		ns_log notice "Error - ::xo::structured_text::stx_to_html (entry-one.tsp): $errmsg"
	    }



	}
	p -class meta {
	    set nlabels [llength [${bi} set label_id_list]]
	    if { $nlabels > 0 } {
		t "Posted in "
		set j 0
		foreach v_label_id [${bi} set label_id_list] label_name [${bi} set label_text_list] {
		    a -class label -href ".?label_id=${v_label_id}" {
			t ${label_name}
		    }
		    if { [incr j] < $nlabels } {
			t ", "
		    }
		}
		if { $is_permalink_page } {
		    t " | "
		}
	    }
	    if { $is_permalink_page } {
		t "[ad_decode [$bi set cnt_comments] 0 no [$bi set cnt_comments]] comments"
	    } else {
		p -class meta {
		    a -href [${bi} set id] -title "Permanent Link" { t [mc Permanent_Link "Permanent Link"] }
		    if {![string equal [${bi} set cnt_comments] 0]} {
			t " \[ "
			t "[${bi} set cnt_comments] [ad_decode [${bi} set cnt_comments] 1 comment comments]"
			if {[${bi} set is_new_p]} {
			    tmpl::tag=new -title "Recent Comments"
			}
			t " \]"

		    }
		    if { [${bi} set allow_comments_p] } {
			nt "&nbsp;-&nbsp;"
			a -href "comment-add?parent_id=[${bi} set i\d]" {
			    t [mc Add_a_Comment "Add a Comment"]
			}
		    }
		}
	    }
	}
    }
}
