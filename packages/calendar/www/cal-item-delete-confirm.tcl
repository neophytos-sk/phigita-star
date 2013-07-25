
#
# A script that assumes
#
# cal_item_id
#
# This will pull out information about the event and 
# display it with some options.
#

ad_page_contract {
    Confirm Deletion
} {
    cal_item_id
    {show_cal_nav 1}
}

calendar::item::get -cal_item_id $cal_item_id -array cal_item

# no time?
set cal_item(no_time_p) [dt_no_time_p -start_time $cal_item(start_time) -end_time $cal_item(end_time)]

# cal nav
set cal_nav [dt_widget_calendar_navigation -link_current_view "view" day $cal_item(start_date) "calendar_id="]

ad_return_template
