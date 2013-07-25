if { ![ns_config ns/server/[ns_info server] is_chat_p 0] } { return }

ad_library {

    Routines for background delivery of files

    @author Gustaf Neumann (neumann@wu-wien.ac.at)
    @author Neophytos Demetriou (k2pts@phigita.net)
    @creation-date 19 Nov 2005
    @cvs-id $Id: messenger-thread-procs.tcl,v 1.2 2006/04/09 00:09:51 gustafn Exp $
}

proc bgerror {message} {
    ns_log notice "BGERROR: $message"
}

::xotcl::THREAD create messenger {

    ###############
    # Subscriptions
    ###############
    set ::subscription_count 0
    set ::message_count 0

    ::xotcl::Class Subscriber -parameter {session_id key channel user_id mode full_name screen_name color status {padding 0}}
    Subscriber proc current {-key } {
	my instvar subscriptions
	set result [list]
	if {[info exists key]} {
	    if {[info exists subscriptions($key)]} {
		return [list $key $subscriptions($key)]
	    }
	} elseif {[info exists subscriptions]} {
	    foreach key [array names subscriptions] {
		lappend result $key $subscriptions($key)
	    }
	}
    }

    Subscriber proc broadcast {key msg} {
	my instvar subscriptions
	set array ::app::Chat-826
	if {[info exists subscriptions($key)]} {
	    set subs1 [list]
	    foreach s $subscriptions($key) {
		if {[catch {
		    if {[$s mode] eq "scripted-streaming"} {
			set smsg "<script type='text/javascript' language='javascript'>var response = $msg;parent.getData(response);</script>\n"
		    } else {
			set smsg ${msg}
		    }
		    append smsg [string repeat " " [$s padding]]
		    #ns_log notice "-- sending to subscriber for $key $smsg ch=[$s channel] mode=[$s mode], user_id [$s user_id]"
		    puts -nonewline [$s channel] $smsg
		    flush [$s channel]
		} errmsg]} {
		    ns_log notice "error in send to subscriber [$s user_id] (key=$key): $errmsg"
		    catch {close [$s channel]}
		    #$s destroy
		} else {
		    lappend subs1 $s
		}
	    }
	    set subscriptions($key) $subs1
	}

	incr ::message_count
    }


    Subscriber proc ping_all {} {
	my instvar subscriptions
	foreach key [array names subscriptions] {
	    foreach s $subscriptions($key) {
		if {[catch {
		    puts -nonewline [$s channel] " "
		    flush [$s channel]
		} errmsg]} {
		    ns_log notice "error in ping to subscriber $s"
		}
	    }		   
	}
    }



    Subscriber proc json {-mode json} {
	if { ${mode} eq {scripted-streaming} } {
	    return "<script type='text/javascript' language='javascript'>var response = $json;parent.getData(response);</script>\n"
	} else {
	    return $json
	}
    }

    Subscriber proc send_presence_to_channel {-mode ch key} {
	my instvar subscriptions
	my instvar subscriptionUser
	if {![info exists subscriptions($key)]} return
	foreach s $subscriptions($key) {
	    if {[catch {
		set u $subscriptionUser($s)
		set user_id [$u set user_id]
		set full_name [$u set full_name]
		set screen_name [$u set screen_name]
		set color [$u set color]
		set status [$u set status]
	    } errmsg]} {
		ns_log notice "failed to send presence_to_channel $ch $key errmsg=$errmsg"
		continue
	    }
	    if {[catch {
		puts -nonewline $ch [my json -mode $mode [subst -nocommands {{'presence': [{'user_id':'$user_id', 'full_name':'$full_name', 'screen_name':'$screen_name', 'profile_link':'http://www.phigita.net/~$screen_name/', 'color': '$color', 'status': '$status'}]\n}\t}]]
	    } errmsg]} {
		ns_log notice "send_presence_channel errmsg: $errmsg"
	    }
	}



	set now [clock clicks -milliseconds]
	array set messages [nsv_array get ::app::Chat-826]
	foreach key [lrange [lsort -integer [array names messages]] end-10 end] {
	    
	    set value [nsv_get ::app::Chat-826 $key]
	    foreach {timestamp secs user_id msg color} $value break
	    set u User=${user_id}
	    if { [Object exists $u] } {
		set userlink "<a href=\"http://www.phigita.net/~[$u set screen_name]/\" target=\"_blank\" style=\"color:[$u set color];\">[$u set screen_name]</a>"
		set urlencoded_text [string map {\n \\n {"} {\"} {'} {\'}} [::util::encodeURIComponent $msg]]
	        set timeshort [clock format $secs -format {[%H:%M:%S]} -timezone :Europe/Athens]
   	        if {[catch {
	            puts -nonewline $ch [my json -mode $mode [subst -nocommands {{'messages': [{'user':'$userlink', 'time': '$timeshort', 'msg':'$urlencoded_text'}]\n}\t}]]
         	} errmsg]} {
	            ns_log notice "send_presence_channel errmsg: $errmsg"
                }
	    } else {
               ns_log notice "send_presence_to_channel: $u does not exist - FIX FIX FIX"
            }
        }
        flush $ch


  }

  proc Reader { pipe o } {
      if { ![eof $pipe] } {
          ns_log notice "Reader: input=[gets $pipe]"
      } else {
          #HERE
          catch {close $pipe}
          if {[catch {
              Subscriber unset __channel_to_subscriber($pipe)
             Subscriber unset __session_to_channel([$o session_id])
          } errmsg]} {
              ns_log notice "error in messenger->Reader errmsg=$errmsg"
          }
          ns_log notice "Closing socket $pipe"
          Subscriber instvar subscriptions
          set index  [lsearch $subscriptions([$o key]) $o]
          Subscriber set subscriptions([$o key]) [lreplace $subscriptions([$o key]) $index $index]
          #ns_log notice "Reader: ok index=$index subscriptions=$subscriptions([$o key])"
          set array ::app::Chat-826
          #ns_log notice "nsv_get $array-login [$o user_id] = [nsv_get $array-login [$o user_id]]"
    #      nsv_incr $array-login [$o user_id] -1
          ::app::Chat c1 -volatile -chat_id 826 -user_id [$o user_id] -set array $array -set now [clock clicks -milliseconds] -set session_id [$o user_id].[clock seconds] -logout -noinit
          if {![nsv_exists $array-login [$o user_id]]} {
	      Subscriber changeUserStatus [$o user_id] disconnected
          }

         $o destroy

         # Process one line
     }

  }

  Subscriber proc changeUserStatus {user_id status} {
      my instvar conn
      set array ::app::Chat-826
      nsv_set $array-status $user_id $status
      User=${user_id} set status $status
      if { $status ne {idle} } {
	  if {![info exists conn]} {
	      set conn [DB_Connection new]
	  }
	  $conn do "update users set status=[ns_dbquotevalue $status] where user_id=[ns_dbquotevalue $user_id]"
      }
  }

  Subscriber proc send_to_user {user_id msg} {
	  if {[catch {
              my instvar userSubscription
              set s $userSubscription(${user_id})
              set ch [$s channel]
              set mode [$s mode]
              set msg [::util::jsquotevalue $msg]
	      puts -nonewline $ch [my json -mode $mode [subst -nocommands {{'instruction': [{'fn':alert(${msg})}]\n}\t}]]
              flush $ch
	  } errmsg]} {
	      ns_log notice "send_presence_channel errmsg: $errmsg"
	  }

  }

  Subscriber proc send_directive_to_user {user_id} {
    my instvar userSubscription
    set s $userSubscription(${user_id})
    set ch [$s channel]
    set mode [$s mode]
	  if {[catch {
	      puts -nonewline $ch [my json -mode $mode [subst -nocommands {{'instruction': [{'fn':emptyFn}]\n}\t}]]
	  } errmsg]} {
	      ns_log notice "send_presence_channel errmsg: $errmsg"
	  }

  }


  Subscriber instproc init {} {
      fconfigure [my channel] -translation binary -encoding utf-8 -buffering none -blocking 0
      fileevent [my channel] readable [list Reader [my channel] [self]]

      [my info class] instvar subscriptions
      [my info class] instvar userSubscription
      [my info class] instvar subscriptionUser
      [my info class] instvar __session_to_channel
      [my info class] instvar __channel_to_subscriber

      set __session_to_channel([my session_id]) [my channel]
      set __channel_to_subscriber([my channel]) [self]

      set userSubscription([my user_id]) [self]
      set subscriptionUser([self]) User=[my user_id]

      if {![Object isobject User=[my user_id]]} {
	  #ns_log notice "Creating user object for [my user_id] [my status]"
	  Object ::User=[my user_id]
      }
      ::User=[my user_id] configure \
	      -set user_id [my user_id] \
	      -set screen_name [my screen_name] \
	      -set full_name [my full_name] \
	      -set color [my color] \
	      -set status [my status]

      Subscriber changeUserStatus [my user_id] [my status]

    lappend subscriptions([my key]) [self]
    #ns_log notice "-- cl=[my info class], subscriptions([my key]) = $subscriptions([my key])"

    incr ::subscription_count
  }

  Subscriber proc adjust_buffer_size {session_id} {
     my instvar __session_to_channel __channel_to_subscriber

if {[catch {
     set channel $__session_to_channel($session_id)
     set subscriber $__channel_to_subscriber($channel)
} errmsg]} {
    ns_log notice "adjust_buffer_size: errmsg=$errmsg"
    return
}
     $subscriber instvar padding
     incr padding 1024
     if { $padding > 8192 } {
       set padding 8192
     }


     if {[catch {
          ns_log notice "adjust_buffer_size: user_id=[$subscriber user_id] session_id=$session_id channel=$channel padding=$padding"
          puts -nonewline $channel [string repeat " " $padding]
          flush $channel
     } errmsg]} {
          ns_log notice "error in adjust_buffer_size for channel=$channel errmsg=$errmsg"
     }   
  }

  Subscriber instproc send {msg} {
      puts -nonewline [my channel] ${msg}
      flush [my channel]
  }

} -persistent 1


if {[ns_info name] eq "NaviServer"} {
    messenger forward write_headers ns_headers
} else {
    messenger forward write_headers ns_headers DUMMY
}



#####################################
messenger proc subscribe {session_id full_name screen_name color  status key {initmsg ""} {mode default} } {
    set content_type [expr {$mode eq "scripted-streaming" ? "text/html" : "text/plain"}]
    ns_write "HTTP/1.0 200 OK\r\nContent-type: $content_type\r\n\r\n[string repeat { } 1024]"
    set ch [ns_conn channel]
    thread::transfer [my get_tid] $ch
    my do ::Subscriber new -session_id $session_id -full_name $full_name -screen_name $screen_name -color $color -status $status -channel $ch -key $key -user_id [ad_conn user_id] -mode $mode
    my do -async ::Subscriber send_presence_to_channel -mode $mode $ch $key
    my send_to_subscriber $key $initmsg
}

messenger proc ping_all {} {
    my do -async ::Subscriber ping_all
}

messenger proc send_directive_to_subscriber {user_id} {
    my do -async ::Subscriber ping_user $user_id
}

messenger proc send_to_subscriber {key msg} {
    my do -async ::Subscriber broadcast $key ${msg}\t
}
messenger proc change_user_status {user_id status} {
    my do ::Subscriber changeUserStatus $user_id $status
}



messenger proc adjust_buffer_size {session_id} {
    my do -async ::Subscriber adjust_buffer_size $session_id
}
