ad_page_contract {

    @author Neophytos Demetriou

} {
    nickname:trim,notnull
    {return_url ""}
}

set nickname [string tolower ${nickname}]

if {[regexp {[^a-z0-9_]} ${nickname} match]} {
    tmpl::master -title "Problem with your input: Illegal characters in nickname" {
	t "Your nickname ${nickname} contains illegal characters. Please go back using your browser's back button and try again. Allowed characters are: a-z0-9_"
    }
    return
}
if {[string length ${nickname}] > 20} {
    tmpl::master -title "Problem with your input: Nickname is too big" {
	t -disableOutputEscaping "The length of your nickname '<b>${nickname}</b>' is more than the maximum allowed which is 20 chars. Please go back using your browser's back button and try again."
    }
    return
}
if {[string length ${nickname}] < 5} {
    tmpl::master -title "Problem with your input: Nickname is too small" {
	t -disableOutputEscaping "The length of your nickname '<b>${nickname}</b>' is less than the minimum allowed which is 5 chars. Please go back using your browser's back button and try again."
    }
    return
}

set user_id [ad_conn user_id]

set sn_unique_p [db_string screen_name_unique_count "
    select count(*) from users where screen_name = :nickname and user_id != :user_id"]


if {$sn_unique_p != 0} {
    tmpl::master {
	t "The screen name you have selected is already taken."
    }
} else {


    db_1row get_user_info "select email,screen_name,password,url,second_to_last_visit from cc_users where user_id=:user_id"

    if {[string equal ${screen_name} ""]} {
	db_dml update_nickname "update users set screen_name=:nickname where user_id=:user_id"
    }

    ad_returnredirect ${return_url}

}
