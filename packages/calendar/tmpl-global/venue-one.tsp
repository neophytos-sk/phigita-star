ad_page_contract {
    @author Neophytos Demetriou 
} {
    id:integer,notnull
}
set base ..
set events_limit 25
set data [::db::Set new \
	      -pool agendadb \
	      -select "* {st_x(geom) as geom_x} {st_y(geom) as geom_y}" \
	      -type ::agenda::Venue \
	      -where [list id=[ns_dbquotevalue $id]] \
	      -limit 1]

$data load

if { [$data emptyset_p] } {
    rp_returnnotfound
    return
}

set venue [$data head]



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
						   -lhs [::db::Set new -pool agendadb -alias vt -type ::agenda::Venue_Time -where [list "start_dt > current_timestamp" "start_dt < current_timestamp+'9 months'::interval"]  -where [list "venue_id=[ns_dbquotevalue $id]"] -limit $events_limit] \
						   -rhs [::db::Set new -pool agendadb -alias e -type ::agenda::Event] \
						   -join_condition {vt.event_id=e.id}]] \
			      -rhs [::db::Set new -pool agendadb -alias v -type ::agenda::Venue] \
			      -join_condition {evt.venue_id = v.id}] \
		   -select "* {date_trunc('second',evt.start_dt)  as event_start_dt_utc} {evt.id as event_id} {evt.start_dt as event_start_dt}" \
		   -order "evt.start_dt asc" \
		   -limit $events_limit]


set upcoming_events_data [::db::Set new \
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
			-where [list "venue_id=[ns_dbquotevalue $id]" "event_start_dt < current_timestamp"] \
			-order "event_start_dt desc" \
			-limit $events_limit]


set past_events_data [::db::Set new \
	      -pool agendadb \
	      -viewFields [list $ds_tags] \
	      -type $ds_past_events \
	      -noinit]




$upcoming_events_data load
$past_events_data load


