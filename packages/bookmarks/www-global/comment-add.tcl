ad_maybe_redirect_for_registration

ad_page_contract {
    @author Neophytos Demetriou
} {
    q:trim,notnull
    content:trim,notnull
}

set qualifier [::xo::db::qualifier url_sha1 eq $q]
set data [::db::Set new -select "url_sha1" -type ::sw::agg::Url -where [list $qualifier] -limit 1]
$data load

if { [$data emptyset_p] } {
    rp_returnnotfound
    return
}

set user_id [ad_conn user_id]
set peeraddr [ad_conn peeraddr]

set o [::bm::Bookmark_Comment new -mixin ::db::Object]
$o set ancestor $q
$o set content $content
$o set screen_name [ad_conn screen_name]
$o set creation_user $user_id
$o set creation_ip $peeraddr
$o set modifying_user $user_id
$o set modifying_ip $peeraddr

#set u [$data head]
#$u set pathexp ""
#$u mixin ::db::Object

set commentDict [$o toDict true creation_dt [dt_systime]]

$o beginTransaction
set conn [$o getConn]
$conn do "update xo.xo__sw__agg__url set cnt_comment=cnt_comment+1,last_comment=[ns_dbquotevalue $commentDict],last_comment_date=current_timestamp where ${qualifier}"

::xo::db::touch [$conn pool].xo.xo__sw__agg__url

$o rdb.self-insert
$o endTransaction

bg_sendOneWay "touch main.xo.xo__sw__agg__url"

ad_returnredirect ./url/${q}
