## DATA

datastore \
    -id questiondata \
    -scope context_user \
    -from_class ::Poll_User_Answer \
    -order "creation_date desc" \
    -where [list "live_p"] \
    -limit 10 \
    -extend {
	set choices [dict get $question_extra choices]
    }

val -id ns_conn_url { return [ns_conn url] }

## ATTENTION!!! PRIVATE DATA - BE CAREFUL
h2 { t "your answered questions (limited to the last 10)" }

tpl -for questiondata {
    div -class "question" {
	p -class "qtext @{answer_private_p}_private_p" { 
	    t @{question_subject}
	    ul {
		tpl -for choices {
		    tpl -if { @{_:rownum} == @{parent.answer_choice} } {
			li {
			    span -class "owner_choice mine" { 
				t @{_}
			    }
			    tpl -if @{parent.answer_private_p} {
				a \
				    -class action_anchor \
				    -href "make-answer-public?question_id=@{parent.question_id}&return_url=@{val.ns_conn_url}" \
				    -onclick "return confirm('You are going public. Are you sure?')" { 
					nt "&larr;&nbsp;go public" 
				    }
			    }
			}
		    } 
		    tpl -else "" {
			li -class "owner_choice" { 
			    t @{_} 
			}
		    }
		}
	    }
	}
    }
}
