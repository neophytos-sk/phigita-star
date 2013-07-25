source [acs_root_dir]/packages/core-platform/tcl/globalization/localization-procs.tcl

ad_page_contract {
    @author Neophytos Demetriou 
} {
    id:integer,notnull
}


set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
if { ${user_id} == 0 } {
    set admin_p f
} else {
    set admin_p [permission::permission_p -object_id ${package_id} -party_id ${user_id} -privilege admin]
}


set base ..

set ds_tags [::db::Set new \
		 -pool agendadb \
		 -alias tags \
		 -select [list "trim(xo__concatenate_aggregate('{' || label.name || '} {' || coalesce((extra->'bgcolor'),'') || '} {' || coalesce((extra->'fontcolor'),'') ||'} ' ),' ')"] \
		 -type [::db::Inner_Join new \
			    -lhs [::db::Set new -alias label -pool agendadb -type ::agenda::Event_Label] \
			    -rhs [::db::Set new -alias tag_id -from int_array_enum(tags_ia)] \
			    -join_condition "label.id=tag_id.int_array_enum"] \
		 -noinit]


set ds_venues [::db::Set new \
		   -pool agendadb \
		   -type [::db::Inner_Join new \
			      -lhs [::db::Set new -select "{(case when start_dt<CURRENT_TIMESTAMP then 't' else 'f' end) as is_past_p} *" -pool agendadb -alias vt -type ::agenda::Venue_Time -where [list event_id=[ns_dbquotevalue $id]]] \
			      -rhs [::db::Set new -pool agendadb -alias v -type ::agenda::Venue] \
			      -join_condition {vt.venue_id=v.id}] \
		   -order "vt.is_past_p,vt.start_dt"]

$ds_venues load

set ds_events [::db::Set enw \
		   -pool agendadb \
		   -type ::agenda::Event \
		   -where [list "id=[::util::dbquotevalue $id]"] \
		   -limit 1]

set data [::db::Set new \
	      -pool agendadb \
	      -viewFields [list $ds_tags] \
	      -type $ds_events \
	      -noinit]



$data load

if { [$data emptyset_p] } {
    rp_returnnotfound
    return
}

set evt [$data head]

### HERE: FIX FIX FIX
set u ""
if { 0 } {
    set userinfo [::db::Set new \
		      -pool main \
		      -select "* {first_names || ' ' || last_name as full_name}" \
		      -type CC_Users \
		      -where [list "user_id=[ns_dbquotevalue [$o set creation_user]]"]]
    $userinfo load
    set u [$userinfo head]
}

set title "[$evt set event_name]"
set keywords [join "Event [::xo::fun::filter [$evt set tags] x { $x ne {} }]" {,}]

