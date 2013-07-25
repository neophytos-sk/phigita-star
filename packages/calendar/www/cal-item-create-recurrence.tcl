
# /packages/calendar/www/cal-item-create.tcl

ad_page_contract {
    
    Creation of new recurrence for cal item
    
    @author Ben Adida (ben@openforce.net)
    @creation-date 10 Mar 2002
    @cvs-id $Id: cal-item-create-recurrence.tcl,v 1.4 2002/07/22 21:46:19 ben Exp $
} {
    cal_item_id
    {return_url "./"}
} 

# Verify permission
ad_require_permission $cal_item_id cal_item_write

# Select basic information about the event
calendar::item::get -cal_item_id $cal_item_id -array cal_item

ad_return_template

