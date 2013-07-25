ad_page_contract {
    @author Neophytos Demetriou
} {
    id:integer
}

set pathexp [list "User [ad_conn user_id]"]
set o [Content_Item new \
	   -mixin ::db::Object \
	   -pathexp $pathexp \
	   -id $id -proc rdb.self-delete {} {

	       set result [next]
	       my instvar pathexp id

	       set list ""
	       foreach item $pathexp {
		   foreach {className instance_id} $item break
		   lappend list [$className set id]-${instance_id}
	       }

	       set directory /web/data/storage/
	       append directory [join $list .]/ ;# [User set id]-[ad_conn user_id]
	       append directory $id

	       file delete -force -- $directory

	       return $result
	   }]

$o do self-delete

ns_return 200 text/plain ok-${id}