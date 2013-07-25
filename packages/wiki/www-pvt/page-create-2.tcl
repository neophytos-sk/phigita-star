ad_page_contract {

    @author Neophytos Demetriou

} {
    {subject:allhtml,trim ""}
    body:stx,trim
    saveAsDraft:trim,optional
    publishPage:trim,optional
}

set user_id [ad_conn user_id]
set peeraddr [ns_conn peeraddr]

set page_id [::wiki::Page autovalue "User [ad_conn user_id]"]
set revision_id [::wiki::Page_Revision autovalue "User [ad_conn user_id]"]

if {${subject} eq {}} {
    set subject "Page \#${page_id} - Revision \#${revision_id}"
}

if {[exists_and_not_null publishPage]} {
    set shared_p t
} else {
    set shared_p f
}

set pathexp [list "User [ad_conn user_id]"]
set o [::wiki::Page new -mixin ::db::Object -pathexp ${pathexp}]

$o beginTransaction

${o} set id ${page_id}
${o} set title ${subject}
${o} set content ${body}
${o} set shared_p ${shared_p}
${o} set creation_ip ${peeraddr}
${o} set creation_user ${user_id}
${o} set modifying_ip ${peeraddr}
${o} set modifying_user ${user_id}
${o} set latest_revision_id ${revision_id}
${o} set live_revision_id ${revision_id}


${o} do self-insert

set r [::wiki::Page_Revision new -mixin ::db::Object -pathexp ${pathexp}]
${r} set page_id ${page_id}
${r} set id ${revision_id}
${r} set title ${subject}
${r} set content ${body}
${r} set creation_ip ${peeraddr}
${r} set creation_user ${user_id}
${r} set modifying_ip ${peeraddr}
${r} set modifying_user ${user_id}

${r} do self-insert

$o endTransaction

ad_returnredirect ${page_id}
