ad_page_contract {
    @author Neophytos Demetriou
} {
    {tab "home"}
}

set user_id [ad_verify_and_get_user_id]

set user_exists_p [db_0or1row pvt_home_user_info "
    select first_names, last_name, email, url, second_to_last_visit,
    coalesce(screen_name,'&lt none set up &gt') as screen_name
    from cc_users 
    where user_id=:user_id
"]



if { ! $user_exists_p } {
    if {$user_id == 0} {
        ad_redirect_for_registration
        return
    }
    ad_return_error "Account Unavailable" "Δεν βρήκαμε τα στοιχεία σου (χρήστης #$user_id) ανάμεσα στους έγκυρους χρήστες.  Πιθανό ο λογαριασμός σου να έχει διαγραφεί για κάποιο λόγο.  Μπορείς να κάνεις <a href=\"/register/logout\">logout</a> και να ξαναδοκιμάσεις."
    return
}

if { ![empty_string_p $first_names] || ![empty_string_p $last_name] } {
    set full_name "$first_names $last_name"
} else {
    set full_name "Ανώνυμος"
}

template::multirow create tabs name key url 
foreach loop_tab {
    { Home home }
} {
#    { Σταθμοί channels }
#    { Σελιδοδείκτες bookmarks }
    if { "home" == [lindex $loop_tab 1] } {
	template::multirow append tabs [lindex $loop_tab 0] [lindex $loop_tab 1] ""
    } else {
	template::multirow append tabs [lindex $loop_tab 0] [lindex $loop_tab 1] "?[export_vars -url {tab_key {tab {[lindex $loop_tab 1]}}}]"
    }
}


  set bio [db_string biography "
  select attr_value
  from acs_attribute_values
  where object_id = :user_id
  and attribute_id =
     (select attribute_id
      from acs_attributes
      where object_type = 'person'
      and attribute_name = 'bio')" -default ""]



set profile_url [acs_community_member_url -user_id $user_id]
set context_bar [ad_context_bar]


ad_return_template
