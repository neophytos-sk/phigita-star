ad_page_contract {
    @author Neophytos Demetriou
} {
    id:integer
}


set pathexp [list "User [ad_conn user_id]"]
set o1 [::bm::Bookmark new \
	   -mixin ::db::Object \
	   -pathexp ${pathexp} \
	   -id ${id}]

set o2 [::bm::Label new \
	    -mixin ::db::Object \
	    -pathexp ${pathexp}]

set o3 [::bm::Label_Map new \
	    -mixin ::db::Object \
	    -pathexp ${pathexp}]

${o1} beginTransaction

set table_exists_p [${o3} info.db.table_exists_p]
if {${table_exists_p}} {
    # HERE: Replace the following with a ::db::Set that uses an instproc to update.
    set sql [subst {
	update [${o2} info.db.table] set
        cnt_bookmarks = cnt_bookmarks - 1
	from [${o3} info.db.table] as bmlm
	where 
        id=bmlm.label_id and 
        bmlm.bookmark_id=[${o1} quoted id]
        
    }]
    set conn [${o2} getConn]
#    ns_log notice sql=${sql}
    ${conn} do ${sql}
} 

${o1} rdb.self-load
${o1} rdb.self-delete
${o1} endTransaction

ad_returnredirect "."