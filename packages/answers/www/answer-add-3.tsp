ad_page_contract {

    @author Neophytos Demetriou

} {
    parent_id:notnull,integer
    body:notnull,stx
}

ad_maybe_redirect_for_registration


set pathexp [list "Subsite [ad_conn subsite_id]"]
set question_data [::db::Set new \
		       -pathexp $pathexp \
		       -type ::Question \
		       -where [list "id=[ns_dbquotevalue $parent_id]" "kind=0"] \
		       -limit 1]
$question_data load "::Question"
if { [$question_data emptyset_p] } {
    rp_returnnotfound
    return
}
set question [$question_data head]

set answer_obj [::Answer new \
		    -mixin ::db::Object \
		    -pathexp ${pathexp}]


${answer_obj} set parent_id ${parent_id}
${answer_obj} set body ${body}
${answer_obj} set creation_user [ad_conn user_id]
${answer_obj} set creation_ip [ad_conn peeraddr]

${answer_obj} do self-insert

throw REDIRECT "${parent_id}"
