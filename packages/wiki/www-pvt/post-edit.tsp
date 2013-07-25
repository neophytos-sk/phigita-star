ad_page_contract {

    @author Neophytos Demetriou

} {
    id:integer,notnull
}
 
set blog_item [Blog_Item retrieve \
		   -pathexp "User [ad_conn user_id]" \
		   -output "*" \
		   -criteria "id = [ns_dbquotevalue ${id}]"]

script -type "text/javascript" -src "/my/spell-checker/spell-checker.js"
  
script -type "text/javascript" {
    c {
        var SC = null;
        function initEditor() {
  
            SC = new SpellChecker();
            return false;
        }
    }
}
 

tmpl::master -title "Edit Post" -context_bar [ad_context_bar "Edit Post"] -onload "initEditor()" {

    style {
	c {
	    #postButtons p {
		float:left;
		margin-right:.3em;
	    }
	    button, .btn, a.ltBlue, a.dkBlue, a.orange, a.tan {
		font-weight:bold;
		padding:0.5em 1em 0.5em 1em;
		cursor:pointer;
		margin:0em !important;
		background-image:none !important;
	    }
	    a.ltBlue:hover, a.dkBlue:hover, a.orange:hover, a.tan:hover {
		_text-decoration:underline;
	    }

	    .ltBlue {
		cursor:pointer;
		border-bottom:solid 2px #002255;
		border-right:solid 2px #002255;
		border-top:solid 1px #003366;
		border-left:solid 1px #003366;
		background-color:#6699ff;
		color:#fff;
		font-size:105%;
		padding:.4em;
		font-weight:normal;
	    }
	    .ltBlue:hover {
		text-decoration:underline;
	    }


	    .dkBlue {
		cursor:pointer;
		border-bottom:solid 2px #000;
		border-right:solid 2px #000;
		border-top:solid 1px #336699;
		border-left:solid 1px #336699;
		background-color:#002255;
		color:#fff;
		font-size:105%;
		text-decoration:none;
		padding:.4em;
		font-weight:bold;
	    }
	    .dkBlue:hover {
		text-decoration:none;
		background-color:#003366;
		color:#fff;
	    }
	    a.dkBlue:hover {
		_background-color:#002255;
	    }

	    .orange {
		cursor:pointer;
		border-right:solid 2px #E55C00;
		border-bottom:solid 2px #E55C00;
		border-top:solid 2px #FF751A;
		border-left:solid 2px #FF751A;
		background-color:#ff6600;
		color:#fff;
		font-size:105%;
		font-weight:bold;
		padding:.4em;
		text-decoration:none;
	    }
	    .orange:hover {
		text-decoration:none;
		color:#fff;
		background-color:#FF751A;
	    }
	    a.orange:hover {
		_background-color:#ff6600;
	    }

	}
    }

    b { t "Edit your blog entry below" }
    p
    small {
	form -action post-edit-2 -method POST {
	    input -name "id" -type "hidden" -value ${id}
	    input -name "old_shared_p" -type "hidden" -value [${blog_item} set shared_p]

	    b { t "Blog Entry: " }
	    br
	    b { a -href "" -style "text-decoration:none;font-variant: small-caps;" -class fl -onclick "SC.buttonPress('ta');return false;" { t \[[mc Spell_Check "Spell Check"]\] } }
	    t " "
                img -src /graphics/spell-check -width 18 -height 18 -onclick "SC.buttonPress('ta')" -title [mc Spell_Check "Spell Check"]
            br
	    textarea -id "ta" -name "body" -rows "15" -cols "80" -wrap "soft" {
		t -disableOutputEscaping [${blog_item} set body]
}	
	    p
	    b { t "Subject: " }
	    t "Enter the topic of your entry (e.g. \"Hiking in New Mexico\")."
	    br
	    input -type "text" -name "subject" -value [${blog_item} set title] -maxlength "80" -size "80" -onkeypress "return event.keyCode!=13;"
	    div {
		b {
		    font -face "Arial" -size "-1" {
			t [mc Allow_Comments " Allow New Comments on This Post"]:
		    }
		}
		t -disableOutputEscaping "&nbsp;&nbsp;"

		br
		if {[${blog_item} set allow_comments_p]} {
		    input -type "radio" -name "allow_comments_p" -value "t" -size 50 -checked "" -id "allow_comments_p:t" {
			label -for "allow_comments_p:t" {
			    t [mc yes "Yes"]
			}
		    }
		    t " "
		    input -type "radio" -name "allow_comments_p" -value "f" -size 50  -id "allow_comments_p:f" {
			label -for "allow_comments_p:f" {
			    t [mc no "No"]
			}
		    }
		} else {
		    input -type "radio" -name "allow_comments_p" -value "t" -size 50 -id "allow_comments_p:t" {
			label -for "allow_comments_p:t" {
			    t [mc yes "Yes"]
			}
		    }
		    t " "
		    input -type "radio" -name "allow_comments_p" -value "f" -size 50  -checked "" -id "allow_comments_p:f" {
			label -for "allow_comments_p:f" {
			    t [mc no "No"]
			}
		    }
		}
	    }
	    p -id "postButtons" {
		input -value "Save as Draft" -type "submit" -id "saveDraft" -name "saveDraft" -class "btn dkBlue"
		t -disableOutputEscaping "&nbsp;"
		input -value "Publish Post" -type "submit" -id "publishPost" -name "publishPost" -class "btn orange"
	    }
	}
    }

}
