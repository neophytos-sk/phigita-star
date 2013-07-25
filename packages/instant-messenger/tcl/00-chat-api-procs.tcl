if { ![ns_config ns/server/[ns_info server] is_chat_p 0] } { return }

ad_library {
  generic chat - chat procs

  @creation-date 2006-02-02
  @author Gustaf Neumann
  @cvs-id $Id: chat-procs.tcl,v 1.10 2006/04/09 00:09:51 gustafn Exp $  
}

namespace eval ::xo {
  Class Message -parameter {time user_id msg color}
  Class Chat -superclass ::xo::OrderedComposite \
      -parameter {chat_id user_id session_id {mode default}
	{encoder urlencode} {timewindow 600} {sweepinterval 30}
      }

  Chat instproc init {} {
    my instvar array
    # my log "-- "
    my set now [clock clicks -milliseconds]
    if {![my exists user_id]}    {my set user_id [ad_conn user_id]}
    if {![my exists session_id]} {my set session_id [ad_conn session_id]}
    set cls [my info class]
    set array $cls-[my set chat_id]
    if {![nsv_exists $cls initialized]} {
	#my log "-- initialize $cls"
	nsv_array set $array-login {}
	nsv_set $array-count current 0
      $cls initialize_nsvs
      nsv_set $cls initialized \
	  [ad_schedule_proc -thread "t" [my sweepinterval] $cls sweep_all_chats]
    }
    if {![nsv_exists $array-seen newest]} {nsv_set $array-seen newest 0}
    if {![nsv_exists $array-color idx]}   {nsv_set $array-color idx 0}
    my init_user_color
  }

  Chat instproc add_msg {{-get_new:boolean true} -uid msg} {
      my instvar array now

      set user_id [expr {[info exists uid] ? $uid : [my set user_id]}]
      set color   [my user_color $user_id]
      #set msg     [my encodeURIComponent $msg]
      #my log "-- msg=$msg"
      set seconds [clock seconds]


      if {$get_new && [info command ::thread::mutex] ne {}} { 
	  # we could use the streaming interface
	  my broadcast_msg [Message new -volatile -time $seconds  \
				-user_id $user_id -msg $msg -color $color]
      }

      #set timeshort [clock format $seconds -format {[%H:%M:%S]}]
      #set msg_id ${timeshort}.$now.$user_id
      set msg_id [nsv_incr $array-count current 1]


      if { ![nsv_exists $array-login $user_id] } {
	  nsv_set $array-login $user_id 1 ;# HERE [clock seconds]
	  #ns_log notice "$user_id not logged in and trying to add_msg"
      }


      if { [nsv_array exists $array-last-activity] } {
	  if { [nsv_exists $array-last-activity $user_id] } {
	      if { [nsv_exists $array-status $user_id] } {
		  if { [nsv_get $array-status $user_id] eq {idle} } {
		      messenger change_user_status $user_id available
		      messenger send_to_subscriber chat-[my chat_id] [subst -nocommands {{'presence': [{'user_id':'$user_id', 'status': 'available'}]\n}}]
		  }
	      }
	  }
      }

      #my log "-- ending"
      array set messages [nsv_array get $array]
      foreach key [lrange [lsort -integer [array names messages]] 0 end-100] {
	  nsv_unset $array $key
      }

      nsv_set $array $msg_id [list $now [clock seconds] $user_id $msg $color]
      nsv_set $array-seen newest $now
      nsv_set $array-seen last [clock seconds]
      nsv_set $array-last-activity $user_id $now
      # this in any case a valid result, but only needed for the polling interface
      if {$get_new} {my get_new}
  }

  Chat instproc current_message_valid {} {
    expr { [my exists user_id] && [my set user_id] != -1 }
  }
  
  Chat instproc active_user_list {} {
    nsv_array get [my set array]-login
  }
  
  Chat instproc nr_active_users {} {
      expr { [llength [nsv_array get [my set array]-login]] / 2 }
  }
  
  Chat instproc last_activity {} {
    if { ![nsv_exists [my set array]-seen last] } { return "-" }
    return [clock format [nsv_get [my set array]-seen last] -format "%d.%m.%y %H:%M:%S"]
  }
  
