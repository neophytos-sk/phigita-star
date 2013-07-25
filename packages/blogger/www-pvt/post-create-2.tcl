ad_page_contract {

    @author Neophytos Demetriou

} {
    {subject:allhtml,trim ""}
    body:notnull,stx
    allow_comments_p:notnull
    saveAsDraft:trim,optional
    publishPost:trim,optional
}

set id [Blog_Item autovalue "User [ad_conn user_id]"]

if {${subject} eq {}} {
    set subject "Post \#${id}"
}

if {[exists_and_not_null publishPost]} {
    set shared_p t
} else {
    set shared_p f
}

set pathexp [list "User [ad_conn user_id]"]
set bi [Blog_Item new -mixin ::db::Object -pathexp ${pathexp}]

${bi} set id ${id}
${bi} set title ${subject}
${bi} set body ${body}
${bi} set shared_p ${shared_p}
${bi} set allow_comments_p ${allow_comments_p}

${bi} do self-insert

ad_returnredirect ${id}
