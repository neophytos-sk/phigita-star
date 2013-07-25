
ad_page_contract {
    
    Viewing Calendar Stuff
    
    @author Ben Adida (ben@openforce.net)
    @creation-date May 29, 2002
    @cvs-id $Id: view.tcl,v 1.9 2002/11/20 17:22:11 lars Exp $
} {
    {view day}
    {date ""}
    {julian_date ""}
    {calendar_list:multiple ""}
    {sort_by ""}
}

set package_id [ad_conn package_id]
set user_id [ad_conn user_id]

set calendar_list [calendar::adjust_calendar_list -calendar_list $calendar_list -package_id $package_id -user_id $user_id]
set date [calendar::adjust_date -date $date -julian_date $julian_date]

# Calendar ID list

# Set up some template
set item_template "<a href=\"cal-item-view?cal_item_id=\$item_id\">\$item</a>"
set hour_template "<a href=\"cal-item-new?date=\[ns_urlencode \$date]&start_time=\$start_time&end_time=\$end_time\">\$hour</a>"
set item_add_template "<a href=\"cal-item-new?julian_date=\$julian_date&start_time=&end_time=\" title=\"[_ calendar.Add_Item]\">+</a>"

set base_url view?
set navbar [dt_navbar_view -link_current_view=0 $view $base_url $date]

# Depending on the view, make a different widget
if {$view == "day"} {
    set cal_stuff [calendar::one_day_display \
		       -prev_nav_template "<a href=\"view?view=$view&date=\[ns_urlencode \$yesterday]\"><img border=0 src=/graphics/leftl1 width=16 height=16></a>" \
		       -next_nav_template "<a href=\"view?view=$view&date=\[ns_urlencode \$tomorrow]\"><img border=0 src=/graphics/rightl1 width=16 height=16></a>" \
            -item_template $item_template \
            -hour_template $hour_template \
            -date $date -start_hour 7 -end_hour 22 \
            -calendar_id_list $calendar_list]

}

if {$view == "week"} {
    set cal_stuff [calendar::one_week_display \
            -item_template $item_template \
            -day_template "<font size=-1><b>\$day</b> - <a href=\"view?date=\[ns_urlencode \$date]&view=day\">\$pretty_date</a> &nbsp; &nbsp; <a href=\"cal-item-new?date=\$date&start_time=&end_time=\">([_ calendar.Add_Item])</a></font>" \
            -date $date \
            -calendar_id_list $calendar_list \
            -prev_week_template "<a href=\"view?date=\[ns_urlencode \$last_week]&view=week\"><img border=0 src=/graphics/leftl1 width=16 height=16></a>" \
            -next_week_template "<a href=\"view?date=\[ns_urlencode \$next_week]&view=week\"><img border=0 src=/graphics/rightl1 width=16 height=16></a>"
    ]
}

if {$view == "month"} {
    set cal_stuff [calendar::one_month_display \
            -item_template "<font size=-2>$item_template</font>" \
            -day_template "<font size=-1><b><a href=view?julian_date=\$julian_date&view=day>\$day_number</a></b></font>" \
            -date $date \
            -item_add_template "<font size=-3>$item_add_template</font>" \
            -calendar_id_list $calendar_list \
            -prev_month_template "<a href=view?view=month&date=\$ansi_date><img border=0 src=/graphics/leftl1 width=16 height=16></a>" \
            -next_month_template "<a href=view?view=month&date=\$ansi_date><img border=0 src=/graphics/rightl1 width=16 height=16></a>"]
}

if {$view == "list"} {
    set start_date $date
    set ansi_list [split $date "- "]
    set ansi_year [lindex $ansi_list 0]
    set ansi_month [string trimleft [lindex $ansi_list 1] "0"]
    set ansi_day [string trimleft [lindex $ansi_list 2] "0"]
    set end_date [dt_julian_to_ansi [expr [dt_ansi_to_julian $ansi_year $ansi_month $ansi_day ] + 1]]
    set cal_stuff [calendar::list_display \
            -item_template $item_template \
            -start_date $start_date \
            -end_date $end_date \
            -date $date \
            -calendar_id_list $calendar_list \
            -sort_by $sort_by \
            -url_template "view?view=list&sort_by=\$order_by"]
}

set cal_nav [dt_widget_calendar_navigation "view" $view $date "calendar_list="]

ad_return_template 
