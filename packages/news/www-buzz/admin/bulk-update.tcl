ad_page_contract {
    @author Neophytos Demetriou
} {
    url:trim,notnull,multiple
    key:trim,notnull
    {value:trim ""}
} -validate {

    key_in_range -requires {key:trim value:trim} {
	array set allowed_keys [list active_p boolean]
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


set o [::buzz::Feed new \
	   -mixin ::db::Object \
	   -pool newsdb \
	   -set url $url \
	   -set $key $value]

$o do bulk-update -pk url

ns_return 200 text/plain ok-${url}