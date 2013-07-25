ad_page_contract {
    @author Neophytos Demetriou
} {
    label_id:integer,notnull
    object_id:integer,notnull
}

set pathexp [list "User [ad_conn user_id]"]
set o1 [Blog_Item_Label_Map new \
	    -mixin ::db::Object \
	    -pathexp ${pathexp}]

set o2 [::Blog_Item_Label new \
            -mixin ::db::Object \
            -pathexp ${pathexp}]

${o1} beginTransaction
set sql1 [subst {
    delete from [${o1} info.db.table] where label_id=[ns_dbquotevalue ${label_id}] and object_id=[ns_dbquotevalue ${object_id}]
}]
set conn1 [${o1} getConn]
${conn1} do ${sql1}


# HERE: Replace the following with a ::db::Set that uses an instproc to update.
set sql2 [subst {
    update [${o2} info.db.table] set
        cnt_entries = cnt_entries - 1
    where
        id=[ns_dbquotevalue ${label_id}]

}]
set conn2 [${o2} getConn]
${conn2} do ${sql2}

${o1} endTransaction


ad_returnredirect "../${object_id}"
