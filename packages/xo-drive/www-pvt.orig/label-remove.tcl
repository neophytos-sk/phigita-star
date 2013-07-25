ad_page_contract {
    @author Neophytos Demetriou
} {
    id:integer
}

set pathexp [list "User [ad_conn user_id]"]
set folder [Content_Item_Label new \
		-mixin ::db::Object \
		-pathexp $pathexp \
		-id $id]

set o [Content_Item new \
	   -mixin ::db::Object \
	   -pathexp $pathexp]

$folder beginTransaction
[$o getConn] do "update [$o info.db.table] set tags_ia=case when coalesce(icount(tags_ia),0)=1 then null else tags_ia-[ns_dbquotevalue \{$id\}] end where tags_ia @ [ns_dbquotevalue \{${id}\}]::integer\[\]"
$folder rdb.self-delete
$folder endTransaction

ns_return 200 text/plain ok-${id}