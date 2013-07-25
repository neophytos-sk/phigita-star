set subsite_id [ad_conn subsite_id]

set limit 7
set questiondata1 [db::Set new -cache ANSWERS_APP.MOST_RECENT_QUESTIONS -select {q.* {cc.first_names || ' ' || cc.last_name as full_name} cc.screen_name} -type [::db::Inner_Join new -lhs [db::Set new -alias q -pathexp [list "Subsite [ad_conn subsite_id]"] -type ::Question -order "creation_date desc" -limit ${limit}] -rhs [db::Set new -type CC_Users -alias cc] -join_condition {cc.user_id=q.creation_user}] -order "creation_date desc" -limit ${limit}]
${questiondata1} load

set questiondata2 [db::Set new -cache ANSWERS_APP.MOST_RECENT_ANSWERS -select {q.* {cc.first_names || ' ' || cc.last_name as full_name} cc.screen_name} -type [::db::Inner_Join new -lhs [db::Set new -alias q -pathexp [list "Subsite [ad_conn subsite_id]"] -type ::Question -order "last_answer desc" -where "cnt_answers>0" -limit 4] -rhs [db::Set new -type CC_Users -alias cc] -join_condition {cc.user_id=q.last_answer_user_id}] -order "last_answer desc"]
${questiondata2} load




set meta_keywords "Q&A, Vox Pop, Polls, Knowledge, Information, Greek, Cyprus, Greece"
set meta_description "A continually improving collection of user-contributed questions and answers."
tmpl::master -docStyleId doc2 -docStyleClass z-t2 -title "Answers in Greek" -meta_description $meta_description -meta_keywords $meta_keywords {

    ::xo::html::add_style {
	a {color:#04c;}

	#latest_answers .answer {margin:5px 0 0 10px;}
	#latest_answers {width:50%;margin-left:250px;border-left:1px dashed #999;padding-left:15px;}

	#questions {margin-bottom:15px;}
	#questions .question {margin:3px 0;}
	#questions .creation_date {color:#666;font-size:11px;}

	#polls {float:left;width:250px;padding:0;margin:0;}

	#citations {padding:10;}
	#citations ul {padding:5px;margin:0;}
	#citations ul li {list-style-type:none;}
	#citations ul li a {font-size:12px;color:green;}

	a.g {color:#666;font-size:12px;text-decoration:underline;}
	.actions {margin:5px 0;}

    }

    div -id "bd" {	
	div -id "z-main" {
	    div -class "z-b" {
		div -class "z-gc" {
		    div -class "z-u first" {
			b {
			    a -class "fl" -href "question-ask" { t "Ask a Question" }
			    t " | "
			    a -class "fl" -href "vox-pop" { t "Vox Pop the World" }
			}
			# {	<form action="askquestion" method="post"> <table cellpadding="3" bgcolor="#cacae3" cellspacing="0" border="0" width="1%"> <tr> <td width="2%" nowrap rowspan="3">&nbsp;</td> <td width="96%" nowrap> <font size="-1">Step 1 - Enter your Question. <a href="help/">Tips for great results.</a></font> </td> <td width="2%" nowrap rowspan="3">&nbsp;</td> </tr> <tr> <td width="96%" valign="top"> <span class="c"> <textarea wrap="soft" rows="5" cols="80" name="body"></textarea> </span> </td> </tr> <tr> <td width="96%" align="right" valign="top"> <font size="-1"> <input type="submit" name="submitmain" value="Ask Question"> </font> </td> </tr> </table> </form> }

			div -id "questions" {
			    h2 {
				t "New Questions"
			    }
			    ul {
				if {[${questiondata1} emptyset_p]} {
				    li {
					i { t "None" }
				    }
				}
				foreach o [${questiondata1} set result] {
				    li -class question {
					if { [$o set kind] == 1 } {
					    t { [vox pop] }
					}
					a -href [${o} set id] {
					    t [${o} set subject]
					}
					span -class creation_date { t " ([lc_time_fmt [${o} set creation_date] %q])" }
				    }
				}
			    }
			    div -class "actions" {
				a -class "fl" -href "all-questions" -title "List of all questions." {
				    t "More Questions"
				}
				t " | "
				a -class "fl" -href "unanswered-questions" {
				    t "Unanswered Questions"
				}
			    }
			}

			div -id "polls" {
			    b { t "Random Vox Pop" }
			    p
			    t ""
			}
			div -id "latest_answers" {
			    b { t "Latest Answers" }
			    foreach o [${questiondata2} set result] {
				div -class "answer" {
				    a -href "[${o} set id]" {
					t [${o} set subject]
				    }
				    div -style "color:#666;font-size:10px;" {
					t " [${o} set cnt_answers] [ad_decode [${o} set cnt_answers] 1 "answer, on" "answers, last"] by "
					a -class g -href "http://www.phigita.net/~[$o set screen_name]/" -title [$o set screen_name] { 
					    t "[${o} set full_name]"
					}
				    }
				}
			    }
			    div -class "actions" {
				a -class "fl" -href "answered-questions" -title "List of all answered questions." {
				    t "More Answers"
				}
			    }

			}
		    }

		    div -class "z-u" {
			div -id "citations" {
			    i { t "Knowledge Bases" }
			    ul {
				li {
				    a -href "http://citeseer.ist.psu.edu/" -title "Scientific Literature Digital Library" {
					t "citeseer"
				    }
				}
				li {
				    a -href "http://www.faqs.org/" {
					t "faqs"
				    }
				}
				li {
				    a -href "http://stackoverflow.com/" {
					t "stackoverflow"
				    }
				}
				li {
				    a -href "http://groups.google.com" {
					t "google groups"
				    }
				}
				li {
				    a -href "http://www.howstuffworks.com/" {
					t "howstuffworks"
				    }
				}
				li {
				    a -href "http://www.investopedia.com/" {
					t "investopedia"
				    }
				}
				li {
				    a -href "http://msdn.microsoft.com/" {
					t "msdn"
				    }
				}
				li {
				    a -href "http://www.refdesk.com/" {
					t "refdesk"
				    }
				}
				li {
				    a -href "http://www.tldp.org/" -title "The Linux Documentation Project" {
					t "tldp"
				    }
				}
				li {
				    a -href "http://en.uncyclopedia.org/" {
					t "uncyclopedia"
				    }
				}
				li {
				    a -href "http://en.wikipedia.org/" {
					t "wikipedia"
				    }
				}
			    }
			    p
			    br
			    p
	::xo::google::adsense::slot 5109930996 125 125
			}
		    }
		}
	    }
	}
    }
}





