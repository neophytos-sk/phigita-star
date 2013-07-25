accounts::trusted_member_check

tmpl::master -title "Invite a friend to phigita.net" -context_bar [ad_context_bar "Invite a friend to phigita.net"] {

    blockquote {

	t "An invitation has been emailed to your friend. "

	# A copy of this invitation has been saved in your Sent Mail folder.

	

	a -href "/my/friend-invite" {
	    t "Invite another friend"
	}
    }

}
