namespace eval ::app::answers {;}

proc ::app::answers::init {} {}


proc ::app::answers::css_default_style {} {
    ::xo::html::add_style {
	#poll {width:350px;margin:25px;}
	#poll_inner {background:#def2e5;border:1px dotted #5a8669;padding:10px;-moz-border-radius:0.7em;-webkit-border-radius:0.7em;border-radius:0.7em;}
	#poll_question {font-size:13px;line-height:18px;font-weight:bold;padding:5px;margin:2px 8px 0 0;color:#5a8669;}
	.poll_choice {margin:2px 8px;font-size:12px;line-height:22px;color:#3a5c55;}
	#poll_etc {border-top:1px dotted #5a8669;margin-top:10px;}
	#poll_submit {margin:5px 0;}
	#poll_submit button {width:100px;height:25px;}
	#poll_privacy {font-size:9px;color:#666;margin-top:5px;}
    }
}


proc ::app::answers::js_code {} {

    ::xo::html::add_script3 -key POLLS.CREATE_POLL -deps {
	answers/lib/polls.js
    } -names_map "POLL_CSS" -names {
	arrows action first choices choice fl addChoice question_textarea submitBtn
    }

}


proc ::app::answers::render_poll {qo {url ""}} {

    $qo instvar id
    $qo instvar subject
    $qo instvar extra

    ## check if the user answered already
    set user_id [ad_conn user_id]
    set pathexp [list "User $user_id"]
    set user_answer_data [::db::Set new \
			      -pathexp $pathexp \
			      -type ::Poll_User_Answer \
			      -where [list "question_id=[ns_dbquotevalue $id]" "live_p"] \
			      -limit 1]
    $user_answer_data load

    set button_text "Answer"
    set answer_choice ""
    set answer_private_p ""
    set show_results_p 0
    if { ![$user_answer_data emptyset_p] } {
	set user_answer [$user_answer_data head]
	set answer_choice [$user_answer set answer_choice]
	set answer_private_p [$user_answer set answer_private_p]
	set button_text "Re-Answer"
	if { !$answer_private_p } {
	    set show_results_p 1
	}
    }
    ## end of user answer check

    set presentation_type [dict get $extra presentation_type]
    set choices [dict get $extra choices]

    set css_exclude_list [list "private_answer"]
    form -action $url -method post {
	input -type hidden -name parent_id -value $id
	div -id "poll" {
	    div -id "poll_inner" {
		div -id "poll_question" { t $subject }
		div -id "poll_choices" {
		    set i 0
		    foreach choice $choices {
			lappend css_exclude_list "choice_[incr i]"
			div -class "poll_choice" {
			    set input_node [::tmpl::input -id choice_$i -name choice -type radio -value $i -onchange "validateFrm()" -onclick "validateFrm()"]
			    set label_node [::tmpl::label -for choice_$i -onclick "validateFrm()" { t $choice }]
			    if { $answer_choice eq ${i} } {
				#span -style "font-size:10px;" { t "<<< your answer" }
				$input_node setAttribute checked checked
				$label_node setAttribute style "text-decoration:underline;"
			    }
			}
		    }
		}
		div -id "poll_etc" {
		    div -style "font-size:10px;color:#666;margin-top:5px;" { t "You can always Re-Answer this question." }
		    div -id "poll_privacy" {
			div -style "float:left;" {
			    set input_node [::tmpl::input -type checkbox -name private_p -id private_answer -value "t" -checked "checked" -onclick "validateFrm()"]
			    if { $answer_private_p eq {f} } {
				$input_node removeAttribute checked
			    }
			}
			div -style "padding:3px;" {
			    label -for private_answer { t "Answer this question privately." }
			}
		    }
		    div -id "poll_submit" {
			set button_node [::tmpl::button -id "voteBtn" -type submit -disabled "disabled" { t $button_text }]
			if { $answer_choice ne {} } {
			    $button_node removeAttribute disabled
			}
		    }
		    if { [::xo::kit::is_registered_p] } {
			div -style "font-size:10px;color:#666;margin:5px 0;" { 
			    t "Answering questions publicly lets you compare"
			    br
			    t "your answers with other people."
			}
		    }
		}
	    }
	}
    }
    ::xo::html::iexclude $css_exclude_list


    set admin_p [::xo::kit::admin_p]
    if { $admin_p || $show_results_p } {

	set subsite_pathexp [list "Subsite [ad_conn subsite_id]"]

	set votes_data [::db::Set new \
			    -select "choice {count(1) as cnt_votes}" \
			    -pathexp $subsite_pathexp \
			    -type ::Poll_Answer \
			    -where [list "parent_id=[ns_dbquotevalue $id]" "live_p"] \
			    -order "choice" \
			    -group "choice"]

	$votes_data load

	set max_votes 0
	set sum_votes 0
	foreach o [$votes_data set result] {
	    $o instvar cnt_votes
	    if { $max_votes < $cnt_votes } {
		set max_votes $cnt_votes
	    }
	    incr sum_votes $cnt_votes
	}

	if { $admin_p } {
	    div {
		t "sum_votes = $sum_votes"
	    }
	}


	div {
	    if { $sum_votes < 10 } {
		t "Not enough data points to show results!"
	    } elseif { $sum_votes < 100 } {
		nt "These results are of <b>low accuracy</b> (fewer than 100 data points)."
	    } elseif { $sum_votes < 1000 } {
		nt "These results are of <b>medium accuracy</b> (between 1000 and 1000 data points)."
	    } else {
		nt "These results are of <b>high accuracy</b> (more than 1000 data points)."
	    }
	}

	if { $sum_votes >= 10 } {
	    foreach o [$votes_data set result] {
		$o instvar cnt_votes
		div {
		    set percentage [expr { 100*(double($cnt_votes) / double($sum_votes)) }]
		    t "Choice [$o set choice]: [format "%.1f" $percentage]%"
		    if { $admin_p } {
			t " ($cnt_votes votes) "
		    }
		}
	    }
	}

    }
}


proc ::app::answers::init_profile_css {} {
    ::xo::html::cssList {
	qtext 
	choice 
	mine 
	f_private_p 
	t_private_p 
	question 
	compare_who 
	compare_atext 
	compare_hint 
	action_anchor
	action_answer
	action_submit
	action_cancel
	private_answer
    }

    ::xo::html::add_style {
	h2 {border-bottom:1px solid #e9e9e9;color:#777;font-size:18px;font-weight:normal;margin:0 0 15px;padding:0 0 5px;}
	ul {list-style-type:disc;padding-left:15px;}
	.qtext {margin-bottom:5px;color:#777;font-size:13px;font-weight:bold;line-height:18px;margin:0 0 10px;font-family:Verdana,"Bitstream Vera Sans",sans-serif;}
	.owner_choice {color:#569424;font-size:12px;line-height:16px;}
	.choice {color:#555;font-size:12px;line-height:22px;font-weight:normal;}
	.mine {text-decoration:underline;}
	.f_private_p {color:#2963a4;}
	.question {padding:12px 15px 0 17px;margin:0 0 3px;}
	.compare_who {float:left;height:25px;color:#777;width:25px;text-align:right;overflow:hidden;margin:3px 7px 0 0;}
	.compare_atext {padding-top:5px;line-height:16px;height:25px;overflow:hidden;}
	.compare_hint {color:#2963a4;font-style:italic;}
	.action_anchor {border:0;color:#2963a4;margin:0 0 0 5px;padding:0 2px;}
	a.action_anchor:hover {background:#d5ddf3;color:#369;}
	.action_answer {display:inline-block;border:0;color:#2963a4;font-weight:normal;margin:0 0 0 5px;padding:0 2px;width:75px;}
	.action_answer:hover {background:#d5ddf3;}
	.action_submit {display:none;margin:0 8px;}
	.action_submit:hover {}
	.action_cancel {display:none;color:#666;border:1px solid #aaa;width:75px;text-align:center;font-weight:normal;}
	.action_cancel:hover {background:#eee;}
    }

}

proc ::app::answers::profile_view_from_owner {context_user_id} {

    ## DATA
    ## DECISION: no caching
    ## -cache "Vox-Pop:User-${context_user_id}:TOP10_POLL_ANSWERS-[::xo::kit::is_registered_p]"

    set pathexp [list "User $context_user_id"]
    set vp_questions [::db::Set new \
			  -pathexp $pathexp \
			  -type ::Poll_User_Answer \
			  -order "creation_date desc" \
			  -where [list "live_p"] \
			  -limit 10 \
			  -load]


    ## ATTENTION!!! PRIVATE DATA - BE CAREFUL
    h2 { t "Your questions" }
    foreach qo [$vp_questions set result] {
	div -class "question" {
	    p -class "qtext [$qo set answer_private_p]_private_p" { t [$qo set question_subject] }
	    ul {
		set i 0
		$qo instvar question_id question_extra answer_private_p
		set choices [dict get $question_extra choices]

		foreach choice $choices {
		    if { [incr i] == [$qo set answer_choice] } {
			li {
			    span -class "owner_choice mine" { 
				t $choice 
			    }
			    if { $answer_private_p } {
				a -class action_anchor -href "make-answer-public?question_id=$question_id&return_url=[ns_conn url]" -onclick "return confirm('You are going public. Are you sure?')" { nt "&larr;&nbsp;go public" }
			    }
			}
		    } else {
			li -class "owner_choice" { t $choice }
		    }
		}
	    }
	}
    }
}

proc ::app::answers::profile_view_from_other {context_user_id user_id} {

    ## JS
    script {
	t {
	    $ = function(id) {
		return document.getElementById(id);
	    }
	    show = function(id) {
		$(id).style.display='inline-block';
	    }
	    hide = function(id) {
		$(id).style.display='none';
	    }
	    showOptions = function(cssId) {
		hide(cssId+'_answer');
		show(cssId+'_choices');
		show(cssId+'_submit');
		show(cssId+'_cancel');
		return false;
	    }
	    hideOptions = function(cssId) {
		show(cssId+'_answer');
		hide(cssId+'_choices');
		hide(cssId+'_submit');
		hide(cssId+'_cancel');
		return false;
	    }
	    validateFrm = function(cssId) {
		$(cssId+'_submit').disabled=false;
	    }
	}
    }

    ## DATA
    ## DECISION: no caching
    ## -cache "Vox-Pop:User-${context_user_id}:TOP10_POLL_ANSWERS-[::xo::kit::is_registered_p]"

    set pathexp [list "User $context_user_id"]
    set owner_questions [::db::Set new \
			     -alias "owner" \
			     -pathexp $pathexp \
			     -type ::Poll_User_Answer \
			     -order "creation_date desc" \
			     -where [list "NOT answer_private_p" "live_p"]]

    set other_pathexp [list "User $user_id"]
    set other_questions [::db::Set new \
			     -alias "other" \
			     -pathexp $other_pathexp \
			     -type ::Poll_User_Answer \
			     -where [list "live_p"]]
			     
    set questions [::db::Set new \
		       -select {
			   owner.question_id 
			   owner.question_subject
			   owner.question_extra
			   {owner.answer_choice as owner_choice}
			   {owner.answer_private_p as owner_private_p}
			   {coalesce(other.answer_choice,0) as other_choice}
			   {other.answer_private_p as other_private_p}
		       } -type [::db::Left_Outer_Join new \
				    -lhs $owner_questions \
				    -rhs $other_questions \
				    -join_condition {owner.question_id=other.question_id}]]
    
    $questions load

    ## ATTENTION!!! PRIVATE DATA - BE CAREFUL
    h2 { t "The public questions" }
    foreach qo [$questions set result] {
	div -class "question" {
	    set question_node [div -class "qtext" { t [$qo set question_subject] }]
	    set i 0
	    $qo instvar question_id question_extra other_private_p
	    set choices [dict get $question_extra choices]

	    set owner_answer_text [lindex $choices [expr {[$qo set owner_choice]-1}]]
	    set other_answer_text [lindex $choices [expr {[$qo set other_choice]-1}]]
	    if { $other_private_p eq {f} } {
		div { 
		    div -class "compare_who" { t "Me:" } 
		    div -class "compare_atext" { t "$owner_answer_text" } 
		}
		div { 
		    div -class "compare_who" { t "You:" }
		    div -class "compare_atext" { t "$other_answer_text" } 
		}
	    } elseif { $other_private_p eq {t} }  {
		div { 
		    div -class "compare_who" { t "Me:" } 
		    div -class "compare_atext compare_hint" { t "Answer publicly to see my public answer" } 
		}
		div { 
		    div -class "compare_who" { t "You:" }
		    div -class "compare_atext" { 
			t "$other_answer_text"
			a -class "action_anchor" -href "make-answer-public?question_id=$question_id&return_url=[ns_conn url]" -onclick "return confirm('You are going public. Are you sure?')" { nt "&larr;&nbsp;go public" }
		    }
		}
	    } else {
		# other did not answer this question
		# add button to enable her to answer
		$question_node appendFromScript {
		    # add possible response options (hidden)
		    set base "http://www.phigita.net"
		    #set form_action "http://localhost:8090/answers/vox-pop-vote"
		    set form_action "http://answers.phigita.net/vox-pop-vote"
		    form -action $form_action -method POST {
			div -id "${question_id}_choices" -style "display:none;" {

			    input -type hidden -name "parent_id" -value "$question_id"
			    input -type hidden -name "return_url" -value "${base}[ns_conn url]"
			    set i 0
			    foreach choice $choices {
				div -class choice {
				    label {
					input -type radio -name choice -value [incr i] -onclick "validateFrm('${question_id}')"
					t $choice
				    }
				}
			    }
			    div -style "font-weight:normal;margin-top:10px;font-size:10px;" {
				input -type checkbox -name private_p -id ${question_id}_private -value "t"
				label -for ${question_id}_private { t "Answer this question privately." }
			    }
			}
			div {
			    a -id ${question_id}_answer -class "action_answer" -href "http://answers.phigita.net/${question_id}" -onclick "return showOptions('${question_id}')" { nt "&#8627;&nbsp;answer" }
			    button -id ${question_id}_submit -class "action_submit" -disabled "disabled" { t "Answer" }
			    a -id ${question_id}_cancel -class "action_cancel" -href "#" -onclick "return hideOptions('${question_id}')" { t "Cancel" }
			}
		    }
		    ::xo::html::iexclude "${question_id}_choices ${question_id}_private ${question_id}_answer ${question_id}_submit ${question_id}_cancel"
		}
	    }
	}
    }
}