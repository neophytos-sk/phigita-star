ad_page_contract {
    @author Neophytos Demetriou
} {
    return_url:trim
    id:integer
    shared_p:boolean
}

set pathexp [list "User [ad_conn user_id]"]
set c [::Blog_Item_Comment new -pathexp ${pathexp} -mixin ::db::Object -id ${id} -shared_p ${shared_p}]
${c} do self-update

ad_returnredirect ${return_url}