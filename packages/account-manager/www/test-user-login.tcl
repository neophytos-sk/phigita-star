ad_page_contract {

    Accepts an email from the user and attempts to log the user in.

    @author Multiple
    @cvs-id $Id: user-login.tcl,v 1.1.1.1 2002/11/22 09:47:32 nkd Exp $
} {
    email:notnull
    {return_url [ad_pvt_home]}
    password:notnull
    {persistent_cookie_p 0}
    token_id
    time
    hash
}


# Security check to prevent the back button exploit.

set token [sec_get_token $token_id]
set computed_hash [ns_sha1 "$time$token_id$token"]

if { [string compare $hash $computed_hash] != 0 } {
    # although this technically is not an expired login, we'll
    # just use it anyway.
    ad_returnredirect "login-expired"
    return
} elseif { $time < [ns_time] - [ad_parameter -package_id [ad_acs_kernel_id] LoginExpirationTime security 600] } {
    ad_returnredirect "login-expired"
    return
}

# Obtain the user ID corresponding to the provided email address.

set email [string tolower $email]

if { ![db_0or1row user_login_user_id_from_email {
    select user_id, member_state, email_verified_p
    from cc_users
    where email = :email}] } {

    # The user is not in the database. Redirect to user-new.tcl so the user can register.
    ad_set_client_property -persistent "f" register password $password
    ad_returnredirect "user-new?[ad_export_vars { email return_url persistent_cookie_p }]"

    return
}


db_release_unused_handles

switch $member_state {
    "approved" {
	if { $email_verified_p == "f" } {
	    ad_returnredirect "awaiting-email-verification?user_id=$user_id"
	    return
	}
	if { [ad_check_password $user_id $password] } {
	    # The user has provided a correct, non-empty password. Log
	    # him/her in and redirect to return_url.
	    ad_user_login -forever=$persistent_cookie_p $user_id
set forever_p $persistent_cookie_p
if { $forever_p } {
        set max_age inf
    } else {
	# ad_user_login cookie will live for as long as the maximum login time
        set max_age [sec_login_timeout]
    }
foreach domain {
	.phigita.net
	.news.phigita.net
	.buzz.phigita.net
} {
	     ad_set_signed_cookie -domain $domain -max_age $max_age  -secure f  ad_user_login  "$user_id,[ns_time]"
}
	    ad_returnredirect $return_url
	    return
	}
    }
    "banned" { 
	ad_returnredirect "403" 
	#ad_returnredirect "banned-user?user_id=$user_id" 
	return
    }
    "deleted" {  
	ad_returnredirect "deleted-user?user_id=$user_id" 
	return
    }
    "rejected" {
	ad_returnredirect "awaiting-approval?user_id=$user_id"
	return
    }
    "needs approval" {
	ad_returnredirect "awaiting-approval?user_id=$user_id"
	return
    }
    default {
	ns_log Warning "Problem with registration state machine on user-login.tcl"
	ad_return_error "Problem with login" "There was a problem authenticating the account: $user_id. Most likely, the database contains users with no user_state."
	return
    }
}

# The user is in the database, but has provided an incorrect password.
ad_returnredirect "bad-password?user_id=${user_id}&return_url=${return_url}"
