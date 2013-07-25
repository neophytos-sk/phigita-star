ad_page_contract {
    @author Neophytos Demetriou
} {
    id:integer
    shared_p:boolean
}

set pathexp [list "User [ad_conn user_id]"]
set o [Content_Item new \
	   -mixin ::db::Object \
	   -pathexp $pathexp \
	   -id $id \
	   -shared_p $shared_p]

$o do self-update

ns_return 200 text/plain ok-${id}-${shared_p}