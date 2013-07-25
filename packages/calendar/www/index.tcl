# /packages/calendar/www/index.tcl

ad_page_contract {
    
    Main Calendar Page
    totally redone by Ben
    
    @author Ben Adida (ben@openforce.net)
    @creation-date June 2, 2002
    @cvs-id $Id: index.tcl,v 1.10 2002/11/30 17:28:09 jeffd Exp $
} {
}

set package_id [ad_conn package_id]
set user_id [ad_conn user_id]

if {!$user_id} {
    # user isn't logged in 
    ad_redirect_for_registration
    ad_script_abort
}

# Check for a personal, private calendar, create if missing
# FIXME BUG: this should be moved to new pages to allow users
# to create/delete/modify/admin their calendars. 

if {![db_string private_calendar_count_qry {}]} {
    # Create a personal calendar for the user
    calendar::new -owner_id $user_id -private_p "t" -calendar_name "Personal" -package_id $package_id
}

ad_returnredirect "view"    
