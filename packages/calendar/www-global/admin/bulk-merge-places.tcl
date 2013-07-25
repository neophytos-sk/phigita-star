ad_page_contract {
    @author Neophytos Demetriou
} {
    id:integer,multiple,notnull
}


set ids [lsort $id]

set keep_place_id [lindex $ids 0]
set ids [lrange $ids 1 end]

set o [::agenda::Venue new \
	   -mixin ::db::Object \
	   -pool agendadb]

$o beginTransaction

set update_sql "update xo.xo__agenda__venue set place_id=${keep_place_id} where place_id in [::util::sqllist $ids]"
[$o getConn] do $update_sql

set delete_sql "delete from xo.xo__agenda__place where id in [::util::sqllist $ids]"
[$o getConn] do $delete_sql

$o endTransaction


ns_return 200 text/html [::util::map2json b:success true]