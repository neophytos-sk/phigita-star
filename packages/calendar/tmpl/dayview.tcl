ad_page_contract {

    @author Neophytos Demetriou

} {
    {base ""}
    {date "[dt_sysdate]"}
    {start_hour "0"}
    {end_hour "23"}
}

set pretty_date [lc_time_fmt $date "%Q"]


set prev_day [dt::prev $date]
set next_day [dt::next $date]


#### 
set widget_start_hour $start_hour
        set widget_end_hour $end_hour


        set current_date $date
        set date_format "YYYY-MM-DD HH24:MI"

set calendar_id_list [list [calendar_have_private_p -return_id 1 [ad_get_user_id]]]


set calendar_details [ns_set create]

set timezone [lang::conn::timezone]

# Loop through the calendars
db_foreach select_day_items "       select   to_char(start_date, 'HH24') as start_hour,
         to_char(start_date, 'HH24:MI') as start_date,
         to_char(end_date, 'HH24:MI') as end_date,
         to_char(start_date, 'YYYY-MM-DD HH24:MI:SS') as ansi_start_date,
         to_char(end_date, 'YYYY-MM-DD HH24:MI:SS') as ansi_end_date,
         coalesce(e.name, a.name) as name,
         coalesce(e.status_summary, a.status_summary) as status_summary,
         e.event_id as item_id,
         (select type from cal_item_types where item_type_id= cal_items.item_type_id) as item_type,
         on_which_calendar as calendar_id,
         (select calendar_name from calendars
         where calendar_id = on_which_calendar)
         as calendar_name
from     acs_activities a,
         acs_events e,
         timespans s,
         time_intervals t,
         cal_items
where    e.timespan_id = s.timespan_id
and      s.interval_id = t.interval_id
and      e.activity_id = a.activity_id
and      start_date between
         to_date(:current_date,:date_format) and
         to_date(:current_date,:date_format) + (24 - 1/3600)/24
and     cal_items.cal_item_id= e.event_id
and      e.event_id
in       (
         select  cal_item_id
         from    cal_items
         where   on_which_calendar in ([join $calendar_id_list ","])
         )
