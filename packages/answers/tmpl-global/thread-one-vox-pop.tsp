#source [acs_root_dir]/packages/answers/tcl/answers-procs.tcl



::app::answers::css_default_style

tmpl::master -docStyleId doc -docStyleClass z-t7 -title "[${qo} set subject] - Vox Pop" -context_bar [ad_context_bar "One Question"] {
    set js [::xo::html::cssListToJS CSS "voteBtn"]
    append js {
	function validateFrm() {
	    var el = document.getElementById(CSS['voteBtn']);
	    el.disabled=false;
	}
    }
    script { t $js }

    p
    div -id "bd" {
	div -id "z-main" {
	    div -class "z-g" {

		div -style "background:#c2bddd;padding:4px;font-weight:bold;color:#eee;" {
		    t "Vox Pop Question"
		}

		div -style "background:#eee;padding:4px;color:#666;" {
		    t "Created on "; t [lc_time_fmt [${qo} set creation_date] "%Q"]
		    if { 0 && [${qo} set cnt_answers]} {
			br
			t "Number of answers: "; b { t [${qo} set cnt_answers] }
		    }
		}

		::app::answers::render_poll $qo vox-pop-vote

		div {
		    #p
		    #nt [stx_to_html [${qo} set body]]
		    #${qo} instvar {body post_content}
		    #array set config [list root "[User set id]-[$qo set user_id]" container_object_id ${id} image_prefix "image/"]
		    #::xo::structured_text::stx_to_html config post_content html
		    #nt $html
		}

		if { ![${qo} set anonymous_p] } {
		    t "-- "
		    if {![string equal [${qo} set screen_name] ""]} {
			set nickname [${qo} set screen_name]
		    } else {
			set nickname [${qo} set user_id]
		    }
		    a -href "http://www.phigita.net/~${nickname}/" {
			t "[${qo} set first_names] [${qo} set last_name]"
		    }
		    sub {
			nt "&nbsp;~${nickname}"
		    }
		}
		
		if {0 && [llength ${answers}] >0} {
		    center {
			h2 {
			    t [mc readers_answers "Reader's Answers"]
			}
		    }
		    foreach answer_obj ${answers} {
			#lappend cssList answer-[${answer_obj} set id]
			lappend cssList [${answer_obj} set id]
			
			try {
			    blockquote -id [${answer_obj} set id] {
				if {![string equal [${answer_obj} set screen_name] ""]} {
				    set nickname [${answer_obj} set screen_name] 
				} else {
				    set nickname [${answer_obj} set user_id]
				}
				#nt [stx_to_html [${answer_obj} set body]]
				$answer_obj instvar {body post_content}
				array set config [list root "[User set id]-[$answer_obj set user_id]" container_object_id "X" image_prefix "/~${nickname}/blog/image/"]
				::xo::structured_text::stx_to_html config post_content html
				nt $html
				t "-- "
				a -href "http://www.phigita.net/~${nickname}/" {
				    t "[${answer_obj} set first_names] [${answer_obj} set last_name]"
				}
				sub {
				    nt "&nbsp;~${nickname}"
				}
				t ", [lc_time_fmt [${answer_obj} set creation_date] %q]"
				p
			    }
			} catch {*} {
			    ns_log notice "answers error: question \#[$answer_obj set id] trymsg=$trymsg"
			    t "error: \#[$answer_obj set id]"
			} trymsg
			br
			br
		    }
		}

		if {0} {
		    p
		    form -action "answer-add" -method "get" {
			input -type "hidden" -name "parent_id" -value "${id}"
			center {
			    input -type "submit" -value "Contribute an answer"
			}
		    }
		}
		p
	    }
	    
	    div -class z-g {
		div {
		    #::xo::google::adsense::slot 2463122883 250 250
		}
	    }

	}
    }
}

::xo::html::iexclude $cssList
