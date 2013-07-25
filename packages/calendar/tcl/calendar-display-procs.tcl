
ad_library {

    Utility functions for Displaying Calendar Things
    NOTE: this needs some serious refactoring. This code is already refactored from Tcl scripts.
    I'm working as fast as I can to fix this, but there is a LOT to fix (ben).


    @author Ben Adida (ben@openforce.net)
    @creation-date Jan 21, 2002
    @cvs-id $Id: calendar-display-procs.tcl,v 1.32 2002/12/19 16:27:11 peterm Exp $

}

namespace eval calendar {

    ad_proc -public one_month_display {
        {-calendar_id_list ""}
        {-day_template "<a href=?julian_date=\$julian_date>\$day_number</a>"}
        {-item_template "<a href=?action=edit&cal_item_id=\$item_id>\$item</a>"}
        {-item_add_template ""}
        {-date ""}
        {-url_stub_callback ""}
        {-show_calendar_name_p 1}
        {-prev_month_template ""}
        {-next_month_template ""}
    } {
        Creates a month widget with events for that month

        The url_stub_callback parameter allows a parameterizable URL stub
        for each calendar_id. If the parameter is non-null, it is considered a proc
        that can be called on a calendar_id to generate a URL stub.
    } {
        if {[empty_string_p $date]} {
            set date [dt_systime]
        }

        # If we were given no calendars, we assume we display the 
        # private calendar. It makes no sense for this to be called with
        # no data whatsoever.
        if {[empty_string_p $calendar_id_list]} {
            set calendar_id_list [list [calendar_have_private_p -return_id 1 [ad_get_user_id]]]
        }
        
        set items [ns_set create]
        
	
	db_foreach select_monthly_items {} {
            # Localize
            set start_time [lc_time_fmt $ansi_start_date "%X"]
            set end_time [lc_time_fmt $ansi_end_date "%X"]

	    # Calendar name now set in query
	    # set calendar_name [calendar_get_name $calendar_id]
	    
	    # reset url stub
	    set url_stub ""

	    # In case we need to dispatch to a different URL (ben)
	    if {![empty_string_p $url_stub_callback]} {
		# Cache the stuff
		if {![info exists url_stubs($calendar_id)]} {
		    set url_stubs($calendar_id) [$url_stub_callback $calendar_id]
		}

		set url_stub $url_stubs($calendar_id)
	    }
	    
	    set item "$name"
	    set item "[subst $item_template]"
	    
	    if {![dt_no_time_p -start_time $start_time -end_time $end_time]} {
		set item "<font size=-2><b>$start_time</b></font> $item"
	    }
	    
	    if {$show_calendar_name_p} {
		append item " <font size=-2>($calendar_name)</font>"
	    }
	    
	    # DRB: This ugly hack was added for dotlrn-events, to give us a way to
	    # flag event status in red in accordance with the spec.  When calendar
	    # is rewritten we should come up with a way for objects derived from
	    # acs-events to render their own name summary and full descriptions.
	    
	    if { [string length $status_summary] > 0 } {
		append item " <font color=\"red\">$status_summary</font> "
	    }
	    
	    append item "<br>"
	    
	    ns_set put $items $start_date $item
	}            

        
        # Display stuff
        if {[empty_string_p $item_add_template]} {
            set day_number_template "<font size=1>$day_template</font>"
        } else {
            set day_number_template "<font size=1>$day_template&nbsp;$item_add_template</font>"
        }

        return [dt_widget_month -calendar_details $items -date $date \
                -master_bgcolor black \
                -header_bgcolor lavender \
                -header_text_color black \
                -header_text_size "+1" \
                -day_header_bgcolor lavender \
                -day_bgcolor white \
                -today_bgcolor #FFF8DC \
                -empty_bgcolor lightgrey \
                -day_text_color black \
                -prev_next_links_in_title 1 \
                -prev_month_template $prev_month_template \
                -next_month_template $next_month_template \
                -day_number_template $day_number_template]
    }

