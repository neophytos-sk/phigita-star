
### Upcoming Events

#set bgcolor DEE5F2
#set fontcolor 5A6986

set location_clause "false"
set location_id [ad_conn UL_LOC]
set latitude [ns_dbquotevalue [ad_conn UL_LAT]]
set longitude [ns_dbquotevalue [ad_conn UL_LNG]]

#set location_id 29092; set longitude "33.3"; set latitude "35.15" ;# Nicosia
#set location_id 29092; set longitude "32.42"; set latitude "34.81" ;# Empa


set city_name ""
if { $location_id ne {} } {
    set ds_loc [::db::Set new \
		    -cache GEOIP.LOCATION=$location_id \
		    -pool geoipdb \
		    -from locations \
		    -where [list "id=[ns_dbquotevalue $location_id]"] \
		    -limit 1]
    $ds_loc load
    if { ![$ds_loc emptyset_p] } {
	set loc_head [$ds_loc head]
	set city_name [$loc_head set city]
    }

    set user_geom st_setsrid(st_makepoint($longitude,$latitude),4326)
    set distance [expr { 30000.0 / 111319.49 }]
    set location_clause "st_dwithin(v.geom,${user_geom},$distance)"
}
set location_clause true


set events_limit 3
set ds_events_1 [::db::Set new \
		   -pool agendadb \
		   -type [::db::Inner_Join new \
			      -lhs [::db::Set new \
					-select {
					    e.id 
					    e.event_name 
					    e.event_description 
					    e.tags_ia 
					    e.ts_vector
					    vt.venue_id 
					    vt.start_dt 
					    vt.end_dt
					} -alias evt \
					-type [::db::Inner_Join new -alias \
						   -lhs [::db::Set new \
							     -pool agendadb \
							     -alias vt \
							     -type ::agenda::Venue_Time \
							     -where [list "start_dt > current_timestamp at time zone 'Europe/Athens'" "start_dt < current_timestamp+'9 months'::interval"] \
							     -order "start_dt asc" \
							     -limit $events_limit] \
						   -rhs [::db::Set new -pool agendadb -alias e -type ::agenda::Event] \
						   -join_condition {vt.event_id=e.id}]] \
			      -rhs [::db::Set new -pool agendadb -alias v -type ::agenda::Venue] \
			      -join_condition {evt.venue_id = v.id}] \
		     -where [list "${location_clause}"] \
		     -select "venue_id venue_name venue_city event_name event_description tags_ia {date_trunc('second',evt.start_dt)  as event_start_dt_utc} {evt.id as event_id} {evt.start_dt as event_start_dt}" \
		     -order "evt.start_dt asc" \
		     -limit $events_limit]


set ds_events_2 [::db::Set new \
		   -pool agendadb \
		   -type [::db::Inner_Join new \
			      -lhs [::db::Set new \
					-select {
					    e.id 
					    e.event_name 
					    e.event_description 
					    e.tags_ia 
					    e.ts_vector
					    vt.venue_id 
					    vt.start_dt 
					    vt.end_dt
					} -alias evt \
					-type [::db::Inner_Join new -alias \
						   -lhs [::db::Set new \
							     -pool agendadb \
							     -alias vt \
							     -type ::agenda::Venue_Time \
							     -where [list "start_dt > current_timestamp at time zone 'Europe/Athens'" "start_dt < current_timestamp+'9 months'::interval"] \
							     -order "start_dt asc" \
							     -limit $events_limit] \
						   -rhs [::db::Set new -pool agendadb -alias e -type ::agenda::Event] \
						   -join_condition {vt.event_id=e.id}]] \
			      -rhs [::db::Set new -pool agendadb -alias v -type ::agenda::Venue] \
			      -join_condition {evt.venue_id = v.id}] \
		     -select "venue_id venue_name venue_city event_name event_description tags_ia {date_trunc('second',evt.start_dt)  as event_start_dt_utc} {evt.id as event_id} {evt.start_dt as event_start_dt}" \
		   -order "evt.start_dt asc" \
		   -limit $events_limit]


