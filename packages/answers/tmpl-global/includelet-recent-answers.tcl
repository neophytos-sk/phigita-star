::xo::ns::once /global/templates/includelet_default_style.tcl

::xo::html::cssList {answers action tl s i g nd xs}
::xo::html::cssList {t fl}

::xo::html::add_style {
    .tl {color:#666;}
    .s {font-size:12px;padding:2px;}
    .i {font-family:georgia;}
    .g {color:#666;font-size:12px;}

    .nd {text-decoration:none;}
    .xs {font-size:10px;}
}

set pathexp [list "Subsite 808"]
set limit 3
set questiondata [::db::Set new \
		      -cache "ANSWERS.MOST_RECENT_QUESTIONS" \
		      -select {
			  q.last_answer_user_id 
			  q.subject 
			  q.cnt_answers 
			  q.id 
			  cc.status 
			  {cc.first_names || ' ' || cc.last_name as full_name} 
			  cc.screen_name
		      } -type [::db::Inner_Join new \
				   -lhs [::db::Set new \
					     -alias q \
					     -pathexp $pathexp \
					     -type ::Question \
					     -order "last_answer desc" \
					     -where [list "cnt_answers > 0"] \
					     -limit ${limit}] \
				   -rhs [::db::Set new \
					     -type CC_Users \
					     -alias cc] \
				   -join_condition {cc.user_id=q.last_answer_user_id}] \
		      -limit ${limit} \
		      -order "last_answer desc"]

${questiondata} load

set new_unanswered_data [::db::Set new \
			     -cache "ANSWERS.COUNT_UNANSWERED_LAST_2_DAYS" \
			     -pathexp $pathexp \
			     -select {{count(1) as n_unanswered}} \
			     -type ::Question \
			     -where [list "cnt_answers = 0" "creation_date > current_timestamp-'2 days'::interval"]]

$new_unanswered_data load

set cnt_new_unanswered 0 
if { ![$new_unanswered_data emptyset_p] } {
    set cnt_new_unanswered [[${new_unanswered_data} head] set n_unanswered]
}


div -id "answers" {
    a -href "http://answers.phigita.net/question-ask" -class "action" -style "float:right;" {
	nt "ask"
    }
    a -href "http://answers.phigita.net/vox-pop" -class "action" -style "float:right;" {
	nt "vox pop"
    }
    # border-top:3px solid #DEE5F2;
    div -style "background:#def2e5;padding:2px 0px;" {
	div -class inc_bar_title { nt "answers&nbsp;" }
	div -class inc_bar_subtitle {
	    t "ask a question"
	    br
	    t "get your answer"
	}
    }
    #div -style "border:1px solid #C5D7EF;overflow:hidden;padding:3px 3px 5px;" 
    div {
	#div -class "tl s" { t "\"[mc ask_a_question_get_your_answer "Ask a question. Get your answer."]\"" }
	div -style "padding-left:10px;" {
	    foreach o [${questiondata} set result] {
		set x [${o} set cnt_answers]
		if {${x}<1} {set x 1}

		set y [expr round(95-log(${x})*log10(${x})*1.61)]
		div -style "margin-top:10px;" {
		    a -class t -href "http://answers.phigita.net/[${o} set id]" {
			t [${o} set subject]
		    }
		    t -disableOutputEscaping " &nbsp; "
		    div -class "tl xs" {
			span -class "nd xs" -style "background:rgb(${y}%,${y}%,100%);" {
			    t -disableOutputEscaping "[${o} set cnt_answers]&nbsp;[ad_decode [${o} set cnt_answers] 1 "[mc answer.singular answer]" "[mc answer.plural answers]"]"
			}
			t "[ad_decode [${o} set cnt_answers] 1 "," ", [mc last.female last]"] "
			t " [mc by.user "by"] "
			a -class g -href "/~[util::coalesce [${o} set screen_name] [${o} set last_answer_user_id]]/" {
			    t [${o} set full_name]
			}
			### CHAT presence &nbsp;[getStatusImg [$o set last_answer_user_id] [$o set status]]
			t " (~[util::coalesce [${o} set screen_name] [${o} set last_answer_user_id]])"
		    }
		}
	    }
	}
	#border-bottom:2px solid #dee5f2;
	div -style "margin-top:10px;" {
	    a -class "action bottom_action" -href "http://answers.phigita.net/" {
		t "More Q&A"
	    }
	    a -class "action bottom_action" -title "Unanswered Questions" -href "http://answers.phigita.net/unanswered-questions" {
		t "Unanswered"
	    }

	    if { ${cnt_new_unanswered} } {
		tmpl::tag=new -n_items "&nbsp;${cnt_new_unanswered}&nbsp;" -title "${cnt_new_unanswered} unanswered [ad_decode ${cnt_new_unanswered} 1 question questions] in last 48 hours"
	    }
	    #div -style "margin:5px"
	}
    }
}