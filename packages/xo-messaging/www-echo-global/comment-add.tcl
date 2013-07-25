ad_maybe_redirect_for_registration

ad_page_contract {
    @author Neophytos Demetriou
} {
    parent_id:integer,notnull
    content:trim,notnull
}

#set context_uid [ad_conn ctx_uid]
#set pathexp [list "User $context_uid"]
#-pathexp $pathexp 

set qualifier [::xo::db::qualifier id eq $parent_id]
set data [::db::Set new -select "id creation_user" -type ::echo::Message -where [list $qualifier] -limit 1]
$data load

if { [$data emptyset_p] } {
    rp_returnnotfound
    return
}

set m [$data head]

set user_id [ad_conn user_id]
set peeraddr [ad_conn peeraddr]

set pathexp [list "User [$m set creation_user]"]
set o [::echo::Message_Comment new -mixin ::db::Object -pathexp $pathexp]
$o set parent_id $parent_id
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
${conn} do "update xo.xo__echo__message set cnt_comment=cnt_comment+1,last_comment=[ns_dbquotevalue $commentDict] where ${qualifier}"
${conn} do "update xo__u[$m set creation_user].xo__echo__message set cnt_comment=cnt_comment+1,last_comment=[ns_dbquotevalue $commentDict] where ${qualifier}"

set pool [$conn pool]
::xo::db::touch ${pool}.xo.xo__echo__message
::xo::db::touch ${pool}.xo__u[$m set creation_user].xo__echo__message 

$o rdb.self-insert
$o endTransaction

bg_sendOneWay "touch main.xo.xo__echo__message"

#set context_username [ad_conn context_username]
#ad_returnredirect /~${context_username}/echo/${parent_id}

ad_returnredirect http://www.phigita.net/
