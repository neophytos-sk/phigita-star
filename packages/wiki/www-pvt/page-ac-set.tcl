ad_page_contract {

    @author Neophytos Demetriou

} {
    id:notnull,integer
    shared_p:boolean,notnull
}

set pathexp [list "User [ad_conn user_id]"]
set o [::wiki::Page new \
	    -mixin ::db::Object \
	    -pathexp ${pathexp}]

${o} set id ${id}
${o} set shared_p ${shared_p}

${o} do self-update



ad_returnredirect "."
