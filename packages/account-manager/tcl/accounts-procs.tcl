namespace eval accounts {;}

ad_proc accounts::one-create {
    {-email ""}
    {-first_name ""}
    {-last_name ""}
    {-screen_name ""}
    {-password ""}
    {-question ""}
    {-answer ""}
    {-member_state ""}
    {-email_verified_p ""}
    {-url ""}
} { 
    @author Neophytos Demetriou
} {

    set user_id [db_nextval acs_object_id_seq]
    set peeraddr [ad_conn peeraddr]
    set salt [sec_random_token]
    set hashed_password [ns_sha1 "$password$salt"]

    db_transaction {
	db_exec_plsql add_user {
	    select acs__add_user(
                         :user_id,
                         'user',
                         now(),
                         null,
                         :peeraddr,
                         :email,
                         :url,
                         :first_name,
                         :last_name,
                         :hashed_password,
                         :salt,
                         :question,
                         :answer,
                         :screen_name,
                         :email_verified_p,
                         :member_state);
	}
	db_dml update_users "update users set member_state=:member_state where user_id=:user_id"
    }

    return ${user_id}
}

ad_proc accounts::trusted_member_p {
    {-user_id ""}
} {
    @author Neophytos Demetriou
} {
    if {[string equal ${user_id} 0]} {
	return 0
    }

    if {[db_0or1row trusted_member_check "select 1 from cc_users where user_id=:user_id and creation_date < CURRENT_TIMESTAMP-'2 months'::interval and n_sessions>30"]} {
	return 1
    } else {
	return 0
    }
 
}

ad_proc accounts::trusted_member_check {} {
    @author Neophytos Demetriou
} {
    set user_id [ad_conn user_id]
    set result [util_memoize "accounts::trusted_member_p -user_id ${user_id}" 3600]

    if {${result}} {
	return
    } else {
	ad_return_redirect /
    }

}

ad_proc accounts::invitation_widget {} {
    @author Neophytos Demetriou
} {
    set user_id [ad_conn user_id]

    set result [util_memoize "accounts::trusted_member_p -user_id ${user_id}" 3600]

    if {${result}} {
	#b { t -disableOutputEscaping "&#183;&nbsp;" }
	    a -class fl -href "http://my.phigita.net/friend-invite" {
		t [mc Invite_a_friend "Invite a friend"]
	    }
	set comment {	t -disableOutputEscaping "<sup>&nbsp;[util_memoize "db_string all_invitations {select count(1) from xo__friend_invite_tokens}" 600] <small>[mc thanks thanks]!</small></sup>" }
    }
}