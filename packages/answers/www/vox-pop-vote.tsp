ad_maybe_redirect_for_registration

ad_page_contract {

    @author Neophytos Demetriou

} {
    parent_id:notnull,integer
    choice:integer,notnull
    {private_p:boolean,notnull "f"}
    {body:stx ""}
    {return_url:trim,notnull ""}
}

set private_p [::util::boolean $private_p]


set pathexp [list "Subsite [ad_conn subsite_id]"]
set question_data [::db::Set new -pathexp $pathexp -type ::Question -where [list "id=[ns_dbquotevalue $parent_id]" "kind=1"] -limit 1]
$question_data load "::Question"
if { [$question_data emptyset_p] } {
    rp_returnnotfound
    return
}
set question [$question_data head]


## Store in Global-scoped table for Poll_Answer
set answer_obj [::Poll_Answer new -mixin ::db::Object -pathexp ${pathexp}]
${answer_obj} set id [::Poll_Answer autovalue {*}${pathexp}]
${answer_obj} set parent_id ${parent_id}
${answer_obj} set body ${body}
${answer_obj} set choice $choice
${answer_obj} set private_p $private_p
${answer_obj} set creation_user [ad_conn user_id]
${answer_obj} set creation_ip [ad_conn peeraddr]
${answer_obj} set modifying_user [ad_conn user_id]
${answer_obj} set modifying_ip [ad_conn peeraddr]
${answer_obj} set live_p t

## Store in User-scoped table for Poll_User_Answer
## This is used for profile/match questions. See Vox Pop tab in user-management package
set user_pathexp [list "User [ad_conn user_id]"]
set user_answer_obj [::Poll_User_Answer new -mixin ::db::Object -pathexp ${user_pathexp}]
$user_answer_obj set id [::Poll_User_Answer autovalue {*}${user_pathexp}]
$user_answer_obj set question_id ${parent_id}
$user_answer_obj set question_subject [$question set subject]
$user_answer_obj set question_body [$question set body]
$user_answer_obj set question_extra [$question set extra]
$user_answer_obj set answer_body [$answer_obj set body]
$user_answer_obj set answer_choice [$answer_obj set choice]
$user_answer_obj set answer_private_p [$answer_obj set private_p]
$user_answer_obj set creation_user [ad_conn user_id]
$user_answer_obj set creation_ip [ad_conn peeraddr]
$user_answer_obj set modifying_user [ad_conn user_id]
$user_answer_obj set modifying_ip [ad_conn peeraddr]
$user_answer_obj set live_p t



${answer_obj} beginTransaction
set conn [${answer_obj} getConn] 

${answer_obj} rdb.self-insert
$conn do "update [$answer_obj info.db.table] set live_p='f' where parent_id=[ns_dbquotevalue $parent_id] and id!=[ns_dbquotevalue [$answer_obj set id]] and creation_user=[ns_dbquotevalue [ad_conn user_id]]"

${user_answer_obj} rdb.self-insert
$conn do "update [$user_answer_obj info.db.table] set live_p='f' where question_id=[ns_dbquotevalue $parent_id] and id!=[ns_dbquotevalue [$user_answer_obj set id]]"

${answer_obj} endTransaction

throw REDIRECT [::util::coalesce $return_url "${parent_id}"]
