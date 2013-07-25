ad_page_contract {

    @author Neophytos Demetriou

} {
    subject:notnull,allhtml
    {body:trim,stx ""}
    anonymous_p:notnull,trim
    choice:multiple,trim
}

set choices [lsearch -all -inline -not $choice {}]
if { [llength $choices] < 2 } {
    doc_return 200 text/plain "You must provide at least two choices! Go back and edit your vox pop."
    return
}

ad_maybe_redirect_for_registration
set presentation_type 0 ;# multiple choice (radio buttons, single answer by user)


set pathexp [list "Subsite [ad_conn subsite_id]"]
set question_obj [::Question new -mixin ::db::Object -pathexp $pathexp]

set id [Question autovalue {*}$pathexp]
${question_obj} set id ${id}
${question_obj} set anonymous_p ${anonymous_p}
${question_obj} set subject ${subject}
${question_obj} set body ${body}
${question_obj} set creation_user [ad_conn user_id]
${question_obj} set creation_ip [ad_conn peeraddr]


${question_obj} set kind 1
${question_obj} set extra.choices $choices
${question_obj} set extra.presentation_type $presentation_type


set poll_obj [::Poll new -mixin ::db::Object -pathexp $pathexp]
$poll_obj set id $id
$poll_obj set anonymous_p $anonymous_p
$poll_obj set subject $subject
$poll_obj set body $body
$poll_obj set choices $choices
$poll_obj set presentation_type $presentation_type

$poll_obj set creation_user [ad_conn user_id]
$poll_obj set creation_ip [ad_conn peeraddr]
$poll_obj set modifying_user [ad_conn user_id]
$poll_obj set modifying_ip [ad_conn peeraddr]



${question_obj} beginTransaction
${question_obj} rdb.self-insert
${poll_obj} rdb.self-insert

set i 0
set choice_obj [::Poll_Choice new -mixin ::db::Object -pathexp $pathexp]
foreach label $choices {
    $choice_obj set id [::Poll_Choice autovalue {*}$pathexp]
    $choice_obj set parent_id $id
    $choice_obj set label $label
    $choice_obj set sort_order [incr i]
    $choice_obj set creation_user [ad_conn user_id]
    $choice_obj set creation_ip [ad_conn peeraddr]
    $choice_obj set modifying_user [ad_conn user_id]
    $choice_obj set modifying_ip [ad_conn peeraddr]

    $choice_obj rdb.self-insert
}
${question_obj} endTransaction

${question_obj} destroy

throw REDIRECT "${id}"
