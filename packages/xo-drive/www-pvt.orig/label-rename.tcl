ad_page_contract {
    @author Neophytos Demetriou
} {
    id:integer
    oldValue:trim,notnull
    newValue:trim,notnull
}

package require crc32
set name_crc32 [crc::crc32 -format %d $newValue]

set pathexp [list "User [ad_conn user_id]"]
set o [Content_Item_Label new \
	   -mixin ::db::Object \
	   -pathexp $pathexp \
	   -id $id \
	   -name $newValue \
	   -name_crc32 ${name_crc32}]

$o do self-update

ns_return 200 text/plain ok-${id}