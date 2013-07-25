ad_page_contract {
    @author Neophytos Demetriou
} {
    id:integer
    key:trim,notnull
    value:boolean,notnull
} -validate {

    key_in_range -requires {key:trim} {
	array set allowed_keys [list starred_p boolean hidden_p boolean deleted_p boolean shared_p boolean]
	if { ![info exists allowed_keys($key)] } {
	    ad_complain -key key "$key is not in range"
	    return
	}
    }

}
#doc_return 200 text/plain $id

set pathexp [list "User [ad_conn user_id]"]
set o [Content_Item new \
	   -mixin ::db::Object \
	   -pathexp $pathexp \
	   -id $id \
	   -$key $value]

$o do self-update

ns_return 200 text/plain ok-${id}