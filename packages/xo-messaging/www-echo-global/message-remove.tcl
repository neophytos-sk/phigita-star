ad_maybe_redirect_for_registration

ad_page_contract {
    @author Neophytos Demetriou 
} {
    id:integer,notnull
    {return_url "."}
}

if { [catch {
    set o [::echo::Message new -mixin ::db::Object]
    $o beginTransaction
    $o set id $id
    $o do self-load
    $o do self-delete "id=$id AND creation_user=[ad_conn user_id]"
    $o set pathexp [list "User [ad_conn user_id]"]
    
    ## keep the comments as orphans -- they are not his/her to delete
    ## [$o getConn] do "delete from xo__u[ad_conn user_id].xo__echo__message_comment where parent_id=[ns_dbquotevalue $id]"

    $o do self-delete "id=$id AND creation_user=[ad_conn user_id]"
    $o endTransaction
    $o destroy
} errmsg] } {
    ns_log notice "(echo: message-remove.tcl) failed errmsg=$errmsg"
}

ad_returnredirect $return_url