set COMMENT {
    set ds_events_1 [::db::Set new \
			 -pool agendadb \
			 -select "venue_id venue_name venue_city event_name event_description event_start_dt tags_ia {date_trunc('second',event_start_dt)  as event_start_dt_utc} {e.id as event_id}" \
			 -type [::db::Inner_Join new \
				    -lhs [::db::Set new -pool agendadb -alias e -type ::agenda::Event] \
				    -rhs [::db::Set new -pool agendadb -alias v -type ::agenda::Venue] \
				    -join_condition {e.venue_id=v.id}] \
			 -where [list "${location_clause}" "event_start_dt > current_timestamp" "event_start_dt < current_timestamp+'9 months'::interval"] \
			 -order "event_start_dt asc" \
			 -limit 3]
    
    set ds_events_2 [::db::Set new \
			 -alias ev2 \
			 -pool agendadb \
			 -select "venue_id venue_name venue_city event_name event_description event_start_dt tags_ia {date_trunc('second',event_start_dt)  as event_start_dt_utc} {e.id as event_id}" \
			 -type [::db::Inner_Join new \
				    -lhs [::db::Set new -pool agendadb -alias e -type ::agenda::Event] \
				    -rhs [::db::Set new -pool agendadb -alias v -type ::agenda::Venue] \
				    -join_condition {e.venue_id=v.id}] \
			 -where [list "event_start_dt > current_timestamp" "event_start_dt < current_timestamp+'9 months'::interval"] \
			 -order "event_start_dt asc" \
			 -limit 3]
}

set ds_events [::db::Set new \
		   -cache "AGENDA.TOP${events_limit}.UPCOMING_EVENTS" \
		   -pool agendadb \
		   -type [::db::Union new \
			      -lhs $ds_events_1 \
			      -rhs $ds_events_2] \
		   -order "event_start_dt asc" \
		   -limit $events_limit ]


$ds_events init_sql
#ns_log notice [$ds_events set sql]
$ds_events load

set is_local_p 0

set sysdate_ansi [clock_to_ansi [clock seconds]]

div -id events -class "pl" {
    a -href "http://agenda.phigita.net/event-add" -class action -style "color:#5a6986;font-weight:bold;"  {
	t "add event"
    }
    h2 -style "background-color:#DEE5F2;color:#5A6986;border-style:solid solid none;border-width:1px 1px medium;border-color:#ABB2C2 #DEE5F2 #5A6986" {
	t [mc Agenda "Agenda"]
    }
    div -style "border:1px solid #dee5f2;overflow:hidden;padding:5px 5px 10px;" {
	div -class "tl s" {
	    #t "\"Discover events in [ad_decode $is_local_p "0" "your area" "${city_name}"].\""
	    t "\"Discover events in your area.\""
	}
	if { [$ds_events emptyset_p] } {
	    div -style "padding:10px;" { 
		i { t -disableOutputEscaping "None Yet" }
	    }
	} else {
	    div -style "padding:10px;" {
		foreach o [$ds_events set result] {
		    set node [div -id place -class z-itm {
			div -style "width:75px;float:left;text-align:center;" { 
			    # Timezone at event location (i.e. country of venue)
			    set tz :Europe/Athens
			    t -disableOutputEscaping [::util::pretty_relative_time -timestamp_ansi [$o set event_start_dt] -sysdate_ansi $sysdate_ansi -mode_2_fmt "TODAY<br>%b %d" -mode_3_fmt "%A<br>%b %d" -days_limit 0 -tz $tz]
			}
			div -style "margin-left:80px;" {
			    a -class event-title -href "http://agenda.phigita.net/event/[$o set event_id]" {
				t [$o set event_name]
			    }
			    #t [string tolower [clock format [clock scan [$o set event_start_dt]] -format "%I:%M%p"]]
			    t [string tolower [lc_time_fmt [$o set event_start_dt] "%I:%M%p" [ad_conn locale] UTC]]
			    t " at "
			    a -href "http://agenda.phigita.net/venue/[$o set venue_id]" {
				t "[$o set venue_name] ([$o set venue_city])"
			    }
			}
		    }]
		    br -clear both
		}
		$node setAttribute class "z-itm last"
	    }
	}
	a -class "fl s i" -href "http://agenda.phigita.net/" {
	    t "more events..."
	}
    }
}
