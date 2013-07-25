##source [acs_root_dir]/packages/kernel/tcl/00-utilities/pretty-date-procs.tcl
ad_page_contract {
    @author Neophytos Demetriou
} {
    {tag:trim ""}
    {q:trim,optional ""}
}


set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
if { ${user_id} == 0 } {
    set admin_p f
} else {
    set admin_p [permission::permission_p -object_id ${package_id} -party_id ${user_id} -privilege admin]
}


set now_seconds [ns_time]
set events_limit 25
set ds_tags [::db::Set new \
		 -pool agendadb \
		 -alias tags \
		 -select [list "trim(xo__concatenate_aggregate('{' || label.name || '} {' || coalesce((extra->'bgcolor'),'') || '} {' || coalesce((extra->'fontcolor'),'') ||'} ' ),' ')"] \
		 -type [::db::Inner_Join new \
			    -lhs [::db::Set new -alias label -pool agendadb -type ::agenda::Event_Label] \
			    -rhs [::db::Set new -alias tag_id -from int_array_enum(tags_ia)] \
			    -join_condition "label.id=tag_id.int_array_enum"] \
		 -noinit]

set ds_events [::db::Set new \
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
							     -where [list "start_dt > current_timestamp  at time zone 'Europe/Athens'" "start_dt < current_timestamp+'9 months'::interval"] \
							     -order "start_dt asc" \
							     -limit $events_limit] \
						   -rhs [::db::Set new -pool agendadb -alias e -type ::agenda::Event] \
						   -join_condition {vt.event_id=e.id}]] \
			      -rhs [::db::Set new -pool agendadb -alias v -type ::agenda::Venue] \
			      -join_condition {evt.venue_id = v.id}] \
		   -select "* {date_trunc('second',evt.start_dt)  as event_start_dt_utc} {evt.id as event_id} {evt.start_dt as event_start_dt}" \
		   -order "evt.start_dt asc" \
		   -limit $events_limit]


set data [::db::Set new \
	      -pool agendadb \
	      -viewFields [list $ds_tags] \
	      -type $ds_events \
	      -noinit]

set ds_past_events [::db::Set new \
		   -pool agendadb \
		   -type [::db::Inner_Join new \
			      -lhs [::db::Set new -pool agendadb -alias e -type ::agenda::Event] \
			      -rhs [::db::Set new -pool agendadb -alias v -type ::agenda::Venue] \
			      -join_condition {e.venue_id=v.id}] \
		   -select "* {date_trunc('second',event_start_dt)  as event_start_dt_utc} {e.id as event_id}" \
		   -where [list "event_start_dt < current_timestamp  at time zone 'Europe/Athens'"] \
		   -order "event_start_dt desc" \
		   -limit $events_limit]


set past_events_data [::db::Set new \
	      -pool agendadb \
	      -viewFields [list $ds_tags] \
	      -type $ds_past_events \
	      -noinit]


set context ""
if { $tag ne {} } {
    set base ..
    set tagdata [::db::Set new \
	-pool agendadb\
	-select "id" \
	-type ::agenda::Event_Label \
	-where [list "name=[::util::dbquotevalue $tag]"] \
	-limit 1]
    $tagdata load
    if { ![$tagdata emptyset_p] } {
        set tag_id [[$tagdata head] set id]
    } else {
        set tag_id 0
    }
    $ds_events lappend where "tags_ia @> '\{$tag_id\}'"
    $ds_past_events lappend where "tags_ia @> '\{$tag_id\}'"
    set base ..
    set context "Tag: $tag"
} else {
    set base .
}


