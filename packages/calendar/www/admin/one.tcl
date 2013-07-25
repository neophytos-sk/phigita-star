# /packages/calendar/www/admin/one.tcl

ad_page_contract {
    
    tcl support file for one.adp

    @author Gary Jin (gjin@arsdigita.com)
    
    @action  the action that's going to be performed. view, add, edit, delete, permissions
    @calendar_name  the name of the calendar
    @calendar_permission the permissions of the calendar

    @creation-date Dec 14, 2000
    @cvs-id $Id: one.tcl,v 1.2 2002/09/04 07:52:32 jeffd Exp $
} {
    {action view}
    {calendar_id:integer ""}
} -properties {
    action:onevalue
    party_id:onevalue
    calendar_name:onevalue
    calendar_permission:onevalue

    title:onevalue
    context:onevalue

    audiences:multirow
}

# get party_id of the calendar_admin
set party_id [ad_verify_and_get_user_id]

# TODO: should be a proc here to make sure 
# user truly has the calendar admin privilege


# action is edit
if { [string equal $action "edit" ] } {
    # make sure that calendar_id exist, barf if not 

    if { ![empty_string_p $calendar_id] } {

	#set context bar and title
	set context "Edit"
	set title ": Edit a Calendar"

	# get calendar name
	set calendar_name [calendar_get_name $calendar_id]
	
	# get calendar permission
	if { [calendar_public_p $calendar_id] } {
	    set calendar_permission "public"
	} else {
	    set calendar_permission "private"
	}

    } else {
	ad_return_complaint 1 "Calendar_id is required but not supplied!"
    }
  
  
# action is add
} elseif { [string equal $action "add" ] } {

    #set context bar and title
    set context "Create"
    set title ": Create a Calendar"


# action is view    
} elseif { [string equal $action "view"] } {

    #set context bar and title
    set context "Create"
    set title ": Create a Calendar"


# action is delete
} elseif { [string equal $action "delete"] } {

    #set context bar and title
    set context "Delete"
    set title ": Delete a Calendar"


# action is permission
} elseif { [string equal $action "permission"] } {

    #set context bar and title
    set context "permissions"
    set title ": Manage Calendar Permissions"

    # get calendar_name
    set calendar_name [calendar_get_name $calendar_id]

    # list the audiences of the user
    # note: this would be supported a more complex UI
    #       i am envision it somewhat like the file-storage system
    #       where you can expand the levels.. after this versions though

    db_multirow audiences get_calendar_audiences {
	select    unique(grantee_id) as party_id,
	          acs_object.name(grantee_id) as name
	from      acs_permissions
	where     object_id = :calendar_id	
    }

}






