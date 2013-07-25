ad_page_contract {

    @author Neophytos Demetriou

} {
    id:integer,notnull
}
 
set pathexp [list "User [ad_conn user_id]"]
set o [::db::One new -pathexp ${pathexp} -type ::wiki::Page -where [list "id=[ns_dbquotevalue ${id}]"]]

if { ![${o} exists_p] } {
    rp_returnnotfound
    return
}

tmpl::master -title "Edit Page" -context_bar [ad_context_bar "Edit Page"] {
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


	form -name tf -action page-edit-2 -method post -onsubmit {return wikiwyg_divs[0].testChanges(document.forms['tf'].elements['body']);} {
	    input -name "id" -type "hidden" -value ${id}
	    input -name "old_shared_p" -type "hidden" -value [${o} get shared_p]

	    br
	    textarea -id "ta" -name "body" -rows "15" -cols "80" -wrap "soft" -style "display:none;"
	    div -id "wikidiv" -style "width:600;height:200;" {
		t -disableOutputEscaping [stx_to_html [${o} get content] -allow_href_p 1 -edit_p 1]
	    }
	    p
	    b { t "Subject: " }
	    t "Enter the topic of your page."
	    br
	    input -class input -type "text" -name "subject" -value [${o} get title] -maxlength "80" -size "80" -onkeypress "return event.keyCode!=13;"
	    br
	    font -color "\#666666" -size "-1" {
		i {
		    t -disableOutputEscaping "for example:<br>&nbsp; \"Entrepreneurship and the Market Process\",<br>&nbsp; \"Dynamic Programming\",<br>&nbsp; \"The Basics of Behaviorism\""
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