set title "[$venue set venue_name], [$venue set venue_city], [$venue set venue_country]"
set keywords "Venue, [$venue set venue_city], [$venue set venue_country]"
::tmpl::master -onload "InitMap();" -docStyleClass z-t6 -title $title  -context_bar [ad_context_bar "One Venue"] -meta_description $title -meta_keywords $keywords  -defaultSearchAction ${base} -searchButtonsScript [subst -nocommands -nobackslashes {
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

#border-bottom:1px solid #CCCCCC;
    ::xo::html::add_style {
	.name {font-size:24px;font-weight:bold;width:600px;}
	#venue .fn, #performer .n {font-size: 24px;font-weight: bold;}
	#venue .map {border: 1px solid #bccacf;width: 230px;margin: 10px 0px 0px 0px;}
	#venue .directions {font-size: 10px;}
	.z-itm {height:60px;margin:5;padding:5;}
	.z-itm b b b {border-width:0pt;margin:0pt;padding:1px 5px;}
	.z-itm b b {background:transparent none repeat scroll 0%;border-width:0pt 1px;margin:0pt -1px;padding:0pt;}
	.z-itm b {border-color:-moz-use-text-color;border-style:solid;border-width:1px 0pt;font-weight:normal;margin:0pt 1px;padding:0pt;}
	#place .event-title {display: block;font-size: 14px;font-weight: bold;margin-bottom: 2px;}
	#place a {color:#3A64C3;text-decoration:none;}
	#place a:hover {color:#2565F7;text-decoration:underline;}
	#venue .small, #performer .small {font-size: 10px;text-transform: uppercase;color: #666;}
	#copyright {font-size:10px;position: absolute;right: 3px;bottom: 3px;z-index: 2;}
	#map_canvas a {text-decoration: none;font-family: arial;font-size: 10px;color:#000033;}
	#map_canvas a:link {}
	#map_canvas a:hover {}
	#map_canvas a:active {}
	#map_canvas a:visited {}

    }


    div -id "bd" {
	div -id "z-main" {
	    div -class "z-b" {
		div -class "z-g" {

		    div -id venue -class "location vcard" {
			span -class "fn org" {
			    t [$venue set venue_name]
			}
			br
			div -class "address adr" {
			    span -class "street-address" { t [$venue set venue_address] }
			    br
			    span -class "locality" {
				t [$venue set venue_city]
			    }
			    t " "
			    span -class "postal-code" {
				t [$venue set venue_postal_code]
			    }
			    t ", "
			    span -class "region" {
				t [$venue set venue_country]
			    }
			    br
			    span -class "tel" { t [$venue set venue_phone] }
			    if { [$venue set venue_description] ne {} } {
				br
				br
				span -class small { t Description }
				br
				span -class "description" { t -disableOutputEscaping [text_to_html [$venue set venue_description]] }
			    }
			    if { [$venue set venue_homepage_url] ne {} } {
				br
				br
				span -class small { t Homepage }
				br
				span -class "homepage" {
				    a -class url -href [$venue set venue_homepage_url] -rel nofollow { t [$venue set venue_homepage_url] }
				}
			    }
			}
		    }


		    if { ![$upcoming_events_data emptyset_p] } {
			h1 { t "Upcoming Events" }
		    }

		    set sysdate_ansi [clock_to_ansi [clock seconds]]
		    foreach o [$upcoming_events_data set result] {
			div -id place -class z-itm {
			    div -style "width:75px;float:left;text-align:center;" { 
				t -disableOutputEscaping [::util::pretty_relative_time -timestamp_ansi [$o set event_start_dt] -sysdate_ansi $sysdate_ansi -mode_2_fmt "TODAY<br>%b %d" -mode_3_fmt "%A<br>%b %d" -days_limit 1]
			    }
			    div -style "margin-left:80px;" {
				a -class event-title -href "${base}/event/[$o set event_id]" {
				    t [$o set event_name]
				}
				t [string tolower [lc_time_fmt [$o set event_start_dt] %I:%M%p]]
				t " at "
				a -href "${base}/venue/[$o set venue_id]" {
				    t "[$venue set venue_name] ([$venue set venue_city])"
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
			}
		    }



		    if { ![$past_events_data emptyset_p] } {
			h1 { t "Past Events" }
		    }

		    set sysdate_ansi [clock_to_ansi [clock seconds]]
		    foreach o [$past_events_data set result] {
			div -id place -class z-itm {
			    div -style "width:75px;float:left;text-align:center;" { 
				t -disableOutputEscaping [::util::age_pretty -timestamp_ansi [$o set event_start_dt] -sysdate_ansi $sysdate_ansi -mode_2_fmt "%A<br>%b %d" -mode_3_fmt "%A<br>%b %d, %Y" -days_limit 1]
			    }
			    div -style "margin-left:80px;" {
				a -class event-title -href "${base}/event/[$o set event_id]" {
				    t [$o set event_name]
				}
				t [string tolower [lc_time_fmt [$o set event_start_dt] %I:%M%p]]
				t " at "
				a -href "${base}/venue/[$o set venue_id]" {
				    t [$venue set venue_name]
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
			}
		    }
		}
	    }
	}
	div -class z-b {
	    div -class ads {
		::xo::google::adsense::slot 7142290762 234 60
	    }

	    if { [$venue set geom] ne {} } {
		set lon [$venue set geom_x]
		set lat [$venue set geom_y]
		set s 7500
		div -id map_canvas -style "position:relative;width:300px;height:300px;" {
		    div -id "copyright" { 
			t -disableOutputEscaping {&copy;2008 <a target="_blank" href="http://www.phigita.net/">phigita.net</a> - Map data &copy;2008 <a target="_blank" href="http://www.openstreetmap.com/">OpenStreetMap</a>}
		    }
		}
		script -type text/javascript -src http://maps.phigita.net/lib/data/kaMap-all.js
		script -type text/javascript {
		    t -disableOutputEscaping [subst -nocommands -nobackslashes {
			    aszScales=new Array(30000000,15000000,7500000,3000000,1500000,750000,300000,100000,30000,7500,3000,1500);
			    nScale=300000;
			    nCurrentLeft=0;
			    nCurrentTop=0;
			    aMapFiles = new Array();
			var map;
			var myKaMap = myKaNavigator = myKaZoomer = null;
			function InitMap() {
			    initDHTMLAPI();
			    myKaMap = new kaMap('map_canvas');

			    myKaNavigator = new kaNavigator( myKaMap );
			    myKaNavigator.activate();

			    //    myKaQuery = new kaQuery( myKaMap, KAMAP_RECT_QUERY );
			    myKaZoomer = new kaZoomer(myKaMap);
			    //drawPage();



			    //myKaMap.initialize();


			    myKaMap.initializationState=2;
			    map = new _map( 'gmap', 'gmap', 0, 5, aszScales);
			    map.setDefaultExtents(-0.23810862660315682, -0.23810862660315682, 0.23810862660315682, 0.23810862660315682);
			    map.addLayer( new _layer( '__base__', true, 100 ) );
			    map.resolution = 72.0;
			    myKaMap.addMap( map );
			    myKaMap.tileWidth=256;
			    myKaMap.tileHeight=256;
			    myKaMap.server = 'http://maps.phigita.net/';
			    myKaMap.tileURL='tile';
			    s=7500;
			    myKaMap.selectMap('gmap');
			    map.aZoomTo=new Array('${lon},${lat},7500');
			    myKaMap.zoomTo(${lon},${lat},7500);
			    AddVenueMarker(${lon},${lat});
			}
			function AddVenueMarker(lon,lat) {
			    var myCanvas = myKaMap.createDrawingCanvas(1000);
			    var marker = document.createElement('img');
			    /* mw = marker.width */
			    var mw=15;
			    /* mh = marker.height */
			    var mh=26;
			    marker.src='/graphics/marker.png';
			    marker.xOffset = -Math.floor(mw/2);
			    marker.yOffset = -mh;
			    myKaMap.addMarkerGeo(myCanvas,lon,lat,marker,0,0);
			}
			}]
		}
	    }
	}
    }

}