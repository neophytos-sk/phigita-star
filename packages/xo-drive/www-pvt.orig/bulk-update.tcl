ad_page_contract {
    @author Neophytos Demetriou
} {
    id:integer,multiple
    key:trim,notnull
    {value:trim ""}
} -validate {

    key_in_range -requires {key:trim value:trim} {
	array set allowed_keys [list starred_p boolean hidden_p boolean deleted_p boolean shared_p boolean label_id integer]
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


set pathexp [list "User [ad_conn user_id]"]
set o [Content_Item new \
	   -mixin ::db::Object \
	   -pathexp $pathexp \
	   -id $id \
	   -set $key $value]

if { $key eq {label_id} } {
    #$o unset label_id
    $o set tags_ia \{${value}\}
    if { $value ne {} } {
	$o set __update(tags_ia) "case when coalesce(idx(tags_ia,${value}),0)=0 then tags_ia || ${value} else tags_ia end"
    } else {
	$o set __reset(tags_ia) "" ;# needed for aggregators
    }
    ### $o set __update(tags_ia) "uniq(sort(tags_ia || ${value}))"
}


### Rule 1
if { $key eq {deleted_p} && $value eq {t} } {
    $o set hidden_p f
    $o set shared_p f
}
### Rule 2
if { $key eq {hidden_p} && $value eq {t} } {
    $o set deleted_p f
    $o set shared_p f
}
### Rule 3
if { $key eq {shared_p} && $value eq {t} } {
    $o set deleted_p f
    $o set hidden_p f
}

$o do bulk-update

ns_return 200 text/plain ok-${id}