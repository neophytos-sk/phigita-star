
ad_library {
    Utility functions for syncing Calendar with Outlook
    
    taken from SloanSpace v1, hacked for OpenACS by Ben.

    @author wtem@olywa.net
    @author ben@openforce.biz
}

# wtem@olywa.net, 2001-06-12
# adding support for synching a single event with msoutlook

# 1. make sure the server config file 
# (in this case an .ini file) has the .ics extension mapped to msoutlook
# i.e. .ics=application/x-msoutlook

# 2. define a proc to pull an event from the database and put it in ics formatt
# and any helper procs necessary

# 3. register the proc to all requests for .ics

namespace eval calendar::outlook {
   
    ad_proc -private adjust_timezone {
        {-timestamp:required}
        {-server_tz "US/Eastern"}
        {-user_tz "US/Eastern"}
        {-format "YYYY-MM-DD HH24:MI:SS"}
    } {
        return [db_string adjust_timezone {}]
    }

    ad_proc ics_timestamp_format {
        {-timestamp:required}
    } {
        the timestamp must be in the format YYYY-MM-DD HH24:MI:SS
    } {
        regsub { } $timestamp {T} timestamp
        regsub -all -- {-} $timestamp {} timestamp
        regsub -all {:} $timestamp {} timestamp
        
        append timestamp "Z"
        return $timestamp
    }

    ad_proc cal_outlook_gmt_sql {{hours 0} {dash ""}} {formats the hours to substract or add to make the date_time be in gmt} {
        # east of gmt is notated as "-",
        # in order to get gmt (to store the date_time for outlook)
        # we need to have the hour equal gmt at the same time as the client
        # i.e. if its noon gmt, then its 4am in pst
        # 
        if ![empty_string_p $dash] {
            set date_time_math "- $hours/24"
        } else {
            set date_time_math "+ $hours/24"
        }

        return $date_time_math
    }

    ad_proc -public format_item {
        {-cal_item_id:required}
        {-all_occurences_p 0}
        {-client_timezone 0}
    } {
        the cal_item_id is obvious.
        If we want all occurrences, we set all_occurences_p to true.
        
        The client timezone helps to make things right. 
        It is the number offset from GMT.
    } {
        set date_format "YYYY-MM-DD HH24:MI:SS"

        calendar::item::get -cal_item_id $cal_item_id -array cal_item
        # If necessary, select recurrence information

        # Convert some dates for timezone
        set cal_item(ansi_start_date) [adjust_timezone -timestamp $cal_item(ansi_start_date) -format $date_format -user_tz "Universal"]
        set cal_item(ansi_end_date) [adjust_timezone -timestamp $cal_item(ansi_end_date) -format $date_format -user_tz "Universal"]

        # Here we have some fields
        # start_time end_time title description
        
        # For now we don't do recurrence

        set DTSTART [ics_timestamp_format -timestamp $cal_item(ansi_start_date)]
        set DTEND [ics_timestamp_format -timestamp $cal_item(ansi_end_date)]

        # Put it together
        set ics_event "BEGIN:VCALENDAR\r\nPRODID:-//OpenACS//OpenACS 4.5 MIMEDIR//EN\r\nVERSION:2.0\r\nMETHOD:PUBLISH\r\nBEGIN:VEVENT\r\nDTSTART:$DTSTART\r\nDTEND:$DTEND\r\n"

        # Recurrence stuff
        if {![empty_string_p $cal_item(recurrence_id)] && $all_occurences_p} {

            set recur_rule "RRULE:FREQ="

            # Select recurrence info
            set recurrence_id $cal_item(recurrence_id)
            db_1row select_recurrence {} -column_array recurrence

            switch -glob $recurrence(interval_name) {
                day { append recur_rule "DAILY" }
                week { append recur_rule "WEEKLY" }
                *month* { append recur_rule "MONTHLY"}
                year { append recur_rule "YEARLY"}
            }

            if { $recurrence(interval_name) == "week" && ![empty_string_p $recurrence(days_of_week)] } {
                
                #DRB: Standard indicates ordinal week days are OK, but Outlook
                #only takes two-letter abbreviation form.

                append recur_rule ";BYDAY="
                set week_list [list "SU" "MO" "TU" "WE" "TH" "FR" "SA" "SU"]
                set sep ""
                set day_list [split $recurrence(days_of_week) " "]
                foreach day $day_list {
                    append recur_rule "$sep[lindex $week_list $day]"
                    set sep ","
                }
            }

            if { ![empty_string_p $recurrence(every_nth_interval)] } {
                append recur_rule ";INTERVAL=$recurrence(every_nth_interval)"
            }

            if { ![empty_string_p $recurrence(recur_until)] } {
                #DRB: this should work with a DATE: type but doesn't with Outlook at least.
                append recur_rule ";UNTIL=$recurrence(recur_until)"
                append recur_rule "T000000Z"
            }

            append ics_event "$recur_rule\r\n"

        }

        ns_log Notice "DTSTART = $DTSTART"
        regexp {^([0-9]*)T} $DTSTART all CREATION_DATE
        set DESCRIPTION $cal_item(description)
        set TITLE $cal_item(name)

        append ics_event "LOCATION:Not Listed\r\nTRANSP:OPAQUE\r\nSEQUENCE:0\r\nUID:$cal_item_id\r\nDTSTAMP:$CREATION_DATE\r\nDESCRIPTION:$DESCRIPTION\r\nSUMMARY:$TITLE\r\nPRIORITY:5\r\nCLASS:PUBLIC\r\n"

        append ics_event "END:VEVENT\r\nEND:VCALENDAR\r\n"

        return $ics_event
    }
        
}