    ad_proc -public one_week_display {
        {-calendar_id_list ""}
        {-day_template "<a href=?date=\$date>\$day &nbsp; - &nbsp; \$pretty_date</a>"}
        {-item_template "<a href=?action=edit&cal_item_id=\$item_id>\$item</a>"}
        {-item_add_template ""}
        {-date ""}
        {-url_stub_callback ""}
        {-prev_week_template ""}
        {-next_week_template ""}
        {-show_calendar_name_p 1}
    } {
        Creates a week widget

        The url_stub_callback parameter allows a parameterizable URL stub
        for each calendar_id. If the parameter is non-null, it is considered a proc
        that can be called on a calendar_id to generate a URL stub.
    } {
        if {[empty_string_p $date]} {
            set date [dt_sysdate]
        }

        set current_date $date

        # If we were given no calendars, we assume we display the 
        # private calendar. It makes no sense for this to be called with
        # no data whatsoever.
        if {[empty_string_p $calendar_id_list]} {
            set calendar_id_list [list [calendar_have_private_p -return_id 1 [ad_get_user_id]]]
        }
        
        set items [ns_set create]

        # Find the first day of the week in julian
        set current_date_weekday_no [expr [clock format [clock scan $date] -format %w] + 1]
        set first_day_of_week_julian [expr [dt_ansi_to_julian_single_arg $date] - (($current_date_weekday_no + 6 - [lc_get firstdayofweek]) % 7)]

	set sunday_of_the_week $current_date_weekday_no
	set saturday_of_the_week $current_date_weekday_no
        # Loop through the calendars
	db_foreach select_week_items {} {
            # Localize
            set pretty_start_date [lc_time_fmt $ansi_start_date "%X"]
            set pretty_end_date [lc_time_fmt $ansi_end_date "%X"]

	    # now selected from the query
	    # set calendar_name [calendar_get_name $calendar_id]
	    
	    # In case we need to dispatch to a different URL (ben)
	    if {![empty_string_p $url_stub_callback]} {
		# Cache the stuff
		if {![info exists url_stubs($calendar_id)]} {
		    set url_stubs($calendar_id) [$url_stub_callback $calendar_id]
		}

		set url_stub $url_stubs($calendar_id)
	    }
	    
	    set item "$name"
	    set item_details "[subst $item_template]"
	    
	    # Add time details
	    if {[dt_no_time_p -start_time $start_date -end_time $end_date]} {
		set time_details ""
	    } else {
		set time_details "<b>$pretty_start_date - $pretty_end_date</b>:"
	    }
	    
	    set item "$time_details $item_details"
	    
	    if {$show_calendar_name_p} {
		append item "<font size=-1>($calendar_name)</font><br>"
	    }
	    
	    if { [string length $status_summary] > 0 } {
		append item " <font color=\"red\">$status_summary</font> "
	    }
	    
	    ns_set put $items $start_date_julian $item
        }

        # display stuff
        
        if {[empty_string_p $item_add_template]} {
            set day_number_template "$day_template"
        } else {
            set day_number_template "$day_template &nbsp; &nbsp; $item_add_template"
        }
        
        return [dt_widget_week -calendar_details $items -date $date -day_template $day_number_template -prev_week_template $prev_week_template -next_week_template $next_week_template]
        
    }