::tmpl::master -docStyleId doc -docStyleClass "z-t5" -title $title -meta_keywords $keywords -meta_description $title -context_bar [ad_context_bar "One Event"] -defaultSearchAction ${base} -searchButtonsScript [subst -nocommands -nobackslashes {
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
	.name {font-size:24px;font-weight:bold;}
	#bd h1 {font-size: 24px;color: #333;padding: 0;margin: 0 10px 5px 0;}
	#bd .edit img, #performer .edit img {padding-left: 15px;white-space: nowrap;}
	#bd .edit, #performer .edit {font-size: 12px;}
	#eventMetadata .date {color:#666;font-size:10px;}
	#eventMetadata .time {font-size:10px;}
	#eventMetadata .category, #eventMetadata .homepage, #eventMetadata .performers, #performerMetadata .homepage {color: #3a3a3a;padding-bottom: 18px;}
	#eventMetadata .occurrence {margin-top:10px;}
	#eventMain .description, #performerMain .description {font-family: verdana;padding: 0px 30px 10px 0px;line-height: 1.4em;overflow: hidden;}
	#performerMain .description p {margin-bottom: 0.5em;}
	#eventMain .linked_by, #eventMain .linked_by a, #performerMain .linked_by, #performerMain .linked_by a {color: #a0a0a0;}
	#eventMain .byline {position: relative;color: #696969;font-size: 12px;}
	#bd .mapping {position: relative;color: #696969;font-size: 12px;padding-top: 10px;}
	#bd .directions {font-size: 10px;}
	#bd .fn {padding-bottom: 5px;}
	#bd .fn a {font-size:10px;text-decoration: underline;}
	#bd .venue {font-size:10px;padding-bottom: 14px;}
	#bd .additionalInfo {float: right;}
	#bd .map {width: 180px;float: right;}
	#bd #officialPhotos { border: 1px solid #333; }
	#bd #officialPhotos img { display:block; }
	#bd #mapContainer {border: 1px solid #bccacf;}
	#bd .directions {font-size: 10px;}
	#bd .venueRelated, #bd .eventRelated {padding: 0px 0px 8px 0px;}
	.eventRelated td, .venueRelated td {font-size: 11px;padding: 6px 0px 6px 0px;border-bottom: 1px solid #ccc;margin: 0px;}
	.eventTally {float: right;font-weight: bold;text-align: center;}
	#eventAttendance label {margin: 10px;}
	div.eventSidebar #userlist {margin-top: 100px;margin-bottom: 10px;width: 278px;}
	#userlistExpand {border-top: 1px solid #ccc;margin-top: 5px;text-align: right;clear: both;}
	#userlistExpandBusy {float: right;padding-right: 4px;}
	#userlistExpand .tab {float: right;padding: 0px 8px 2px 8px;color: #666;}
	div.eventSidebar .userlist .title {padding-top: 5px;}
	#userlistAttend, #userlistWatch {overflow: hidden;width: 136px;white-space: nowrap;}
	#userlistAttend {float: left;}
	#eventSidebar .guest {font-weight: bold;margin: 0px 2px 0px 2px;color: #fe8200;}
	#eventSidebar {width: 280px;margin-top: 0px;margin-left: 10px;float: left;}
	#performerSidebar {width: 298px;margin-left: 614px;margin-top: 20px;}
	.insetTitle {font-size: 16px;color: #666;padding-top: 12px;padding-bottom: 4px;}
	#eventToolbar {margin-top: 18px;margin-bottom: 12px;font-size: 12px;font-weight: bold;clear: right;}
	#eventToolbar div {margin-bottom: 6px;}
	#eventTags {margin-bottom: 15px;}
	#eventGroups ul {padding: 0;margin: 0;}
	#eventGroups li {margin: 0;padding: 0;list-style-type: none;}
	#eventTags a {font-size: 12px;}
	#eventComments {margin: 30px 0 0 0;width:100%;float:left;clear:both;}
	#eventComments #addcomments .heading {font-size: 14px;padding-bottom: 5px;}
	.comment {margin: 0px 0px 15px 60px;width: 350px;}
	.commentBody {font-family: verdana;}
	div.bylineReport {width: 620px; /* #eventMetadata width incl. padding */}
	.byline {color: #666;font-weight: normal;font-size: 12px;padding-bottom: 5px;}
	div.bylineReport .byline {float: left;}
	div.bylineReport .reportProblem {float: right;padding-right: 10px;}
	.byline a {font-weight: bold;}
	.date {font-weight: normal;font-size: 10px;}
	#eventPhotos {margin: 0 0 10px 15px;padding-right: 5px;width: 170px;float: right;}
	#photo_container {width:100%;margin:0;padding:0;float:right;}
	#eventPhotos .photo {float:left;margin-bottom: 8px;padding-right: 8px;}
	#eventPhotos .photo img { border: 1px solid #000; }
	#eventMain .heading {padding-bottom: 10px;}
	#bd   .label, #performer .label {font-size:110%;color: #ff9933;font-weight:bold;}
	#bd .rsvpTools {border: 1px solid #dcc57f;background-color: #fffdf6;padding: 0px 10px 10px 10px;width: 400px;}
	    #bd .ads {float:right;padding:0px;}
	    #bd b b b {
		border-width:0pt;
		margin:0pt;
		padding:1px 5px;
	    }
	    #bd b b {
		background:transparent none repeat scroll 0%;
		border-width:0pt 1px;
		margin:0pt -1px;
		padding:0pt;
	    }

	    #bd b {
		border-color:-moz-use-text-color;
		border-style:solid;
		border-width:1px 0pt;
		font-weight:normal;
		margin:0pt 1px;
		padding:0pt;
	    }
	    .tags {padding-top:2px;}
	#bd a {color:#3A64C3;text-decoration:none;}
	#bd a:hover {color:#2565F7;text-decoration:underline;}
    }

    div -id hd -class vevent {
	h3 {
	    span -class "name summary" { t [$evt set event_name] }
	}
    }
	div -id bd {
	    div -id z-main {
		div -class z-b {
		    div -class "z-g" {
			
			if { $admin_p } {
			    t \[
			    a -href "../admin/occurrence-add?id=$id" {
				t "Add Occurrence"
			    }
			    t \]
			}
			div -class "label" {
			    t Description
			}
			div -class "description" {
			    t -disableOutputEscaping [text_to_html [$evt set event_description]]
			}
			if { [$evt set tags_ia] ne {} } {
			    div -class "label" { t Tags }
			    div -class "category" { 
				div -class tags {
				    set j 0
				    set ntags [expr { [llength [$evt set tags]] / 3 }]
				    foreach {tagName bgcolor fontcolor} [$evt set tags] {
					if { $bgcolor eq {} } {
					    set bgcolor DEE5F2
					    set fontcolor 5A6986
					}
					b -style "border-color:\#${bgcolor};background-color:\#${bgcolor};" {
					    b -style "border-color:\#${bgcolor};background-color:\#${bgcolor};" {
						a -style "color:\#${fontcolor};border:none;" -href ${base}/tag/${tagName} {
						    t $tagName
						}
					    }
					}
					if { [incr j] != $ntags } { t " " }
				    }
				}
			    }
			}
			br
			if { [$evt set event_url] ne {} } {
			    div -class "label" { t Homepage }
			    div -class "homepage" {
				a -class url -href [$evt set event_url] -rel nofollow {
				    t [$evt set event_url]
				}
			    }
			}
		    }
		}
		if { $u ne {} } {
		    div -class "bylineReport" {
			div -class "byline" {
			    t "Added by "
			    a -href http://www.phigita.net/~[$u set screen_name]/ {
				t [$u set full_name]
			    }
			    span
			    t "on [lc_time_fmt [$evt set creation_date] %q]"
			}
			div -style "height: 0px; clear: both;"
		    }
		}
	    }
	    div -class z-b {
		div -id eventMain {
		    div {
			div -class label { t "Sponsored Links" }
			br
			div -class ads {
			    ::xo::google::adsense::slot 7142290762 234 60
			}
		    }
		    div -style "margin-top:10px;background:\#fcfcfc;" {
			div -class "label" { t "Where & When" }
			div -id  eventMetadata {
			    set is_past_p ""
			    foreach o [$ds_venues set result] {
				if { [$o set is_past_p] ne ${is_past_p} } {
				    set is_past_p [$o set is_past_p]
				    br 
				    span -style "color:green;" {
					if { $is_past_p } {
					    t "\[Past Events\]"
					} else {
					    t "\[Upcoming Events\]"
					}
				    }
				}
				div -class "occurrence" {
				    div -class date {
					abbr -class "dtstart" -title  [lc_time_fmt [$o set start_dt] "%Y%M%dT%H%m%S"] {
					    t [lc_time_fmt [$o set start_dt] "%Q"]
					}
				    }
				    span -class time {
					t " [lc_time_fmt [$o set start_dt] "%l:%M%p"]"
				    }
				    t " - "
				    span -class "venue location vcard" {
					span -class "fn org" {
					    a -href "../venue/[$o set venue_id]" {
						t [$o set venue_name]
					    }
					}
					t ", "
					span -class "locality" {
					    t [$o set venue_city]
					}
					t ", "
					span -class "region" {
					    t [$o set venue_country]
					}
				    }
				}
			    }
			}
		    }
		}
	    }
	}
    }