    Chat instproc check_age {key ago} {
	my instvar array timewindow
	if {$ago > $timewindow} {
	    #nsv_unset $array $key
	    #my log "--c unsetting $key"
	    return 0
	}
	return 1
    }

  Chat instproc get_new {} {
    my instvar array now session_id
    set last [expr {[nsv_exists $array-seen $session_id] ? [nsv_get $array-seen $session_id] : 0}]
    if {[nsv_get $array-seen newest]>$last} {
      #my log "--c must check $session_id: [nsv_get $array-seen newest] > $last"
      foreach {key value} [nsv_array get $array] {
	foreach {timestamp secs user msg color} $value break
	if {$timestamp > $last} {
	  my add [Message new -time $secs -user_id $user -msg $msg -color $color]
	} else {
	  my check_age $key [expr {($now - $timestamp) / 1000}]
	}
      }
      nsv_set $array-seen $session_id $now
      #my log "--c setting session_id $session_id: $now"
    } else {
      #my log "--c nothing new for $session_id"
    }
    my render
  }

  Chat instproc get_all {} {
    my instvar array now session_id
    foreach {key value} [nsv_array get $array] {
      foreach {timestamp secs user msg color} $value break
      if {[my check_age $key [expr {($now - $timestamp) / 1000}]]} {
	my add [Message new -time $secs -user_id $user -msg $msg -color $color]
      }
    }
    #my log "--c setting session_id $session_id: $now"
    nsv_set $array-seen $session_id $now
    my render
  }

    Chat instproc adjust_buffer_size {} {
	messenger adjust_buffer_size [my session_id]
    }

  Chat instproc sweeper {} {
      my instvar array now user_id


      set newest_timestamp [nsv_get $array-seen newest]
      set newest_ago [expr {($now - $newest_timestamp)/1000}]
      set ping_p [expr { $newest_ago > 30 }]
      #set last_message_id

      #my log "-- starting"
      foreach {user timestamp} [nsv_array get $array-last-activity] {
	  #ns_log Notice "chat sweeper: YY at user $user with $timestamp"
	  set ago [expr {($now - $timestamp) / 1000}]
	  #ns_log Notice "YY Checking: now=$now, timestamp=$timestamp, ago=$ago"
	  # was 1200 HERE: idle
	  if {$ago > 300} { 
	      if { [nsv_exists $array-status $user] } {
		  if { [nsv_get $array-status $user] eq {available} } {
		      messenger change_user_status $user idle
		      messenger send_to_subscriber chat-[my chat_id] [subst -nocommands {{'presence': [{'user_id':'$user', 'status': 'idle'}]\n}}]
		      set ping_p false
		  }
	      }
	      #my add_msg -get_new false -uid $user "idle" 
	      #nsv_unset $array-last-activity $user 
	      #nsv_unset $array-login $user
	      #nsv_unset $array-color $user
	  }
      }
      #my log "-- ending"

      if { $ping_p } { messenger ping_all }


      array set messages [nsv_array get $array]
      foreach key [lrange [lsort -integer [array names messages]] 0 end-100] {
	  nsv_unset $array $key
      }

  }

    Chat instproc status {status} {
	my instvar array
	set user_id [ad_conn user_id]
	messenger do Subscriber changeUserStatus $user_id $status
	nsv_set $array-status $user_id $status
	#ns_log notice "SSSSSSSSSSStatus User=$user_id info vars [User=$user_id info vars]"
	messenger send_to_subscriber chat-[my chat_id] [subst -nocommands {{'presence': [{'user_id':'$user_id', 'status': '$status'}]\n}}]
    }

  Chat instproc logout {} {
    my instvar array user_id
      #ns_log Notice "YY User $user_id logging out of chat"
      set nsubscriptions [nsv_get $array-login $user_id] 
      my add_msg -get_new true -uid ${user_id} "has left the room ($nsubscriptions<sup>[::util::decode [string index $nsubscriptions end] 1 "st" 2 "nd" 3 "rd" "th"]</sup> connection)"
    catch {
        # do not try to clear nsvs, if they are not available
        # this situation could occur after a server restart, after which the user tries to leave the room
	if {[nsv_incr $array-login $user_id -1] == 0} {
	    nsv_unset $array-login $user_id
	    nsv_unset $array-status $user_id
	    nsv_unset $array-last-activity $user_id
	    #nsv_unset $array-color $user_id
	    #ns_log notice "$user_id disconnected"
	    messenger send_to_subscriber chat-[my chat_id] [subst -nocommands {{'presence': [{'user_id':'$user_id', 'status': 'disconnected'}]\n}}]
	}
    }
  }

