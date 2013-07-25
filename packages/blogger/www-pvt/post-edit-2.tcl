ad_page_contract {

    @author Neophytos Demetriou

} {
    id:notnull,integer
    {subject:allhtml ""}
    body:notnull,stx
    allow_comments_p:notnull
    old_shared_p:boolean,notnull
    saveDraft:trim,optional
    publishPost:trim,optional
}


set pathexp [list "User [ad_conn user_id]"]
set bi [Blog_Item new \
	-mixin ::db::Object \
	-pathexp ${pathexp}]

if {[exists_and_not_null publishPost]} {
    ${bi} set shared_p t
} elseif {[exists_and_not_null saveDraft]} {
    ${bi} set shared_p f
} else {
    ${bi} set shared_p ${old_shared_p}
}

${bi} set id ${id}
${bi} set title ${subject}
${bi} set body ${body}
${bi} set allow_comments_p ${allow_comments_p}

${bi} do self-update

ad_returnredirect "${id}"
