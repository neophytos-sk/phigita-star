ad_page_contract {

    @author Neophytos Demetriou

} {
    id:notnull,integer
    {subject:allhtml ""}
    body:notnull,stx
    old_shared_p:boolean,notnull
    saveDraft:trim,optional
    publishPost:trim,optional
}


set pathexp [list "User [ad_conn user_id]"]
set o [::wiki::Page new \
	    -mixin ::db::Object \
	    -pathexp ${pathexp}]

if {[exists_and_not_null publishPost]} {
    ${o} set shared_p t
} elseif {[exists_and_not_null saveDraft]} {
    ${o} set shared_p f
} else {
    ${o} set shared_p ${old_shared_p}
}

${o} set id ${id}
${o} set title ${subject}
${o} set content ${body}

${o} do self-update

ad_returnredirect "${id}"
