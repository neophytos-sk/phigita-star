# /packages/calendar/www/index.tcl

ad_page_contract {
    View one event
    
    @author Ben Adida (ben@openforce.net)
    @creation-date April 09, 2002
    @cvs-id $Id: cal-item-view.tcl,v 1.9 2002/11/18 18:01:11 lars Exp $
} {
    cal_item_id
    {return_url ""}
    {show_cal_nav 1}
}

# find out the user_id 
set user_id [ad_verify_and_get_user_id]

set package_id [ad_conn package_id]

# Require read permission (FIXME)
# ad_require_permission $cal_item_id read

# write permission
set edit_p [ad_permission_p $cal_item_id cal_item_write]

# delete permission
set delete_p [ad_permission_p $cal_item_id cal_item_delete] 

# admin permission
set admin_p [ad_permission_p $cal_item_id calendar_admin]

calendar::item::get -cal_item_id $cal_item_id -array cal_item

# Attachments?
if {$cal_item(n_attachments) > 0} {
    set item_attachments [attachments::get_attachments -object_id $cal_item(cal_item_id)]
} else {
    set item_attachments [list]
}

# no time?
set cal_item(no_time_p) [dt_no_time_p -start_time $cal_item(start_time) -end_time $cal_item(end_time)]

# Attachment URLs
if {[calendar::attachments_enabled_p]} {
    set attachment_options " | <A href=\"[attachments::add_attachment_url -object_id $cal_item(cal_item_id) -return_url "../cal-item-view?cal_item_id=$cal_item(cal_item_id)"]\">add attachment</a>"
} else { 
    set attachment_options {} 
}

# cal nav
set cal_nav [dt_widget_calendar_navigation -link_current_view "view" day $cal_item(start_date) "calendar_id="]

ad_return_template 