    ad_proc -public one_day_display {
        {-date ""}
        {-calendar_id_list ""}
        {-hour_template {$hour}}
        {-item_template {$item}}
        {-prev_nav_template {<a href=".?date=[ns_urlencode $yesterday]">&lt;</a>}}
        {-next_nav_template {<a href=".?date=[ns_urlencode $tomorrow]">&gt;</a>}}
        {-start_hour 0}
        {-end_hour 23}
        {-url_stub_callback ""}
        {-show_calendar_name_p 1}
    } {
        Creates a day widget

        The url_stub_callback parameter allows a parameterizable URL stub
        for each calendar_id. If the parameter is non-null, it is considered a proc
        that can be called on a calendar_id to generate a URL stub.
    } {
        set widget_start_hour $start_hour
        set widget_end_hour $end_hour

        set date_format "YYYY-MM-DD HH24:MI"

        if {[empty_string_p $date]} {
            set date [dt_sysdate]
        }

        set current_date $date

        # If we were given no calendars, we assume we display the 
        # private calendar. It makes no sense for this to be called with
        # no data whatsoever.
        if {[empty_string_p $calendar_id_list]} {
            set calendar_id_list [list [calendar_have_private_p -return_id 1 [ad_get_user_id]]]
        }
        
        set items [ns_set create]

        set timezone [lang::conn::timezone]

        # Loop through the calendars
	db_foreach select_day_items {} {
            # other date/time formats
            set start_hour [lc_time_fmt $ansi_start_date "%H"]
            set start_date [lc_time_fmt $ansi_start_date "%H:%M"]
            set end_date [lc_time_fmt $ansi_end_date "%H:%M"]

            # Localize
            set pretty_start_date [lc_time_fmt $ansi_start_date "%X"]
            set pretty_end_date [lc_time_fmt $ansi_end_date "%X"]
            
	    # Not needed anymore
            # set calendar_name [calendar_get_name $calendar_id]

            # In case we need to dispatch to a different URL (ben)
            if {![empty_string_p $url_stub_callback]} {
		# Cache the stuff
		if {![info exists url_stubs($calendar_id)]} {
		    set url_stubs($calendar_id) [$url_stub_callback $calendar_id]
		}

		set url_stub $url_stubs($calendar_id)
            }
	    
	    set item_details ""

	    if {$show_calendar_name_p} {
		append item_details $calendar_name
	    }
	    
	    if {![empty_string_p $item_type]} {
		if {![empty_string_p $item_details]} {
		    append item_details " - "
		}
		
		append item_details "$item_type"
	    }
	    
	    set item $name
	    set item_subst [subst $item_template]
	    
	    if {[dt_no_time_p -start_time $pretty_start_date -end_time $pretty_end_date]} {
		# Hack for no-time items
		set item "$item_subst"
		if {![empty_string_p $item_details]} {
		    append item " <font size=-1>($item_details)</font>"
		}
		
		set ns_set_pos "X"
	    } else {
		set item "<b>$pretty_start_date - $pretty_end_date</b>: $item_subst"
		if {![empty_string_p $item_details]} {
		    append item " <font size=-1>($item_details)</font>"
		}
		set ns_set_pos $start_hour
	    }
	    
	    if { [string length $status_summary] > 0 } {
		append item " <font color=\"red\">$status_summary</font> "
	    }
	    
	    ns_set put $items $ns_set_pos [list $start_date $end_date $item]
        }

        set hour {$display_hour}
        set start_time {$hour}
        set end_time {$next_hour}
        
        set hour_template [subst $hour_template]
        
        return [dt_widget_day -hour_template $hour_template \
                -prev_nav_template $prev_nav_template \
                -next_nav_template $next_nav_template \
                -start_hour $widget_start_hour -end_hour $widget_end_hour \
                -calendar_details $items -date $date -overlap_p 1]
        
    }

    ad_proc -public list_display {
        {-date ""}
        {-start_date ""}
        {-end_date ""}
        {-calendar_id_list ""}
        {-item_template {$item}}
        {-url_template {?sort_by=$order_by}}
        {-url_stub_callback ""}
        {-show_calendar_name_p 1}
        {-sort_by "item_type"}
    } {
        create a list display of items
    } {
        # If we were given no calendars, we assume we display the 
        # private calendar. It makes no sense for this to be called with
        # no data whatsoever.
        if {[empty_string_p $calendar_id_list]} {
            set calendar_id_list [list [calendar_have_private_p -return_id 1 [ad_get_user_id]]]
        }

        # sort by cannot be empty
        if {[empty_string_p $sort_by]} {
            set sort_by "item_type"
        }
        
        set date_format "YYYY-MM-DD HH24:MI"
        set current_date $date
        set items [ns_set create]
        
        # Loop through the calendars
        foreach calendar_id $calendar_id_list {
            set calendar_name [calendar_get_name $calendar_id]
            
            # In case we need to dispatch to a different URL (ben)
            if {![empty_string_p $url_stub_callback]} {
                set url_stub [$url_stub_callback $calendar_id]
            }
            
            db_foreach select_list_items {} {
                set item "$name"
                set item [subst $item_template]
                
                if {$show_calendar_name_p} {
                    append item " ($calendar_name)"
                }
                
                # Localize
                set pretty_date [lc_time_fmt $ansi_start_date "%x"]
                set pretty_weekday [lc_time_fmt $ansi_start_date "%A"]
                set pretty_start_date [lc_time_fmt $ansi_start_date "%X"]
                set pretty_end_date [lc_time_fmt $ansi_end_date "%X"]

                ns_set put $items $start_hour [list $pretty_date $pretty_start_date $pretty_end_date $pretty_weekday $item_type $item]
            }
            
        }

        # Now we have the items in a big ns_set
        # We call the widget maker
        return [dt_widget_list -order_by $sort_by \
                -item_template $item_template \
                -calendar_details $items \
                -start_date $start_date \
                -end_date $end_date \
                -url_template $url_template]
        
    }

}
