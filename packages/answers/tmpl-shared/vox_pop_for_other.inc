set limit 10
set limit_plus_one [expr {1+${limit}}]

val -id limit "return ${limit}"

# polldata for public view for other/registered users
datastore \
    -id polldata \
    -scope context_user \
    -select {
	owner.question_id 
	owner.question_subject
	owner.question_extra
	{owner.answer_choice as owner_choice}
	{owner.answer_private_p as owner_private_p}
	{coalesce(other.answer_choice,0) as other_choice}
	{other.answer_private_p as other_private_p}
    } -from_class [::db::Left_Outer_Join new \
		       -lhs [::db::Set new \
				 -alias "owner" \
				 -scope context_user \
				 -type ::Poll_User_Answer \
				 -order "creation_date desc" \
				 -where [list "NOT answer_private_p" "live_p"]] \
		       -rhs [::db::Set new \
				 -alias "other" \
				 -scope user \
				 -type ::Poll_User_Answer \
				 -where [list "live_p"]] \
		       -join_condition {owner.question_id=other.question_id}] \
    -offset @{offset} \
    -limit ${limit_plus_one} \
    -extend {
	set choices [dict get $question_extra choices]
	set owner_answer_text [lindex $choices [expr { ${owner_choice} - 1 }]]
	set other_answer_text [lindex $choices [expr { ${other_choice} - 1 }]]
    }

val -id prev_url { 
    set offset [expr { @{offset} - @{limit} }]
    if { $offset <= 0 } { set offset "" }
    export_vars -url -base "." -no_empty offset  
}

val -id next_url { 
    set offset [expr { @{offset} + @{limit} }]
    export_vars -url -base "." -no_empty offset 
}

val -id current_url { return [ns_conn url] }


# -------------------------------------------------------------------------------------------------

js {
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


# -------------------------------------------------------------------------------------------------



	tpl -if "@{polldata:rowcount}" {
	    div -class h2 { t "questions answered publicly (only registered users can see)" }
	    tpl -for "polldata" -limit ${limit} {
		div -class "question" {
		    div -class "qtext" { 
			t @{question_subject} 
		    }	

		    # other did not answer this question
		    # add button to enable her to answer
		    tpl -if { @{other_private_p} eq {} } {

			# add possible response options (hidden)
			set base "http://www.phigita.net"

			#set form_action "http://localhost:8090/answers/vox-pop-vote"
			set form_action "http://answers.phigita.net/vox-pop-vote"

			form -action ${form_action} -method post {
			    div -id "@{question_id}_choices" -style "display:none;" {

				input -type hidden -name "parent_id" -value "@{question_id}"
				input -type hidden -name "return_url" -value "${base}@{val.current_url}"
				tpl -for "choices" {
				    div -class "choice inline" {
					label {
					    input \
						-id "q@{parent.question_id}_c@{_:rownum}" \
						-type radio \
						-name choice \
						-value @{_:rownum}  \
						-onclick "validateFrm('@{parent.question_id}')"
					    
					    t " @{_}"
					}
				    }
				}
				div -class "inline" -style "font-weight:normal;margin-top:10px;font-size:10px;" {
				    label -for @{question_id}_private { 
					input \
					    -type checkbox \
					    -name private_p \
					    -id @{question_id}_private \
					    -value "t"
					
					t " Answer this question privately." 
				    }
				}
			    }
			    div {
				a \
				    -id @{question_id}_answer \
				    -class "action_answer" \
				    -href "http://answers.phigita.net/@{question_id}" \
				    -onclick "return showOptions('@{question_id}')" { 
					nt "&#8627;&nbsp;answer" 
				    }
				
				button \
				    -id @{question_id}_submit \
				    -class "action_submit" \
				    -disabled "disabled" { 
					t "Answer" 
				    }
				
				a \
				    -id @{question_id}_cancel \
				    -class "action_cancel" \
				    -href "#" \
				    -onclick "return hideOptions('@{question_id}')" { 
					t "Cancel" 
				    }
			    }
			}
		    }
		    tpl -else "" {
			# i.e. if other_private_p is non-null
			tpl -if { not @{other_private_p} } {
			    div { 
				div -class "compare_who" { t "Me:" } 
				div -class "compare_atext" { t "@{owner_answer_text}" } 
			    }
			    div { 
				div -class "compare_who" { t "You:" }
				div -class "compare_atext" { t "@{other_answer_text}" } 
			    }
			}
			tpl -if { @{other_private_p} } {
			    div { 
				div -class "compare_who" { t "Me:" } 
				div -class "compare_atext compare_hint" { t "Answer publicly to see my public answer" } 
			    }
			    div { 
				div -class "compare_who" { t "You:" }
				div -class "compare_atext" { 
				    t "@{other_answer_text}"
				    a -class "action_anchor" \
					-href "make-answer-public?question_id=@{question_id}&return_url=@{val.current_url}" \
					-onclick "return confirm('You are going public. Are you sure?')" { 
					    nt "&larr;&nbsp;go public" 
					}
				}
			    }
			}
		    }
		}
	    }
	}
	tpl -else "" {
	    t "None Yet"
	}


# note this needs to be executed AFTER THE ABOVE
# thankfully it works, but it won't always work like this
# when you need to do this, replicate/wrap it inside the same 
# if condition that applies for the include, in this case 
# that user_id==context_user_id
#
    div -x-master-renderTo "sidebar" {
	dataview {
	    tpl -if { @{user_id} != @{context_user_id} } {
		p
		div -style "text-align:center;" {
		    tpl -if "@{offset} > 0 || @{polldata:rowcount} == ${limit_plus_one}" {
			div -class "sidebar-heading" {
			    t "Navigate" 
			}
			p
			span -style "background:#ccc;padding:2px;" {
			    tpl -if "@{offset} > 0" {
				a -href "@{prev_url}" { nt "&laquo; Newer" }
			    }
			    tpl -if "@{offset} > 0 && @{polldata:rowcount} == ${limit_plus_one}" {
				t " | "
			    }
			    tpl -if "@{polldata:rowcount} == ${limit_plus_one}" {
				a -href "@{next_url}" { nt "Older &raquo;" }
			    }
			}
		    }
		}
	    }
	}
    }

