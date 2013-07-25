ad_page_contract {
    @author Neophytos Demetriou
} {
    phone:trim,notnull
}

# validate phone here
set phone [string map {{ } {}} $phone]
if { ![regexp -- {^[+][1-9][0-9]+$} $phone] } {
    doc_return 200 text/plain "Invalid phone number"
    return
}

set user_id [ad_conn user_id]
set peeraddr [ad_conn peeraddr]
set token [::echo::getDeviceToken $user_id $phone]

set o [::echo::Device new -mixin ::db::Object]
$o set device_guid $phone
$o set device_user $user_id
$o set device_token $token

$o set creation_user $user_id
$o set creation_ip $peeraddr

$o set modifying_user $user_id
$o set modifying_ip $peeraddr

$o do self-insert

ad_returnredirect .