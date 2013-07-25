ad_page_contract {

    @author Neophytos Demetriou

} {
    id:notnull,integer
    shared_p:boolean,notnull
}

set pathexp [list "User [ad_conn user_id]"]
set bi [::Blog_Item new \
	    -mixin ::db::Object \
	    -pathexp ${pathexp}]

${bi} set id ${id}
${bi} set shared_p ${shared_p}

${bi} do self-update



ad_returnredirect ${id}
