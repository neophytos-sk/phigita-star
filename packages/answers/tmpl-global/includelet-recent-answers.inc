
set pathexp [list "Subsite 808"]
set limit 3
datastore \
    -id ds_questions \
    -cache "ANSWERS.MOST_RECENT_QUESTIONS" \
    -select {
	q.last_answer_user_id 
	q.subject 
	q.cnt_answers 
	q.id 
	cc.status 
	{cc.first_names || ' ' || cc.last_name as full_name} 
	cc.screen_name
    } -from_class [::db::Inner_Join new \
		       -lhs [::db::Set new \
				 -alias q \
				 -scope subsite \
				 -type ::Question \
				 -order "last_answer desc" \
				 -where [list "cnt_answers > 0"] \
				 -limit ${limit}] \
		       -rhs [::db::Set new \
				 -type CC_Users \
				 -alias cc] \
		       -join_condition {cc.user_id=q.last_answer_user_id}] \
    -limit ${limit} \
    -order "last_answer desc"


#####
p

div -id "answers" {
    a -href "http://answers.phigita.net/question-ask" -class "btn btn-mini" -style "float:right;margin-left:1px;" {
	nt "ask"
    }
    t "Forum"
    t " "
    sup { t "ask a question, get your answer" }

    dataview \
	-store ds_questions \
	-template {
	    <dl>
	    <tpl for=".">
	    <dt>
	    <a class="t" href="http://answers.phigita.net/{id}">@{subject}</a>
	    </dt>
	    <dd>
	    <div>
	    <span>@{cnt_answers} <tpl if="@{cnt_answers} == 1">answer</tpl><tpl if="@{cnt_answers} > 1">answers, last</tpl></span>
	    by
	    <a href="/~@{screen_name}/">@{full_name}</a>
	    (~@{screen_name})
	    </div>
	    </dd>
	    </tpl>
	    </dl>
	}
    
    div -style "margin-top:10px;" {
	a -class "btn btn-link btn-mini" -href "http://answers.phigita.net/" {
	    t "More Q&A"
	}
	a -class "btn btn-link btn-mini" -title "Unanswered Questions" -href "http://answers.phigita.net/unanswered-questions" {
	    t "Unanswered"
	}
    }
}

p

div -id "polls" {
    t "Poll"
    t " "
    sup { t "vox populi" }
    a -href "http://answers.phigita.net/vox-pop" -class "btn  btn-mini" -style "float:right;margin-left:1px;" {
	nt "create"
    }
}