  Chat instproc init_user_color {} {
    my instvar array user_id
    if { [nsv_exists $array-color $user_id] } {
      return
    } else {
      set colors [parameter::get -parameter UserColors -default [[my info class] set colors]]
      # ns_log notice "getting colors of [my info class] = [info exists colors]"
      set color [lindex $colors [expr { [nsv_get $array-color idx] % [llength $colors] }]]
      nsv_set $array-color $user_id $color
      nsv_incr $array-color idx
    }
  }
  
  Chat instproc get_users {} {
    set output ""
    foreach {user_id timestamp} [my active_user_list] {
      if {$user_id > 0} {
	set diff [clock format [expr {[clock seconds] - $timestamp}] -format "%H:%M:%S" -gmt 1]
	set userlink  [my user_link -user_id $user_id]
	append output "<TR><TD class='user'>$userlink</TD><TD class='timestamp'>$diff</TD></TR>\n"
      }
    }     
    return $output
  }
  
    Chat instproc login {} {
    my instvar array user_id now
    # was the user already active?
    if {![nsv_exists $array-last-activity $user_id]} {
        my add_msg -get_new false [mc chat.has_entered_the_room "has entered the room"]
    }
    my encoder noencode
    #my log "--c setting session_id [my set session_id]: $now"
    my get_all
  }

  Chat instproc user_color { user_id } {
    my instvar array
    if { ![nsv_exists $array-color $user_id] } {
	#my log "warning: Cannot find user color for chat ($array-color $user_id)!"
      return [lindex [[my info class] set colors] 0]
    }
    return [nsv_get $array-color $user_id]
  }

  Chat instproc user_name { user_id } {
      acs_user::get -user_id $user_id -array user
      return [expr {$user(screen_name) ne "" ? $user(screen_name) : $user(name)}]
  }
  
  Chat instproc user_link { -user_id -color } {
    if {$user_id > 0} {
        set name [my user_name $user_id]
	set url "http://www.phigita.net/~${name}/"
      if {![info exists color]} {
	set color [my user_color $user_id]
      }
	set creator "<a style='color:$color;' target='_blank' href='$url'>$name</a>"
    } elseif { $user_id == 0 } {
      set creator "Nobody"
    } else {
      set creator "System"
    }  
    return [my encode $creator]  
  }
  
