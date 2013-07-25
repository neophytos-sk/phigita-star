ad_maybe_redirect_for_registration

ad_page_contract {
    @author Neophytos Demetriou
} {
    question_id:integer,notnull
    {return_url "/"}
}

set pathexp [list "User [ad_conn user_id]"]
set answer [::Poll_User_Answer new -mixin ::db::Object -pathexp $pathexp]
$answer set __update(last_update) current_timestamp
$answer set answer_private_p f
$answer rdb.self-update "question_id=[ns_dbquotevalue $question_id] and live_p"

ad_returnredirect $return_url