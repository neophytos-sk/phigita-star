ad_page_contract {

    @author Neophytos Demetriou

} {
    id:notnull,integer
    {subject:allhtml ""}
    body:notnull,stx
    old_shared_p:boolean,notnull
    saveDraft:trim,optional
    publishPage:trim,optional
}

set peeraddr [ad_conn peeraddr]
set user_id [ad_conn user_id]

set page_id $id
set revision_id [::wiki::Page_Revision autovalue "User [ad_conn user_id]"]


set pathexp [list "User [ad_conn user_id]"]



set r [::wiki::Page_Revision new -mixin ::db::Object -pathexp ${pathexp}]
$r beginTransaction

${r} set page_id ${page_id}
${r} set id ${revision_id}
${r} set title ${subject}
${r} set content ${body}
${r} set creation_ip ${peeraddr}
${r} set creation_user ${user_id}
${r} set modifying_ip ${peeraddr}
${r} set modifying_user ${user_id}

${r} do self-insert


set o [::wiki::Page new \
	    -mixin ::db::Object \
	    -pathexp ${pathexp}]

if {[exists_and_not_null publishPage]} {
    ${o} set shared_p t
} elseif {[exists_and_not_null saveDraft]} {
    ${o} set shared_p f
} else {
    ${o} set shared_p ${old_shared_p}
}
${o} set live_revision_id $revision_id
${o} set latest_revision_id $revision_id
${o} set id ${id}
${o} set title ${subject}
${o} set content ${body}

${o} do self-update

$r endTransaction

ad_returnredirect "${id}"