" {
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
    if {![empty_string_p $base]} {
	# Cache the stuff
	if {![info exists url_stubs($calendar_id)]} {
	    set url_stubs($calendar_id) [$url_stub_callback $calendar_id]
	}

	set url_stub $url_stubs($calendar_id)
    }

    set item_details ""


    if {![empty_string_p $item_type]} {

	if {![empty_string_p $item_details]} {
	    append item_details " - "
	}

	append item_details "$item_type"
    }

    set item $name
    set item_subst $item

    if {[dt_no_time_p -start_time $pretty_start_date -end_time $pretty_end_date]} {
	# Hack for no-time items
	set item "$item_subst"
	if {![empty_string_p $item_details]} {
	    append item " <font size=-1>($item_details)</font>"
	}

	set ns_set_pos "X"
    } else {
	set item "<small>$pretty_start_date-$pretty_end_date</small><br> <small>$item_subst</small>"
	set ns_set_pos $start_hour
    }

    if { [string length $status_summary] > 0 } {
	append item " <font color=\"red\">$status_summary</font> "
    }

    ns_set put $calendar_details $ns_set_pos [list $start_date $end_date $item]
}


    for { set hour 0 } { $hour < 24 } { incr hour } { 
        if { ($hour < $start_hour || $hour > $end_hour) && [ns_set find $calendar_details [format "%02d" $hour]] != -1 } {
            if { $hour < $start_hour } {
                set start_hour $hour
            } elseif { $hour > $end_hour } {
                set end_hour $hour
            }
        }
    }

    # Collect some statistics about the events (for overlap)
    for {set hour $start_hour} {$hour <= 23} {incr hour} {
        set n_events($hour) 0
        set n_starting_events($hour) 0
    }

    # Count number of overlapping events each hour

    # Make a copy of the calendar_details set that we can work on for a minute, discard afterwards.
    set calendar_details_2 [ns_set copy $calendar_details]

    for {set hour $start_hour} {$hour <= $end_hour} {incr hour} {
        if {$hour < 10} {
            set index_hour "0$hour"
        } else {
            set index_hour $hour
        }

        # Go through events
        while {1} {
            set index [ns_set find $calendar_details_2 $index_hour]
            if {$index == -1} {
                break
            }
            
            set item_val [ns_set value $calendar_details_2 $index]
            ns_set delete $calendar_details_2 $index
            # Count the num of events starting at this hour
            set n_starting_events($hour) [expr $n_starting_events($hour) + 1]

            # Diff the hours 
            set hours_diff [dt_hour_diff -start_time [lindex $item_val 0] -end_time [lindex $item_val 1]]

            # Count the num of events at the hours of operations
            for {set i 0} {$i <= $hours_diff} {incr i} {
                set the_hour [expr $hour + $i]
                set n_events($the_hour) [expr $n_events($the_hour) + 1]
            }
        }
    }

    # the MAX num of events
    set max_n_events 1
    for {set hour $start_hour} {$hour <= $end_hour} {incr hour} {
        if {$max_n_events < $n_events($hour)} {
            set max_n_events $n_events($hour)
        }
    }
    
    
    set day_of_the_week [lc_time_fmt $current_date "%Q"]

    set return_html ""


    # Loop through the hours of the day
    append return_html "<table cellpadding=1 cellspacing=0 border=0 width=100%>"

    # The items that have no hour (all day events)
    set hour ""
    set next_hour ""
    set start_time ""
    set display_hour "<img border=0 align=\"center\" src=\"/graphics/diamond.gif\" alt=\"No Time\">"
    append return_html "<tr><td class=\"calnone\" align=\"left\" width=\"60\" \"nowrap\"><font size=-1>\No Time</font></td>"
    append return_html "<td class=calnone colspan=\"[expr 1+$max_n_events]\">"
    
    # Go through events
    while {1} {
        set index [ns_set find $calendar_details "X"]
        if {$index == -1} {
            break
        }
        
        if {$overlap_p} {
            append return_html "[lindex [ns_set value $calendar_details $index] 2]<br>"
        } else {
            append return_html "[ns_set value $calendar_details $index]<br>\n"
        }
        
        ns_set delete $calendar_details $index
    }

    append return_html "&nbsp;</td></tr>"

    # Normal hour-by-hour display
    for {set hour $start_hour} {$hour <= $end_hour} {incr hour} {
        
        set next_hour [expr $hour + 1]

        if {$hour < 10} {
            set index_hour "0$hour"
        } else {
            set index_hour $hour
        }
        
        set display_hour [string tolower [string trimleft [lc_time_fmt "0000-00-00 ${hour}:00:00" "%X"] 0]]


#HERE        set display_hour hour_template
        append return_html "<tr><td VALIGN=top ALIGN=right NOWRAP WIDTH=1% class=calnone>$display_hour</td>"
        set n_processed_events 0
        
        # Go through events
        while {1} {
            set index [ns_set find $calendar_details $index_hour]
            if {$index == -1} {
                break
            }

            incr n_processed_events

                set one_item_val [ns_set value $calendar_details $index]
                
                set hour_diff [dt_hour_diff -start_time [lindex $one_item_val 0] -end_time [lindex $one_item_val 1]]

                set start_time $hour

                # Calculate the colspan
                if {$n_processed_events == $n_events($hour)} {
                    # This is the last one, make it as wide as possible
                        set colspan [expr $max_n_events - $n_events($hour)+1]
                } {
                    # Just make it one
                    set colspan 1
                } 

                append return_html "<td class=calmy valign=top rowspan=[expr $hour_diff + 1] colspan=$colspan>[lindex $one_item_val 2]</td>"

            ns_set delete $calendar_details $index
        }

if { $n_processed_events == $n_starting_events($hour)} {
       	append return_html "<td class=calnone colspan=\"[expr "$max_n_events - $n_events($hour)"]\">$hour [expr "$max_n_events - $n_events($hour)"]&nbsp;</td>"
}
        append return_html "</tr>"

    }

    append return_html "</table>"

