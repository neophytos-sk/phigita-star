set subsite_id [ad_conn subsite_id]

set questiondata [db::Set new -select {q.* {cc.first_names || ' ' || cc.last_name as full_name} cc.screen_name} -type [::db::Inner_Join new -lhs [db::Set new -alias q -pathexp [list "Subsite [ad_conn subsite_id]"] -type ::Question -order "last_answer desc" -where "cnt_answers>0"] -rhs [db::Set new -from CC_Users -alias cc] -join_condition {cc.user_id=q.last_answer_user_id}] -order "last_answer desc"]
${questiondata} load



tmpl::master -title "List of Answered Questions" -context_bar [ad_context_bar "List of Answered Questions"] {

    h2 {
	t "List of Answered Questions"
    }
    ul {
	foreach o [${questiondata} set result] {
	    li {
		a -href "[${o} set id]" {
		    t [${o} set subject]
		}
                            br
		font -color "\#666666" -size "-2" {
		    t " [${o} set cnt_answers] [ad_decode [${o} set cnt_answers] 1 "answer, on" "answers, last on"] [lc_time_fmt [${o} set last_answer] %q] by [${o} set full_name]"
		    t -disableOutputEscaping "&nbsp;(&nbsp;~[util::coalesce [${o} set screen_name] [${o} set last_answer_user_id]]&nbsp;)"
		}
                            br
	    }
	}
    }

    p
    div -style "margin-left:32px;width:250;padding:5 5 5 5;border:1px dashed \#efefef;" {
    	if {0} {
		    <script type="text/javascript"><!--
		    google_language = 'en';
		    google_encoding = 'utf-8';
		    google_country = 'gr';
		    google_ad_client = "pub-1374549828513817";
		    google_alternate_color = "ffffff";
		    google_ad_width = 234;
		    google_ad_height = 60;
		    google_ad_format = "234x60_as";
		    google_ad_type = "text";
		    google_ad_channel = "";
		    //--></script>
		    <script type="text/javascript" src="http://pagead2.googlesyndication.com/pagead/show_ads.js"></script>
	}
    }



}
