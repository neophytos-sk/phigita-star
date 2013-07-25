ad_page_contract {

	@author Neophytos Demetriou

} {
	{title ""}
	{body ""}
}

ad_maybe_redirect_for_registration

set user_id [ad_conn user_id]


#script -type "text/javascript" -src "/js/spell-checker/spell-checker.js"
  
#script -type "text/javascript" {
#    c {
#        var SC = null;
#        function initEditor() {
#  
#            SC = new SpellChecker();
#            return false;
#        }
#    }
#}
# -onload "initEditor()"

::xo::html::add_style {
    textarea.subject {background:#ffc;color:#333;font-size:14px;line-height:18px;padding:2px;margin:5px 0 0 3px;height:40px;width:300px;}
    #tips {background:#f0f0f0;width:700px;border:3px solid #e0e0e0;font-size:10px;margin:auto;}
    #choices { padding:5px 0px; }
    input.choice {font-size:14px;padding:2px;margin:2px 0px 2px 3px;height:18px;width:250px;}
    #poll {width:700px;margin:auto;padding:0;}
    #poll_frm {width:350px;float:left;margin:0;}
    #poll_frm form {padding:0px;margin:0px;}
    #poll_preview {width:350px;margin:10px 0 0 350px;}
    #poll_preview_inner {background:#def2e5;border:1px dotted #5a8669;margin:15px 30px;padding:10px;-moz-border-radius:0.7em;-webkit-border-radius:0.7em;border-radius:0.7em;}
    #preview_question {font-size:18px;padding:5px;margin:5px 3px;height:20px;color:#5a8669;}
    .preview_choice {margin:5px;font-size:14px;color:#3a5c55;}
    #preview_submit {margin-left:10px;margin-top:10px;}
    .action {opacity:0.4;filter:alpha(opacity=40);background:url(/graphics/swap.png);position:relative;float:left;margin-top:5px;top:-13px;width:19px;height:19px;}
    a.first {background:#fff;}
    a.action:hover {opacity:1.0;filter:alpha(opacity=100)}

    img {border:0;}
}


::app::answers::js_code


tmpl::master -title "Vox Pop the World" -context_bar [ad_context_bar "Vox Pop the World"] -onload "init()" {
    p
    div -style "background:#eef3fb;padding:4px;width:700px;margin:auto;" {
	t "Create your vox pop below"
    }
    p
    div -id "tips" {
	div -style "float:left;padding-left:30px;" {
	    b { t "How to create a vox pop" }
	    dl {
		li { t "Break up multi-part questions" }
		li { t "Write in a clear, concise and unbiased fashion" }
		li { t "Provide mutually exclusive options" }
		li { t "Cover all aspects of an issue" }
		li { t "Ensure that the question text is brief" }
	    }
	}
	div -style "margin-left:350px;padding-left:30px;" {
	    b { t "Refrain from asking vox pop questions that:" }
	    dl {
		li { t "Interject personal opinion into question text" }
		li { t "Leave uncertainty as to what is being asked" }
		li { t "Are meant to sell or advertise products" }
		li { t "Refer or relate to adult content" }
		li { t "Are homework or exam questions" }
	    }
	}
    }
    div -id "poll" {
	div -id "poll_frm" {
	    form -action vox-pop-2 -method POST {
		b { t "Question: " }
		t "Enter the topic of your question below"
		br
		textarea -id question_textarea -tabindex [incr tabindex] -class subject -type "text" -name "subject" -value ${title} -wrap soft -rows 2 -onkeyup "update()" 
		div -style "padding:0;margin:0;font-size:10px;color:#999;font-style:italic;" { t "e.g. Were you born in the morning or evening?" }
		p
		b { t "Answers: " }
		t "Include all possible response options"
		div -id "choices" {
		    set minChoices 2
		    set numChoices 5
		    for {set i 1} {$i <= $numChoices} {incr i} {
			div { 

			    # 9650 (up) 9660 (down)
			    # 8593 (upwards arrow) 8595 (downwards arrow)
			    if { $i == 1 } {
				set cls "action first"
			    } else {
				set cls "action"
			    }
			    div -class arrows {
				a -class $cls -href "#" -onclick "return moveUp(this)" {
				    #img -src /graphics/swap.png -width 19 -height 19
				}
			    }
			    input -tabindex [incr tabindex] -class choice -type "text" -name "choice" -onkeyup "update()" -onsubmit "return false;"
			    if { $i > $minChoices } {
				a -class "fl" -href "#" -onclick "delChoice(this);return false;" { t {[x]} }
			    }

			}
		    }
		    a -id "addChoice" -href "#" -onclick "return addChoice(this)" { t "add another" }
		}
		if {0} {
		    p
		    b { t "Additional Details: " }
		    t "(optional)"
		    br
		    textarea -id "ta" -name "body" -tabindex [incr tabindex] -rows "2" -style "width:300px;" -wrap "soft" -onkeyup "update()" { nt ${body} }
		}
		p
		b { t "Author Identification:" }
		br
		input -type "radio" -name "anonymous_p" -value "t" -id "anonymous_p:t" -checked "" 
		label -for "anonymous_p:t" {
		    t "Anonymous"
		}
		br
		input -type "radio" -name "anonymous_p" -value "f" -id "anonymous_p:f" 
		label -for "anonymous_p:f" {
		    t [db_string user_full_name "select first_names || ' ' || last_name from cc_users where user_id=:user_id"]
		}
		
		p

		#input -type "submit" -value "Save as Draft"
		input -id submitBtn -tabindex [incr tabindex] -type "submit" -value "Publish Question"
		#	    input -type "submit" -value "Save"

	    }
	}
	div -id "poll_preview" {
	    b { t "Preview: " }
	    t "Here's how your vox pop will look like"
	    br
	    div -id "poll_preview_inner" {
		div -id "preview_question" { t "Question Text Here" }
		div -id "preview_choices" {
		    div -class "preview_choice" {
			input -id choice_1 -name choice -type radio
			label -for choice_1 { t "First Choice" }
		    }
		    div -class "preview_choice" {
			input -id choice_2 -name choice -type radio
			label -for choice_2 { t "Second Choice" }
		    }
		    div -class "preview_choice" {
			input -id choice_3 -name choice -type radio
			label -for choice_3 { t "Third Choice" }
		    }
		    div -class "preview_choice" {
			input -id choice_4 -name choice -type radio
			label -for choice_4 { t "Fourth Choice" }
		    }
		    div -class "preview_choice" {
			input -id choice_5 -name choice -type radio
			label -for choice_5 { t "Fifth Choice" }
		    }
		}
		div -id "preview_submit" {
		    button -type submit -disabled "disabled" { t "Answer" }
		}
	    }
	}
    }
}

::xo::html::iuse {choice_1 choice_2 choice_3 choice_4 choice_5}