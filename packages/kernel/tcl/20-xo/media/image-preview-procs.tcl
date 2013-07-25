namespace eval ::xo::media {;}

ad_proc ::xo::media::preview_image_url {
    -user_id
    -object_id 
    {-container_object_id "X"}
    {-size "120"}
    {-image_prefix ""}
} {

    if { $image_prefix eq {} } {
	set user_info [::xo::kit::get_user $user_id]
	set screen_name [$user_info set screen_name]
	set image_prefix "/~${screen_name}/media/preview/"
    }

    set root [User set id]-${user_id}
    set seconds [clock seconds]
    set secret_token [ns_sha1 sEcReT-iMaGe-${root}-${object_id}-${seconds}-${container_object_id}]

    set image_url "${image_prefix}${object_id}-${secret_token}-${seconds}-${container_object_id}-s${size}"
    return $image_url

}