ad_page_contract {
    @author Neophytos Demetriou
} {
    {q:trim,notnull}
}


set parts [split ${q} {-}]
if { [llength $parts] != 5  } {
    rp_returnnotfound
    return
}

lassign $parts image_id secret_token time object_id size

if { $size ni {s120 s240 s500 s800} } {
    rp_returnnotfound
    return
}


set root [User set id]-[ad_conn ctx_uid]
ns_set put [ns_conn outputheaders] Cache-Control no-cache
ns_set put [ns_conn outputheaders] Pragma no-cache
ns_set put [ns_conn outputheaders] Expires -1

set current_time [clock seconds]

if { ![string is integer -strict $image_id] || ![string is integer -strict $time] } {
    rp_returnnotfound
    return
}



set verify_token [ns_sha1 sEcReT-iMaGe-${root}-${image_id}-${time}-${object_id}]


#ns_log notice "ctx_uid=[ad_conn ctx_uid] root=$root secret_token=$secret_token verify_token=$verify_token ($current_time - $time) = [expr {$current_time - $time}]"
#ns_log notice "q=$q current_time=$current_time time=$time"

if { ($secret_token eq $verify_token) && (${current_time} - ${time} < 600) } {
    set directory /web/data/storage/${root}/${image_id}
    set filename ${directory}/preview/c-${image_id}_p-1-${size}.jpg
    ad_returnfile_background 200 image/jpeg $filename
} else {
    if { $object_id ne {X} && [string is integer -strict $image_id] } {
	set pathexp [list "User [ad_conn ctx_uid]"]
	set data [::db::Set new \
		      -pathexp $pathexp \
		      -select "1" \
		      -type ::Blog_Item \
		      -where [list "id=[ns_dbquotevalue $object_id]" shared_p "body ~* '\{image:${image_id}( |left|center|right)*\}'"] \
		      -limit 1]
	$data load
	if { ![$data emptyset_p] } {
	    ### set directory /web/data/storage/${root}/${image_id}
	    ### set filename ${directory}/preview/c-${image_id}_p-1-${size}.jpg
	    ### ad_returnfile_background 200 image/jpeg $filename

	    set image_prefix ""
	    set root_of_hierarchy $root
	    set new_secret_token [ns_sha1 sEcReT-iMaGe-${root_of_hierarchy}-${image_id}-${current_time}-${object_id}]
	    set item_url "${image_id}-${new_secret_token}-${current_time}-${object_id}"
	    set new_url ${item_url}-${size}
	    ns_return 200 text/html [subst -nocommands {
		<html><head><meta http-equiv="refresh" content="0;url=${new_url}"/></head></html>
	    }]
	} else {
	    ad_returnfile_background 200 image/gif [acs_root_dir]/resources/graphics/noimage.gif
	}
    } else {
	ad_returnfile_background 200 image/gif [acs_root_dir]/resources/graphics/noimage.gif
    }
}
