# /packages/calendar/www/admin/cal-item-permissions.tcl

ad_page_contract {
    
    this provides a very basic permissioning UI by
    assigning permission to cal_items
    
    @author Gary Jin (gjin@arsdigita.com)
    
    @party_id  key to owner id
    @calendar_name  the name of the calendar
    @calendar_permission the permissions of the calendar

    @creation-date Jan 14, 2000
    @cvs-id $Id: cal-item-permissions.tcl,v 1.3 2002/09/18 12:12:04 jeffd Exp $
} {
    {party_id:integer -1}
    {cal_item_id:integer,notnull}
    {action list}
    {permission ""} 
} -properties {
    action:onevalue
    party_id:onevalue
    party_name:onevalue
    cal_item_name:onevalue

    privileges:multirow
    cal_item_permissions:multirow
    parties:multirow
    audiences:multirow
} 


# get user_id and check permission of the user
set user_id [ad_verify_and_get_user_id]    
#ad_require_permission $user_id cal_item_invite

# get party name
set party_name [db_string get_party_name {
                  select   acs_object.name(:party_id)
                  from     dual
               } -default ""]

# get cal_item name
set cal_item_name [db_string get_cal_item_name {
                     select    cal_item.name(:cal_item_id)
                     from      dual
                  } -default ""]
    

# ----------------------------------------------
# get cal_item_permissions within the system

db_multirow cal_item_permissions get_existing_permissions {
    select   unique(child_privilege) as privilege 
    from     acs_privilege_hierarchy 
    where    child_privilege like 'cal_item%'
}

# ----------------------------------------------
# view, edit, or delete

# view
if { [string equal $action "view"] } {
    
    #list all the privilege for the given party

    db_multirow privileges get_party_privileges {
	select    privilege
	from      acs_object_party_privilege_map 
	where     party_id = :party_id
	and       object_id = :cal_item_id
	and       privilege like '%cal_item%'
    }

    
# edit and delete must be done with users
# with calendar admin privilege only
# edit 

} elseif { [string equal $action "edit"] } {
    
    ad_require_permission $user_id calendar_admin

    # verify that permission does exist
    if { ![empty_string_p $permission] } {

	# grant permission
	cal_assign_item_permission $cal_item_id $party_id $permission	 
    }
    
   set action view
   ad_returnredirect "cal-item-permissions?[export_url_vars cal_item_id party_id action]"
    ad_script_abort
# delete
} elseif { [string equal $action "revoke"] } {
    ad_require_permission $user_id calendar_admin
    
    cal_assign_item_permission $cal_item_id $party_id $permission "revoke"
    
    set action "view"
    ad_returnredirect "cal-item-permissions?[export_url_vars cal_item_id party_id action]"
    ad_script_abort
# add user
} elseif { [string equal $action "add" ] } {

    # simple UI this would need be changed in the next release

    db_multirow parties list_users {
	select   acs_object.name(party_id) 
	         as pretty_name,
	         party_id
        from     parties
    }


# list   
} elseif { [string equal $action "list"] } {


    db_multirow audiences get_calendar_audiences {
	select    unique(grantee_id) as party_id,
	          acs_object.name(grantee_id) as name
	from      acs_permissions
	where     object_id = :cal_item_id	
    }



}
















