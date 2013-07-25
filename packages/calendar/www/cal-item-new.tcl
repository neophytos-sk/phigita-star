ad_page_contract {
    
    Creating a new Calendar Item
    
    @author Ben Adida (ben@openforce.net)
    @creation-date May 29, 2002
    @cvs-id $Id: cal-item-new.tcl,v 1.6 2002/11/18 18:01:11 lars Exp $
} {
    {calendar_id ""}
    {date ""}
    {julian_date ""}
    {start_time ""}
    {end_time ""}
}

set package_id [ad_conn package_id]

set date [calendar::adjust_date -date $date -julian_date $julian_date]

if {[empty_string_p $calendar_id]} {
    set calendar_list [calendar::calendar_list]

    if {[llength $calendar_list] > 1} {
        set return_url [ns_urlencode "cal-item-new?date=[ns_urlencode $date]&start_time=$start_time&end_time=$end_time"]
        ad_returnredirect "calendar-choose?return_url=$return_url"
        ad_script_abort
    }

    set calendar_id [lindex $calendar_list 0]
}


# Create the form
form create cal_item

element create cal_item calendar_id \
        -label "Calendar ID" -datatype integer -widget hidden -value $calendar_id

element create cal_item title \
        -label "[_ calendar.Title_1]" -datatype text -widget text -html {size 60}

element create cal_item date \
        -label "[_ calendar.Date_1]" -datatype date -widget date

element create cal_item time_p \
        -label "&nbsp;" -datatype text -widget radio -options [list [list "[_ calendar.All_Day_Event]" 0] [list "[_ calendar.Use_Hours_Below]" 1]]

element create cal_item start_time \
        -label "[_ calendar.Start_Time]" -datatype date -widget date \
        -format [lc_get formbuilder_time_format] -optional

element create cal_item end_time \
        -label "[_ calendar.End_Time]" -datatype date -widget date \
        -format [lc_get formbuilder_time_format] -optional

element create cal_item description \
        -label "[_ calendar.Description]" -datatype text -widget textarea -html {cols 60 rows 3 wrap soft} -optional

element create cal_item item_type_id \
        -label "[_ calendar.Type_1]" -datatype integer -widget select -options [calendar::get_item_types -calendar_id $calendar_id] -optional

element create cal_item repeat_p \
        -label "[_ calendar.Repeat_1]" -datatype text -widget radio -options [list [list "[_ calendar.Yes]" 1] [list "[_ calendar.No]" 0]] -value 0

# Process the form
if {[form is_valid cal_item]} {
    template::form get_values cal_item calendar_id title date time_p start_time end_time description item_type_id repeat_p

    # Set up the datetimes
    set start_date [calendar::to_sql_datetime -date $date -time $start_time -time_p $time_p]
    set end_date [calendar::to_sql_datetime -date $date -time $end_time -time_p $time_p]

    set cal_item_id [calendar::item::new -start_date $start_date \
            -end_date $end_date \
            -name $title \
            -description $description \
            -calendar_id $calendar_id \
            -item_type_id $item_type_id]

    # If repeat_p, go to repetition page
    if {$repeat_p} {
        ad_returnredirect "cal-item-create-recurrence?cal_item_id=$cal_item_id"
    } else {
        ad_returnredirect "cal-item-view?cal_item_id=$cal_item_id"
    }
    
    # Stop here
    ad_script_abort
}

# Hide the type widget if there *are* no types to choose from
if { [llength [element get_property cal_item item_type_id options]] <= 1 } {
    element set_properties cal_item item_type_id -widget hidden
}

if { [form is_request cal_item] } {
    # Set some properties
    element set_properties cal_item date -value [calendar::from_sql_datetime -sql_date $date -format "YYYY-MM-DD"]
    
    if {[dt_no_time_p -start_time $start_time -end_time $end_time]} {
        # No time event
        element set_properties cal_item time_p -value 0
    } else {
        if {![empty_string_p $start_time]} {
            set start_time_date [calendar::from_sql_datetime -sql_date $start_time -format {HH24}]
            element set_properties cal_item start_time -value $start_time_date
        }
        
        if {![empty_string_p $end_time]} {
            set end_time_date [calendar::from_sql_datetime -sql_date $end_time -format {HH24}]
            element set_properties cal_item end_time -value $end_time_date
        }
        
        element set_properties cal_item time_p -value 1
    }
}

set cal_nav [dt_widget_calendar_navigation -link_current_view "view" day $date "calendar_id=$calendar_id"]

ad_return_template
