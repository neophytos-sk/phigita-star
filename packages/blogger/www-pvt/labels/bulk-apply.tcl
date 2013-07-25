ad_page_contract {
    @author Neophytos Demetriou
} {
    label_id:integer
    bookmark_id:integer,multiple
}


set pathexp [list "User [ad_conn user_id]"]

set o2 [::bm::Label new \
	    -mixin ::db::Object \
	    -pathexp ${pathexp}]

set o3 [::bm::Label_Map new \
	    -mixin ::db::Object \
	    -pathexp ${pathexp}]

${o3} beginTransaction
foreach id ${bookmark_id} {

    ${o3} set label_id ${label_id}
    ${o3} set bookmark_id ${id}

    set jic_sql [subst {
        UPDATE [${o2} info.db.table] set
            cnt_bookmarks = cnt_bookmarks - 1
        WHERE
	    id=[ns_dbquotevalue ${label_id}]
    }]
    ${o3} rdb.self-insert ${jic_sql}

}
${o3} endTransaction

ad_returnredirect ".."