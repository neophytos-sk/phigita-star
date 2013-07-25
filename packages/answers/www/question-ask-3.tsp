ad_page_contract {

    @author Neophytos Demetriou

} {
    subject:notnull,allhtml
    body:notnull,stx
    anonymous_p:notnull,trim
}

ad_maybe_redirect_for_registration

set question_obj [Question new -volatile_p yes -pathexp "Subsite [ad_conn subsite_id]" -mixin DB_Object]

set id [Question autovalue "Subsite [ad_conn subsite_id]"]
${question_obj} set id ${id}
${question_obj} set anonymous_p ${anonymous_p}
${question_obj} set subject ${subject}
${question_obj} set body ${body}
${question_obj} set creation_user [ad_conn user_id]
${question_obj} set creation_ip [ad_conn peeraddr]

${question_obj} Save

${question_obj} destroy

throw REDIRECT "${id}"
