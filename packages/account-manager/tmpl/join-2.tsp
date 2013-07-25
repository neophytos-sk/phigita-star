ad_page_contract {

    @author Neophytos Demetriou
    Enters a new user into the database.

} {
    token:trim,notnull
    password:trim,notnull
    password_confirmation:trim,notnull
    firstname:trim,notnull
    lastname:trim,notnull
    nickname:trim,notnull
    {question ""}
    {answer ""}
} -validate {
    passwords_match -requires {password:notnull password_confirmation:notnull} {
	if {![string equal ${password} ${password_confirmation}]} {
            ad_complain "Passwords do not match"
	}
    }
	member_check -requires token:notnull {
	    lassign [split ${token} -] invite_id payload
	    db_1row get_email_from_invite "select email from xo__friend_invite_tokens where invite_id=:invite_id"
	    set exists_p [db_0or1row check_users "select 1 from parties where email=:email"]
	    if { $exists_p } {
		ad_complain "An account is already associated with <b>${email}</b>. Forgot your password? <a href=\"http://www.phigita.net/accounts/forgotten-password\">Reset it here</a>"
	    }
	}
    nickname_check -requires nickname:notnull {
	if {[regexp {[^a-z0-9\.]} ${nickname} match]} {
            ad_complain "Sorry, only letters (a-z), numbers (0-9), and periods (.) are allowed."
	}
	if { [string length ${nickname}] < 5 || [string length ${nickname}] > 30 } {
            ad_complain "Sorry, your username must be between 5 and 30 characters long."
	}
	if { [string index ${nickname} 0] == "." } {
            ad_complain "Sorry, the first character of your username must be an ascii letter (a-z) or number (0-9)."
        }
	if { [string index ${nickname} end] == "." } {
            ad_complain "Sorry, the last character of your username must be an ascii letter (a-z) or number (0-9)."
        }
	if {[db_0or1row check_nickname_exists "select 1 from users where screen_name=:nickname"]} {
	    ad_complain "<b>${nickname}</b> is not available."
	}
    }
    full_name_check -requires {firstname:notnull lastname:notnull} {
	if { [info exists firstname] && [string first "<" $firstname] != -1} {
	    ad_complain " You can't have a &lt; in your first name because it will look like an HTML tag and confuse other users."
	}

	if {[info exists lastname] && [string first "<" $lastname] != -1} {
	    ad_complain " You can't have a &lt; in your last name because it will look like an HTML tag and confuse other users."
	}
    }
}



set inv_id ""
set payload ""
lassign [split ${token} -] inv_id payload


if {![db_0or1row get_invitation_info "select inv.*,u.user_id,u.screen_name, (CURRENT_TIMESTAMP - '2 weeks'::interval > inv.creation_date) as expired_p from xo__friend_invite_tokens inv left outer join cc_users u on (inv.email = u.email) where inv.invite_id=:inv_id and inv.token=:payload"]} {
        rp_internal_redirect /packages/account-manager/tmpl/link-broken
}

if {[string equal ${friend_id} ""]} {
   db_transaction {

	set user_id [accounts::one-create \
	-email $email \
	-first_name $firstname \
	-last_name $lastname \
	-password $password \
	-question $question \
	-answer $answer \
	-member_state approved \
	-screen_name $nickname \
	-email_verified_p 1]

     db_dml update_info "update xo__friend_invite_tokens set friend_id=:user_id where invite_id=:inv_id"
   }
}

rp_internal_redirect /packages/account-manager/tmpl/join-done