# /packages/calendar/www/admin/index.tcl

ad_page_contract {
    
    Main Calendar Admin Page. 
    ## HACKED BY BEN FOR SLOAN ##
    ## FEATURES TEMPORARILY TAKEN OUT ##
    
    This pages checks to see if the user has any group calendar 
    that he or she is the admin of. 
    

    @author Gary Jin (gjin@arsdigita.com)
    @creation-date Dec 14, 2000
    @cvs-id $Id: index.tcl,v 1.2 2002/03/16 21:06:44 ben Exp $
} {
 
} -properties {
    context_bar:onevalue
}


# find out the user_id 
set user_id [ad_verify_and_get_user_id]

set package_id [ad_conn package_id]
set context_bar "Admin"


db_multirow calendars calendar_list {
    select     calendar_id, 
               calendar_name
    from       calendars
    where      owner_id = :user_id
    and        acs_permission.permission_p(
                  calendar_id, 
                  :user_id,
                  'calendar_admin'
               ) = 't'
    order by   calendar_name
}
          

# list the groups that the user_id is a member of
set group_set_id [cc_member_of_groups $user_id] 

set set_size [ns_set size $group_set_id]
set data ""

for {set i 0} {$i < [ns_set size $group_set_id]} {incr i} {
    set data "<li> [ns_set key $group_set_id $i] => [ns_set value $group_set_id $i]"
}

ad_return_template 





