  Chat instproc urlencode {string} {ns_urlencode $string}
  Chat instproc noencode  {string} {set string}
  Chat instproc encode    {string} {my [my encoder] $string}	
    Chat instproc encodeURIComponent {string} { string map {+ { }} [ns_urlencode $string] }
  Chat instproc json_encode {string} {
      string map [list \n \\n {"} {\"} {'} {\'}] $string ;#"
  }

  Chat instproc json_encode_msg {msg} {
    set old [my encoder]
    my encoder noencode ;# just for user_link
    set userlink [my user_link -user_id [$msg user_id] -color [$msg color]]
    my encoder $old
    set timeshort [clock format [$msg time] -format {[%H:%M:%S]} -timezone :Europe/Athens]
      set text [$msg msg]
    foreach var {userlink timeshort} {set $var [my json_encode [set $var]]}
      set urlencoded_text [my json_encode [my encodeURIComponent $text]]
    return [subst -nocommands {{'messages': [{'user':'$userlink', 'time': '$timeshort', 'msg':'$urlencoded_text'}]\n}}]
  }

  Chat instproc js_encode_msg {msg} {
    set json [my json_encode_msg $msg]
    return "<script type='text/javascript' language='javascript'>
    var data = $json;
    parent.getData(data);
    </script>\n"
  }

  Chat instproc json {json} {
      if { [my mode] eq {scripted-streaming} } {
    return "<script type='text/javascript' language='javascript'>
    var data = $json;
    parent.getData(data);
    </script>\n"
      } else {
	  return $json
      }
  }

  Chat instproc broadcast_msg {msg} {
    messenger send_to_subscriber chat-[my chat_id] [my json_encode_msg $msg]
  }

	  Chat instproc subscribe {-uid} {
	      my instvar array
	      set key chat-[my chat_id]
	      set user_id [expr {[info exists uid] ? $uid : [my set user_id]}]
	      #ns_log notice "subscribing $user_id"

	      set userdata [db::Set new -select {* {first_names || ' ' || last_name as name}} -type CC_Users -where [list user_id=[ns_dbquotevalue $user_id]]]
	      $userdata load
	      set o [$userdata head]

	      array set user [list]
	      foreach varName [$o info vars] {
		  set user($varName) [$o set $varName]
	      }

	      if {![nsv_exists $array-login $user_id]} {
		  set nsubscriptions 1
		  if { $user(status) eq {disconnected} } {
		      set status available
		  } else {
		      set status [::util::coalesce $user(status) available];# available ;# HERE: get status from db
		  }
		  nsv_set $array-login $user_id 1
		  nsv_set $array-status $user_id avalable
	      } else {
		  set status [nsv_get $array-status $user_id]
		  #set status [messenger do User=$user_id set status]
		  set nsubscriptions [nsv_incr $array-login $user_id 1] ;# HERE [clock seconds]
	      }
	      set color [my user_color $user_id]


	      #acs_user::get -user_id $user_id -array user

	      set msg [mc chat.has_entered_the_room "has entered the room ($nsubscriptions<sup>[::util::decode [string index $nsubscriptions end] 1 "st" 2 "nd" 3 "rd" "th"]</sup> connection)"]
	      set urlencoded_name [my encodeURIComponent $user(name)]


	      set initmsg [my json_encode_msg [Message new -volatile -time [clock seconds] -user_id $user_id -color $color -msg $msg] ]
	      messenger subscribe [my session_id] $urlencoded_name $user(screen_name) $color $status chat-[my chat_id] $initmsg [my mode]


	      my add_msg -get_new false -uid $user_id $msg

	      messenger send_to_subscriber chat-[my chat_id] [subst -nocommands {{'presence': [{'user_id':'$user_id', 'full_name':'$urlencoded_name', 'screen_name':'$user(screen_name)', 'profile_link':'http://www.phigita.net/~$user(screen_name)/', 'color': '${color}', 'status': '$status'}]\n}}]



	  }


  Chat instproc render {} {
    my orderby time
    set result ""
    foreach child [my children] {
      set msg       [$child msg]
      set user_id   [$child user_id]
      set color     [$child color]
      set timelong  [clock format [$child time]]
      set timeshort [clock format [$child time] -format {[%H:%M:%S]}]
      set userlink  [my user_link -user_id $user_id -color $color]

      append result "<p class='line'><span class='timestamp'>$timeshort</span>" \
	  "<span class='user'>$userlink:</span>" \
	  "<span class='message'>[my encode $msg]</span></p>\n"
    }
    return $result
  }

  
  ############################################################################
  # Chat meta class, since we need to define general class-specific methods
  ############################################################################
  Class create ChatClass -superclass ::xotcl::Class
  ChatClass method sweep_all_chats {} {
      #my log "-- starting"
    foreach nsv [nsv_names "[self]-*-seen"] {
      if { [regexp "[self]-(\[0-9\]+)-seen" $nsv _ chat_id] } {
	#my log "--Chat_id $chat_id"
	my new -volatile -chat_id $chat_id -user_id 0 -session_id 0 -init -sweeper
      }
    }
    #my log "-- ending"
  }
    
  ChatClass method initialize_nsvs {} {
    # read the last_activity information at server start into a nsv array
      set comment {
	  db_foreach get_rooms {
	      select room_id, to_char(max(creation_date),'HH24:MI:SS YYYY-MM-DD') as last_activity 
	      from chat_msgs group by room_id} {
		  nsv_set [self]-$room_id-seen last [clock scan $last_activity]
	      }
      }
  }

  ChatClass method flush_messages {-chat_id:required} {
    set array "[self]-$chat_id"
    nsv_unset $array
    nsv_unset $array-seen
    nsv_unset $array-last-activity
  }

  ChatClass method init {} {
    # default setting is set19 from http://www.graphviz.org/doc/info/colors.html
    # per parameter settings in the chat package are available (param UserColors)
    my set colors [list #1b9e77 #d95f02 #7570b3 #e7298a #66a61e #e6ab02 #a6761d #666666]
  }
}

