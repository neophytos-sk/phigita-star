ad_page_contract {
    @author Neophytos Demetriou
} {
    id:integer
    name:trim
    {return_url "."}
}


set user_id [ad_conn user_id]
set pathexp [list "User ${user_id}"]
set o [::Blog_Item_Label new \
	   -mixin ::db::Object \
	   -pathexp ${pathexp} \
	   -id ${id}]

${o} do self-delete

set comment {
    ${o} beginTransaction
    ${o} rdb.self-load
    ${o} rdb.self-delete
    set swu [::sw::agg::Url new -mixin ::db::Object]
    set conn2 [${swu} getConn]
    set sql2 "update [${swu} info.db.table] set label_crc32_arr=label_crc32_arr-[${o} quoted name_crc32]::int where max_sharing_user_id=[ns_dbquotevalue ${user_id}] and label_crc32_arr @ [ns_dbquotevalue "\{[${o} set name_crc32]\}"]"
    ns_log notice ${sql2}
    ${conn2} do ${sql2}
    ${o} endTransaction
}

set status OD
set response [list]
lappend response "Label-ID: ${id}"
lappend response "Label-Name: ${name}"
lappend response "Info-Text: Label \"${name}\" has been deleted"
lappend response "S: ${status}"


doc_return 200 text/plain [join ${response} \n]
