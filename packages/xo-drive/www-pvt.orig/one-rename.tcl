ad_page_contract {
    @author Neophytos Demetriou
} {
    id:integer
    name:trim,notnull
}

set pathexp [list "User [ad_conn user_id]"]
set o [Content_Item new \
	   -mixin ::db::Object \
	   -pathexp $pathexp \
	   -id $id \
	   -title $name]

$o do self-update

ns_return 200 text/plain ok-${id}-${name}