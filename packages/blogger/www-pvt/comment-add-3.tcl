ad_page_contract {

    @author Neophytos Demetriou

} {
    id:notnull,integer
    parent_id:notnull,integer
    comment:notnull,stx
}

ad_maybe_redirect_for_registration

set pathexp [list "User [ad_conn user_id]"]
set bi [Blog_Item_Comment new -pathexp ${pathexp} -mixin ::db::Object]

${bi} set id ${id}
${bi} set parent_id ${parent_id}
${bi} set comment ${comment}
${bi} set shared_p t
${bi} set creation_user [ad_conn user_id]
${bi} set creation_ip [ad_conn peeraddr]

${bi} do self-insert

ad_returnredirect "/my/blog/${parent_id}"
