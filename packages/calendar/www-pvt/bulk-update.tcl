ad_page_contract {
    @author Neophytos Demetriou
} {
    id:integer,notnull,multiple
    key:trim,notnull
    {value:trim ""}
} -validate {

    key_in_range -requires {key:trim value:trim} {
	array set allowed_keys [list done_p boolean]
	if { ![info exists allowed_keys($key)] } {
	    ad_complain -key key "$key is not in range"
	    return
	} else {
	    if {![string is $allowed_keys($key) $value]} {
		ad_complain -key value "Invalid value"
		return
	    }
	}
    }

}

set user_id [ad_conn user_id]
set pathexp [list "User ${user_id}"]
set o [::calendar::Task new \
	   -mixin ::db::Object \
	   -pathexp $pathexp \
	   -set id $id \
	   -set $key $value]

$o do bulk-update -pk id

ns_return 200 text/plain ok-${id}