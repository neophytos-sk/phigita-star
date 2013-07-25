ad_page_contract {
    @author Neophytos Demetriou
} {
    {prefix:trim,notnull ""}
    {name:trim,notnull ""}
}

set pathexp [list "User [ad_conn user_id]"]
set o [Content_Item_Label new -mixin ::db::Object -pathexp $pathexp]

$o beginTransaction
$o rdb.self-id

$o set creation_ip [ad_conn peeraddr]
$o set creation_user [ad_conn user_id]
$o set modifying_ip [ad_conn peeraddr]
$o set modifying_user [ad_conn user_id]


set name [::util::coalesce $name "${prefix} [$o set id]"]
$o set name $name
package require crc32
$o set name_crc32 [crc::crc32 -format %d ${name}]

$o rdb.self-insert
$o endTransaction


ns_return 200 text/plain \{id:[$o set id],name:'$name'\}