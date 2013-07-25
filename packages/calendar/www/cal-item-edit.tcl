# /packages/calendar/www/cal-item-edit.tcl

ad_page_contract {
    
    edit an existing calendar item
    (totally rewritten, this was nasty)

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-06-02
    @cvs-id $Id: cal-item-edit.tcl,v 1.16 2002/12/19 16:27:22 peterm Exp $
} {
    cal_item_id:integer,notnull
} 

# Permissions
# FIXME: we need to add a permissions check here!

# Create the form
form create cal_item

element create cal_item cal_item_id \
        -label "Calendar Item ID" -datatype integer -widget hidden -value $cal_item_id

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
        -label "[_ calendar.Type_1]" -datatype integer -widget select -optional

element create cal_item repeat_p \
        -label "[_ calendar.Edit_All_Occurrences]" -datatype text -widget radio -options [list [list "[_ calendar.Yes]" 1] [list "[_ calendar.No]" 0]] -value 0


if {[form is_valid cal_item]} {
    form get_values cal_item cal_item_id title date time_p start_time end_time description item_type_id repeat_p

    # set up the datetimes
    set start_date [calendar::to_sql_datetime -date $date -time $start_time -time_p $time_p]
    set end_date [calendar::to_sql_datetime -date $date -time $end_time -time_p $time_p]

    # Do the edit
    calendar::item::edit -cal_item_id $cal_item_id \
            -start_date $start_date \
            -end_date $end_date \
            -name $title \
            -description $description \
            -item_type_id $item_type_id \
            -edit_all_p $repeat_p

    # Redirect
    ad_returnredirect "cal-item-view?cal_item_id=$cal_item_id"
    ad_script_abort
}

# Select info for the item
calendar::item::get -cal_item_id $cal_item_id -array cal_item

# Prepare the form nicely
element set_properties cal_item item_type_id -options [calendar::get_item_types -calendar_id $cal_item(calendar_id)] 

# Hide the type widget if there *are* no types to choose from
if { [llength [element get_property cal_item item_type_id options]] <= 1 } {
    element set_properties cal_item item_type_id -widget hidden
}

# if no recurrence, don't show the repeat stuff
if {[empty_string_p $cal_item(recurrence_id)]} {
    element set_properties cal_item repeat_p -widget hidden
}

if { [form is_request cal_item] } {
    element set_properties cal_item cal_item_id -value $cal_item(cal_item_id)
    element set_properties cal_item title -value $cal_item(name)
    element set_properties cal_item date -value [template::util::date::from_ansi $cal_item(start_date)]
    element set_properties cal_item start_time -value [template::util::date::from_ansi $cal_item(ansi_start_date) [lc_get formbuilder_time_format]]
    element set_properties cal_item end_time -value [template::util::date::from_ansi $cal_item(ansi_end_date) [lc_get formbuilder_time_format]]
    element set_properties cal_item description -value $cal_item(description)
    element set_properties cal_item item_type_id -value $cal_item(item_type_id)

    if {[dt_no_time_p -start_time $cal_item(start_time) -end_time $cal_item(end_time)]} {
        element set_properties cal_item time_p -value 0
    } else {
        element set_properties cal_item time_p -value 1
    }
}


set cal_nav [dt_widget_calendar_navigation -link_current_view "view" day $cal_item(start_date) "calendar_id"]

ad_return_template

