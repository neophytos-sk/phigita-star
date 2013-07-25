# /packages/calendar/www/admin/calendar-permissions.tcl

ad_page_contract {
    
    this provides a very basic permissioning UI by
    assigning permission to calendars
    
    @author Gary Jin (gjin@arsdigita.com)
    
    @party_id  key to owner id
    @calendar_name  the name of the calendar
    @calendar_permission the permissions of the calendar

    @creation-date Dec 14, 2000
    @cvs-id $Id: calendar-permissions.tcl,v 1.2 2002/09/18 12:12:04 jeffd Exp $
} {
    {party_id -1}
    {calendar_id:notnull}
    {action view}
    {permission ""} 
} -properties {
    party_id:onevalue
    party_name:onevalue
    calendar_name:onevalue

    privileges:multirow
    calendar_permissions:multirow
    parties:multirow
} 


# get user_id and check permission of the user
set user_id [ad_verify_and_get_user_id]    
ad_require_permission $user_id calendar_admin

# get party name
set party_name [db_string get_party_name {
                  select   acs_object.name(:party_id)
                  from     dual
               } -default ""]

# get calendar_name
set calendar_name [calendar_get_name $calendar_id]

# ----------------------------------------------
# get calendar_permissions within the system

db_multirow calendar_permissions get_existing_permissions {
    select   unique(child_privilege) as privilege 
    from     acs_privilege_hierarchy 
    where    child_privilege like 'calendar%'
}

# ----------------------------------------------
# view, greant, or revoke

# view
if { [string equal $action "view"] } {
    
    #list all the privilege for the given party

    db_multirow privileges get_party_privileges {
	select    privilege 	        
	from      acs_object_party_privilege_map 
	where     object_id = :calendar_id
	and       party_id = :party_id
	and       privilege like '%calendar%'
    }

    
# grant
} elseif { [string equal $action "grant"] } {
    
    # verify that permission does exist
    if { ![empty_string_p $permission] } {

	# grant permission
	calendar_assign_permissions $calendar_id $party_id $permission	 

	calendar_assign_permissions $calendar_id $party_id "calendar_show"
    }
    
    set action view
    ad_returnredirect "calendar-permissions?[export_url_vars calendar_id party_id action]"
    ad_script_abort

# revoke
} elseif { [string equal $action "revoke"] } {
    
    calendar_assign_permissions $calendar_id $party_id $permission "revoke"
    ad_returnredirect "calendar-permissions?[export_url_vars calendar_id party_id]"
    ad_script_abort

# add user
} elseif { [string equal $action "add" ] } {

    # simple UI this would need be changed in the next release

    db_multirow parties list_users {
	select   acs_object.name(party_id) 
	         as pretty_name,
	         party_id
        from parties
    }


}

ad_return_template
















