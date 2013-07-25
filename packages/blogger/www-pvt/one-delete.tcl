ad_page_contract {
    @author Neophytos Demetriou
} {
    id:integer,notnull
}

set pathexp [list "User [ad_conn user_id]"]
set bi [::Blog_Item new -pathexp ${pathexp} -mixin ::db::Object]

${bi} set id ${id}


set o2 [::Blog_Item_Label new \
            -mixin ::db::Object \
            -pathexp ${pathexp}]

set o3 [::Blog_Item_Label_Map new \
            -mixin ::db::Object \
            -pathexp ${pathexp}]

${bi} beginTransaction
${bi} rdb.self-load

set table_exists_p [${o3} info.db.table_exists_p]
if {${table_exists_p}} {
    # HERE: Replace the following with a ::db::Set that uses an instproc to update.
    set table [${o2} info.db.table]
    set sql [subst {
        update ${table} set
            cnt_entries = cnt_entries - 1
	   ,cnt_shared_entries=cnt_shared_entries - (case when [${bi} quoted shared_p] then 1 else 0 end)
        from [${o3} info.db.table] as bilm
        where
        id=bilm.label_id and
        bilm.object_id=[${bi} quoted id]

    }]
    set conn [${o2} getConn]

    ${conn} do ${sql}
    ::xo::db::touch [$conn pool].${table}
}

${bi} rdb.self-delete
::xo::db::touch main.xo.xo__sw__agg__most_recent_objects
${bi} endTransaction


ad_returnredirect "."


