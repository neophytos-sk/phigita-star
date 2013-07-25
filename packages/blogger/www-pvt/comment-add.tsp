ad_page_contract {
    @author Neophytos Demetriou
} {
    parent_id:notnull,integer
}

set ctx_uid [ad_conn user_id]

set bi [Blog_Item retrieve \
	    -pathexp [list User ${ctx_uid}] \
	    -output "*" \
	    -criteria "id = ${parent_id}"]

if {[string equal ${bi} ""]} {
    rp_returnnotfound
}


set context_bar_title "One Blog Entry"

set title [${bi} set title]

if {[string equal ${title} ""]} {
    set title "Entry \#[${bi} set id]"
}

script -type "text/javascript" -src "/js/spell-checker/spell-checker.js"
                                                                                
script -type "text/javascript" {
    c {
        var SC = null;
        function initEditor() {
                                                                                
            SC = new SpellChecker();
            return false;
        }
    }
}



tmpl::master -title "Add a comment to ${title}" -context_bar [ad_context_bar [list ${parent_id} ${context_bar_title}] "Add a Comment"] -onload "initEditor()" {
    table -width "100%" -border "0" -cellpadding "4" -cellspacing "0" {
        tr -bgcolor "#EEF3FB" {
            td -colspan "2" -align "left" {
                font -face "arial" -size "-1" {
                    t [mc Add_comment_to_entry_warning "I have a comment to contribute that will be of interest to other readers of this page two or three years from now. "]
                }
            }
        }
    }
    p


    b {
	t [${bi} set title] 
    }
    p
    t -disableOutputEscaping [stx_to_html [${bi} set body]]
    p
    table -width 100% {
	tr {
	    td {
		small {
		    t "posted at "
		    t [lc_time_fmt [${bi} set entry_date] %Q]
		    t " "
		    t [lc_time_fmt [${bi} set entry_date] %r]
		    t -disableOutputEscaping "&nbsp;&nbsp;" 
		}
	    }
	}
    }
    p
    small {
	form -action comment-add-2 -method POST {
	    input -type hidden -name parent_id -value ${parent_id}
	    b { t "Enter your comment below:" }
	    br
	    b { a -href "" -style "text-decoration:none;font-variant: small-caps;" -class fl -onclick "SC.buttonPress('ta');return false;" { t \[[mc Spell_Check "Spell Check"]\] } }
	    t " "
                img -src /graphics/spell-check -width 18 -height 18 -onclick "SC.buttonPress('ta')" -title [mc Spell_Check "Spell Check"]
            br
	    textarea -id "ta" -name "comment" -rows "15" -cols "80" -wrap "soft"
	    p
	    input -type submit -value "Preview"
	}
    }
}
