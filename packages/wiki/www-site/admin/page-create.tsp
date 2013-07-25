ad_page_contract {

	@author Neophytos Demetriou

} {
	{title ""}
	{body ""}
}

set comment {
link -rel "stylesheet" -type "text/css" -href "/css/spellchecker.css"
script -type "text/javascript" -src "/js/spellchecker/base.js"
script -type "text/javascript" -src "/js/spellchecker/lite.js"


}


tmpl::master -title "Create Page" -context_bar [ad_context_bar "Create Page"] {
    script -type "text/javascript" -src "/my/spell-checker/sc.js"
 
    link -rel "stylesheet" -type "text/css" -href "/css/wikiwyg.css"
    script -type "text/javascript" -src "/js/wikiwyg/wikiwyg.js"
    script -type "text/javascript" -src "/js/wikiwyg/ClientServer.js"

script {
    c {
	var SC = null;
	var wikiwyg_divs = [];
	onload = function() {
	    var config = {
		doubleClickToEdit: false,
		toolbar: {
		    imagesLocation: '/graphics/wikiwyg/'
		},
		wysiwyg: {
		    disabledToolbarButtons: [ 'table' ],
		    editHeightMinimum: 300,
		    editHeightAdjustment: 1.3
		},
		wikitext: {
		}
	    };
	    var wikidiv = document.getElementById('wikidiv');
	    var wikiwyg = new Wikiwyg.ClientServer();
	    wikiwyg.createWikiwygArea(wikidiv, config);
	    wikiwyg_divs.push(wikiwyg);
	    window.setTimeout('wikiwyg_divs[0].editMode();wikiwyg_divs[0].current_mode.process_command(\'p\');',0);
	    SC = new SpellChecker();
	    return false;

	}
    }
}

    style {
	c {
            .input { font-size: 20px; width:400; padding: 5px; }
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

    p
small {
    div -style "background:\#f0f0f0;width:575;padding:10;border:3px solid \#e0e0e0;" {
        div -style "float:left;" {
            b { t "Do's" }
            dl {
                li { t "Choose a topic you care about." }
                li { t "Give out expert knowledge." }
                li { t "Include good tips and accurate information." }
                li { t "Think of it as a section of a book." }
            }
        }
        div -style "margin-left:300;" {
            b { t "Don'ts" }
            dl {
                li { t "Make sure it is not self-serving." }
                li { t "No copyright violations." }
                li { t "No advertising or solicitation." }
                li { t "No illegal activities." }
            }
        }
    }
}

form -name tf -action page-create-2 -method post -onsubmit {return wikiwyg_divs[0].testChanges(document.forms['tf'].elements['body']);} {
    textarea -id ta -name body -rows "15" -cols "80" -wrap "soft" -style "display:none;" {
    }
    div -id "wikidiv" -style "width:600;" {
	br
    }
    br
    b { t "Subject: " }
    t "Enter the topic of your page."
    br
    input -class input -type "text" -name "subject" -value ${title} -maxlength "80" -size "80"
    br
    font -color "\#666666" -size "-1" {
	i {
	    t -disableOutputEscaping "for example:<br>&nbsp; \"Entrepreneurship and the Market Process\",<br>&nbsp; \"Dynamic Programming\",<br>&nbsp; \"The Basics of Behaviorism\""
	}
    }
    set comment {
	br
	b {
	    font -face "Arial" -size "-1" {
		t [mc Allow_Comments " Allow New Comments on This Post"]:
	    }
	}
	t -disableOutputEscaping "&nbsp;&nbsp;"
	br
	input -type "radio" -name "allow_comments_p" -value "t" -size 50 -checked "" -id "allow_comments_p:t" {
	    label -for "allow_comments_p:t" {
		t [mc yes "Yes"]
	    }
	}
	t " "
	input -type "radio" -name "allow_comments_p" -value "f" -size 50 -id "allow_comments_p:f" {
	    label -for "allow_comments_p:f" {
		t [mc no "No"]
	    }
	}
    }

small {
    p -id "postButtons" {
	input -value "Save as Draft" -type "submit" -id "saveDraft" -name "saveDraft" -class "btn dkBlue"
	t -disableOutputEscaping "&nbsp;"
	input -value "Publish Page" -type "submit" -id "publishPost" -name "publishPost" -class "btn orange"
    }
}
}


##################################

set comments {
    p
    table -width "100%" -border "0" -cellpadding "4" -cellspacing "0" {
        tr -bgcolor "#EEF3FB" {
            td -colspan "2" -align "left" {
                font -face "arial" -size "-1" {
                    t "Enter your blog entry below."
                }
            }
        }
    }
    p
    small {
	form -action post-create-2 -method POST {
	    b { t "Blog Entry: " }
            br
	    b { a -href "" -style "text-decoration:none;font-variant: small-caps;" -class fl -onclick "SC.buttonPress('ta');return false;" { t \[[mc Spell_Check "Spell Check"]\] } }
	    t " "
	    img -src /graphics/spell-check -width 18 -height 18 -onclick "SC.buttonPress('ta')" -title [mc Spell_Check "Spell Check"]
	    br
	    textarea -id "ta" -name "body" -rows "15" -cols "80" -wrap "soft" {
		t -disableOutputEscaping ${body}
	    }	
	    p
	    b { t "Subject: " }
	    t "Enter the topic of your entry (e.g. \"Hiking in New Mexico\")."
	    br
	    input -type "text" -name "subject" -value ${title} -maxlength "80" -size "80"
	}
    }

}
}