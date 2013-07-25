ad_page_contract {
    @author Neophytos Demetriou
} {
    id:integer,notnull
}

set pathexp [list "User [ad_conn user_id]"]
set o [::wiki::Page new -pathexp ${pathexp} -mixin ::db::Object]

${o} set id ${id}

${o} do self-delete

ad_returnredirect "."


