ad_page_contract {
    @author Neophytos Demetriou
} {
    token:notnull,trim
    password_1:trim
    password_2:trim
}


lassign [split ${token} -] auth_id auth_token

set email [::xo::db::value -default "" -statement_name get_email "select email from cc_users where user_id=[ns_dbquotevalue $auth_id]"]

set exists_p [::xo::db::value -default 0 -statement_name check_token "select 1 from xo__auth_secret_tokens where auth_id=[ns_dbquotevalue $auth_id] and auth_token=[ns_dbquotevalue $auth_token]"]

if { $email eq {} || !$exists_p } {

    t "It seems that you have followed an expired link. If you still want to change your password, then please start over at the "

    a -href "forgotten-password" {
        t "Forgotten Password Self-Service"
    }
    t " page."
    return
}

set exception_text ""
set exception_count 0
                                                                           
if { ![info exists password_1] || [empty_string_p $password_1] } {
    append exception_text "<li>You need to type in a password\n"
    incr exception_count
}
                                                                                
if { ![info exists password_2] || [empty_string_p $password_2] } {
    append exception_text "<li>You need to confirm the password that you typed.
 (Type the same thing again.) \n"
    incr exception_count
}


if { [string compare $password_2 $password_1] != 0 } {
    append exception_text "<li>Your passwords don't match!  Presumably, you made a typo while entering one of them.\n"
    incr exception_count
}
                                                                                
                                                                                
if { $exception_count > 0 } {
    t "Problem with your input:"
    p
    ul {
	t -disableOutputEscaping $exception_text
    }    
    t "Please go back using your browser's BACK button and try again."
    return
}
                                                                                
                                                                                
if [catch {ad_change_password $auth_id $password_1} errmsg] {
    ad_return_error "Ouch!"  "Wasn't able to change your password for
unknown reasons.  This is probably our fault. Please contact the
system administrator."
} else {
    db_dml delete_token "delete from xo__auth_secret_tokens where auth_id=[ns_dbquotevalue $auth_id]"
}

tmpl::simple -title "Forgotten Password Self-Service" {
    h2 {
	t "Password Changed Successfully"
    }
    t "Click "
    a -href ".?email=${email}" {
	t "here"
    }
    t " to login using your new password."
}
