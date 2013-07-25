ad_maybe_redirect_for_registration

ad_page_contract {
    @author Neophytos Demetriou
} {
    content:trim,notnull
    {attachment:naturalnum,multiple ""}
    {public_p:boolean "f"}
    {return_url "."}
}

set content [string range $content 0 1024]

set user_id [ad_conn user_id]
set peeraddr [ad_conn peeraddr]

set o [::echo::Message new -mixin ::db::Object]
$o beginTransaction
$o rdb.self-id
$o set device "web"
$o set public_p $public_p
$o set content $content
$o set attachment $attachment
$o set creation_user $user_id
$o set creation_ip $peeraddr
$o set modifying_user $user_id
$o set modifying_ip $peeraddr
$o rdb.self-insert
$o set pathexp [list "User [ad_conn user_id]"]
$o rdb.self-insert
$o endTransaction
ad_returnredirect ${return_url}