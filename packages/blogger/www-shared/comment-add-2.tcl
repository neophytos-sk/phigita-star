ad_page_contract {

    @author Neophytos Demetriou

} {
    parent_id:notnull,integer
    comment:notnull,stx
}

ad_maybe_redirect_for_registration

set context_user_id [ad_conn ctx_uid]
set pathexp [list "User ${context_user_id}"]

set id [Blog_Item_Comment autovalue "User ${context_user_id}"]

set bi [Blog_Item_Comment new -pathexp ${pathexp} -mixin ::db::Object]

${bi} set id ${id}
${bi} set parent_id ${parent_id}
${bi} set comment ${comment}
${bi} set shared_p t
${bi} set creation_user [ad_conn user_id]
${bi} set creation_ip [ad_conn peeraddr]

${bi} do self-insert

ad_returnredirect "/~[ad_conn context_username]/blog/${parent_id}"
