
# /packages/calendar/www/cal-item-create.tcl

ad_page_contract {
    
    Creation of new recurrence for cal item
    
    @author Ben Adida (ben@openforce.net)
    @creation-date 10 Mar 2002
    @cvs-id $Id: cal-item-create-recurrence-2.tcl,v 1.4 2002/07/22 21:46:19 ben Exp $
} {
    cal_item_id
    every_n
    interval_type
    recur_until:array
    days_of_week:multiple
    {return_url "./"}
} 

# Verify permission
ad_require_permission $cal_item_id cal_item_write

# Set up the recurrence
calendar::item::add_recurrence -cal_item_id $cal_item_id -interval_type $interval_type -every_n $every_n -days_of_week $days_of_week -recur_until [calendar_make_datetime [array get recur_until]]

ad_returnredirect $return_url
