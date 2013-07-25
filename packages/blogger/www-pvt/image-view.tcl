ad_page_contract {
    @author Neophytos Demetriou
} {
    {q:trim,notnull}
}

set parts [split ${q} {-}]
if { [llength $parts] != 3 } {
    rp_returnnotfound
    return
}

#### PRIVATE PRIVATE PRIVATE ONLY 

set root [User set id]-[ad_conn user_id]
foreach {identifier secret_token time} $parts break


set current_time [clock seconds]

if { ![string is integer -strict $identifier] || ![string is integer -strict $time] } {
    rp_returnnotfound
    return
}
if { ${current_time} - ${time} > 30 } {
    ad_returnfile_background 200 image/gif [acs_root_dir]/www/graphics//noimage.gif
    return
}


set verify_token [ns_sha1 sEcReT-iMaGe-${root}-${identifier}-${time}]



if { $secret_token eq $verify_token } {
    set directory /web/data/storage/${root}/${identifier}
    set filename ${directory}/preview/c-${identifier}_p-1-s240.jpg
    ad_returnfile_background 200 image/jpeg $filename
} else {
    ad_returnfile_background 200 image/gif [acs_root_dir]/www/graphics//noimage.gif
}
