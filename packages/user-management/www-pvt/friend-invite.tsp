accounts::trusted_member_check

style -type "text/css" {
    c {
	.ic { background-color:#74D982; }
        .ct {padding:12;height:100%;vertical-align:top;background-color:#B5EDBC;}
        .sm {font-size:80%}
    }
}

set user_id [ad_conn user_id]
set this_user_full_name [db_string get_full_name "select first_names || ' ' || last_name from cc_users where user_id=:user_id"]


set invitation_text {
%s has invited you to open a free phigita.net account. The invitation
will expire in two weeks and can only be used to set up one account.

To accept this invitation and register for your account, visit

    %s

If you haven't already heard about phigita.net, it's a new online community of greek internet users that helps you:

- Publish to the web instantly.

- Get answers to your questions.

- Chat with friends on the web.

- Contribute comments to your friends' postings.

- Access your bookmarks from any computer.

phigita.net is still in an early stage of development. But If you set up an
account, you'll be able to keep it even after we make phigita.net more
widely available. We might also ask for your comments and suggestions
periodically and we appreciate your help in making phigita.net even better.

Thanks,

The phigita.net Team

To learn more about phigita.net before registering, visit:
http://www.phigita.net/

(If clicking the URLs in this message does not work, copy and paste them
 into the address bar of your browser).}

set invitation_text [_ invitation_text ${invitation_text} el_GR]
set invitation_text [format ${invitation_text} ${this_user_full_name} "_INVITE LINK_"]


script -type "text/javascript" {
    c {

	function previewInvitation() {
	    if (document.getElementById('smsg').style.display == 'none') {
		document.getElementById('smsg').style.display = 'block';
		document.getElementById('show_hide').innerHTML = 'hide invite text';
	    } else {
		document.getElementById('smsg').style.display = 'none';
		document.getElementById('show_hide').innerHTML = 'show invite text';
	    }
	}
    }
}

tmpl::master -title "Invite a friend to phigita.net" -context_bar [ad_context_bar "Invite a friend to phigita.net"] {

    table -align "center" -border 0 -cellpadding 3 -cellspacing 2 -width 95% -class ic {
	tr {
	    td -class ic {
		font -size "3" { b { t "Invite a friend to phigita.net!" } }
	    }
	}
	tr {
	    td -class ct {
		t [_ invitation_help_text {Thanks for using phigita.net and helping us improve the service. We're ready to expand our community to a few more users, and because you've been a trusted early member of phigita.net, we're looking for your help. Please invite a few more people who you think would like phigita.net and could help us make it even better.} el_GR]
		p

		b {
		    t [_ invitation_sent_to "Send Invite To" el_GR]:
		}

		form -name "f" -method "post" -action "friend-invite-2" {
		    blockquote {
			blockquote {
			    table -cellspacing 0 -cellpadding 3 {
				tr {
				    td -width 1% -nowrap "" { t [_ invitation_first_name "First Name" el_GR]: }
				    td -width 3 { t -disableOutputEscaping "&nbsp;" }
				    td { input -type text -name "first_name" -size 12 }
				}
				tr {
				    td -width 1% -nowrap "" { t [_ invitation_last_name "Last Name" el_GR]: }
				    td -width 3 { t -disableOutputEscaping "&nbsp;" }
				    td { input -type text -name "last_name" -size 12 }
				}
				tr {
				    td -width 1% -nowrap "" { t "Email:"	}
				    td -width 3 { t -disableOutputEscaping "&nbsp;" }
				    td { input -type text -name "email" -size 24 }
				}
			    }
			}
                        table -cellspacing 0 -cellpadding 0 {
			    tr {
				td -colspan "3" -class "ic" -height "2"
			    }
			    tr { td { br } }
			    tr {
				td -colspan 3 {
				    blockquote {
					t "Add a note to the invitation (optional):"
					br
					textarea -name "msg" -rows "5" -cols "50" {
					    t [_ invitation_msg {I've been using phigita.net and thought you might like to try it out. Here's an invitation to create an account.} el_GR]
					}
					br
					small {
					    a -id "show_hide" -name "show_hide" -href "javascript:previewInvitation()" -tabindex "-1" { t "show invite text" }
					}
				    }
				}
			    }
			    tr { td { br } }
			    tr { td -align center -class sm { input -type "submit" -name "inv" -value "Send Invite" } }
			    tr { td { br } }
			    tr {
				td -colspan "3" -class "ic" -height "2"
			    }
			    tr { td { br } }
			    tr { 
				td {
				    div -id "smsg" -name "smsg" -style "width:400px; display:none;" {
					small {
					    t -disableOutputEscaping [stx_to_html ${invitation_text}]
					}
				    }
				}
			    }
			}
		    }
		}
	    }
	}
    }


}