### Search Events
if { $q ne {} } {
    set tmplist ""
    foreach word [split $q {-,. }] {
	lappend tmplist [::ttext::trigrams [string tolower [::ttext::unac utf-8 [::ttext::ts_clean_text $word]]]]
    }
    set trigrams [join $tmplist]
    set plainQuery [join [::xo::fun::map x $trigrams {  string map {{'} {\'} {"} {\"} \\ \\\\ { } {\ } {,} {\,}} $x }] {&}]
    set tsQuery "[::util::dbquotevalue $plainQuery]::tsquery"
    $ds_events lappend where "evt.ts_vector @@ $tsQuery"
    $ds_past_events lappend where "e.ts_vector @@ $tsQuery"
    set context "Searched for $q"
}


$data load
$past_events_data load

if { $context eq {} } {
    set context_bar [ad_context_bar]
} else {
    set context_bar [ad_context_bar ${context}]
}
set title "Upcoming Events - Agenda"
set description "Agenda is a service for discovering and sharing events. It can help you find stuff to do, discover what your friends are doing, or let you keep private events online for your own reference."
set keywords "Upcoming Events, Agenda, Venues"
::tmpl::master -docStyleId doc3 -docStyleClass z-t2 -title $title -meta_description $description -meta_keywords $keywords -context_bar ${context_bar}  -searchQuery ${q} -defaultSearchAction ${base} -searchButtonsScript [subst -nocommands -nobackslashes {
	center {
	    input -type submit -value [mc Search_Events "Search Events"] -tabindex 2
	    input -type submit -value [mc Search_the_Web "Search the Web"] -tabindex 3 -onclick "return searchTheWeb();"
	}
}] {

    script -language javascript {
	c {
	    function searchTheWeb(){
		var sf=document.createElement('form');
		var q=document.createElement('input');
		sf.style.cssText='display:none;';
		sf.setAttribute('action','http://www.phigita.net/search/');
		sf.setAttribute('method','GET');
		q.setAttribute('name','q');
		q.setAttribute('type','text');
		q.value=document.getElementById('sf').q.value;
		document.body.appendChild(sf);
		sf.appendChild(q);
		sf.submit();
		return false;			
	    }
	}
    } 

    ::xo::html::add_style {
	.z-itm {margin:5;padding:5;border-bottom:1px solid #CCCCCC;}
	.z-itm b b b {border-width:0pt;margin:0pt;padding:1px 5px;}
	.z-itm b b {background:transparent none repeat scroll 0%;border-width:0pt 1px;margin:0pt -1px;padding:0pt;}
	.z-itm b {border-color:-moz-use-text-color;border-style:solid;border-width:1px 0pt;font-weight:normal;margin:0pt 1px;padding:0pt;}
	#place .event-title {display: block;font-size: 14px;font-weight: bold;margin-bottom: 2px;}
	#place a {color:#3A64C3;text-decoration:none;}
	#place a:hover {color:#2565F7;text-decoration:underline;}
    }

	div -id "bd" {
	    div -id "z-main" {
		div -class "z-b" {
		    div -class "z-gc" {
			div -class "z-u first" {

			    if { ![$data emptyset_p] } {
				h1 { t "Upcoming Events" }
			    }

			    set sysdate_ansi [clock_to_ansi [clock seconds]]
			    foreach o [$data set result] {
				div -id place -class z-itm {
				    div -style "width:75px;float:left;text-align:center;" { 
					t -disableOutputEscaping [::util::pretty_relative_time -timestamp_ansi [$o set event_start_dt] -sysdate_ansi $sysdate_ansi -mode_2_fmt "TODAY<br>%b %d" -mode_3_fmt "%A<br>%b %d" -days_limit 0 -hours_limit 12]
				    }
				    div -style "margin-left:80px;" {
					a -class event-title -href "${base}/event/[$o set event_id]" {
					    t [$o set event_name]
					}
					#t [string tolower [lc_time_fmt [$o set event_start_dt] %I:%M%p]]
					t [string tolower [lc_time_fmt [$o set event_start_dt] "%I:%M%p" [ad_conn locale] UTC]]
					t " at "
					a -href "${base}/venue/[$o set venue_id]" {
					    t "[$o set venue_name] ([$o set venue_city])"
					}
					br
					if { [$o set tags_ia] ne {} } {
					    div -style "padding-top:2px;" {
						span -class small { t "Tags: " }
						set j 0
						set ntags [expr { [llength [$o set tags]] / 3 }]
						foreach {tagName bgcolor fontcolor} [$o set tags] {
						    if { $bgcolor eq {} } {
							set bgcolor DEE5F2
							set fontcolor 5A6986
						    }
						    b -style "border-color:\#${bgcolor};background-color:\#${bgcolor};" {
							b -style "border-color:\#${bgcolor};background-color:\#F2F2F2;" {
							    a -style "color:\#${fontcolor};border:none;font-size:10px;" -href ${base}/tag/${tagName} {
								t $tagName
							    }
							}
						    }
						    if { [incr j] != $ntags } { t " " }
						}
					    }
					}
				    }
				    br -clear both
				}
			    }
			}

			### SECOND COLUMN
			div -class "z-u" {
			    if { ${admin_p} } {
				t "\["
				a -class fl -href admin/ {
				    t "Admin"
				}
				t "\]"
			    }

			    if { ![$past_events_data emptyset_p] } {
				h1 { t "Past Events" }
			    }

			    set sysdate_ansi [clock_to_ansi [clock seconds]]
			    foreach o [$past_events_data set result] {
				div -id place -class z-itm -style "border:none;" {
				    div -style "width:75px;float:left;text-align:center;" { 
					# Change tz to reflect the time at venue/place/location of event
					set tz :Europe/Athens
					t -disableOutputEscaping [::util::pretty_relative_time -timestamp_ansi [$o set event_start_dt] -sysdate_ansi $sysdate_ansi -mode_2_fmt "%A<br>%b %d" -mode_3_fmt "%A<br>%b %d, %Y" -days_limit 1 -tz $tz]
				    }
				    div -style "margin-left:80px;" {
					a -class event-title -href "${base}/event/[$o set event_id]" {
					    t [$o set event_name]
					}
					#t [string tolower [lc_time_fmt [$o set event_start_dt] %I:%M%p]]
					t [string tolower [lc_time_fmt [$o set event_start_dt] "%I:%M%p" [ad_conn locale] UTC]]
					t " at "
					a -href "${base}/venue/[$o set venue_id]" {
					    t [$o set venue_name]
					}
					br
					if { [$o set tags_ia] ne {} } {
					    div -style "padding-top:2px;" {
						span -class small { t "Tags: " }
						set j 0
						set ntags [expr { [llength [$o set tags]] / 3 }]
						foreach {tagName bgcolor fontcolor} [$o set tags] {
						    if { $bgcolor eq {} } {
							set bgcolor DEE5F2
							set fontcolor 5A6986
						    }
						    b -style "border-color:\#${bgcolor};background-color:\#${bgcolor};" {
							b -style "border-color:\#${bgcolor};background-color:\#F2F2F2;" {
							    a -style "color:\#${fontcolor};border:none;font-size:10px;" -href ${base}/tag/${tagName} {
								t $tagName
							    }
							}
						    }
						    if { [incr j] != $ntags } { t " " }
						}
					    }
					}
				    }
				    br -clear both
				}
			    }
			}




		    }
		}

	    }


	    # YOUR NAVIGATION GOES HERE
	    div -class z-b {
		p
		div -style "text-align:center;" {
		    a -class fl -href "${base}/event-add" -style "font-size:24px;font-weight:bold;" {
			t "Add Event"
		    }
		    br
		    b { t "Send Feedback: " }
		    br
		    img -src /graphics/53dab96f0fd8087a4110eb0174b4cfbb.png
		}
		div -style "margin:0;padding:0;" {		
		    ::xo::google::adsense::slot 7660433051 180 150
		}
		div -style "margin:10;padding:0;" {
		    ::xo::google::adsense::slot 8462618994 160 600
		}
	    }


	}
    }
