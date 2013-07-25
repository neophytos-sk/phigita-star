ad_page_contract {

    @author Neophytos Demetriou

} {
    {subject:allhtml,trim ""}
    body:stx,trim
    saveAsDraft:trim,optional
    publishPost:trim,optional
}

set user_id [ad_conn user_id]
set peeraddr [ns_conn peeraddr]

set id [::wiki::Page autovalue "User [ad_conn user_id]"]

if {${subject} eq {}} {
    set subject "Page \#${id}"
}

if {[exists_and_not_null publishPost]} {
    set shared_p t
} else {
    set shared_p f
}

set pathexp [list "User [ad_conn user_id]"]
set o [::wiki::Page new -mixin ::db::Object -pathexp ${pathexp}]

${o} set id ${id}
${o} set title ${subject}
${o} set content ${body}
${o} set shared_p ${shared_p}
${o} set creation_ip ${peeraddr}
${o} set creation_user ${user_id}
${o} set modifying_ip ${peeraddr}
${o} set modifying_user ${user_id}

${o} do self-insert

ad_returnredirect ${id}
