#############################################################################
::xotcl::THREAD create throttle {

  Class create ThrottleStat -parameter { type requestor timestamp ip_adress url }
  #startThrottle 7
  #toMuch 10
  Class create Throttle -parameter {
    {timeWindow 10}
    {timeoutMs 2000}
    {startThrottle 64} 
    {toMuch 128} 
    {alerts 0} {throttles 0} {rejects 0} {repeats 0}
  }

  Throttle instproc init {} {
    my set off 0
    Object create [self]::stats
    Object create [self]::users
    next
  }

  Throttle instproc add_statistics { type requestor ip_adress url query } {
    set furl [expr {$query ne "" ? "$url?$query" : $url}]
    my incr ${type}s
    #my log "++++ add_statistics   -type $type -user_id $requestor "
    set entry [ThrottleStat new -childof [self]::stats \
		   -type $type -requestor $requestor \
		   -timestamp [clock seconds] \
		   -ip_adress $ip_adress -url $furl]
  }

  Throttle instproc url_statistics {{-flush 0}} {
    set data [[self]::stats info children]
    if { [llength $data] == 0} {
      return $data
    } elseif {$flush} {
      foreach c $data {$c destroy}
      return ""
    } else {
      foreach stat $data {
	lappend output [list [$stat type] [$stat requestor] \
		    [$stat timestamp] [$stat ip_adress] [$stat url]]
      }
      return $output
    }
  }

  Throttle instproc call_statistics {} {
    set l [list]
    foreach t {seconds minutes hours} {
      lappend l [list $t [$t set last] [$t set trend] [$t set stats]]
    }
    return $l
  }

  Throttle instproc register_access {requestKey pa url community_id} {
      set obj [ThrottleUsers current_object]
      #ns_log notice "register_access: obj=$obj addKey $requestKey $pa $url $community_id"
      $obj addKey $requestKey $pa $url $community_id
      ThrottleUsers expSmooth [$obj point_in_time] $requestKey
  }



  Throttle instproc running {} {
    my array get running_url
  }


  Throttle instproc throttle_check {requestKey pa url conn_time content_type community_id} {
      my instvar off
      seconds ++

      my register_access $requestKey $pa $url $community_id
      return [list 0 0 0]
  }

  Throttle instproc statistics {} {
    return "<table>
        <tr><td>Number of alerts:</td><td>[my alerts]</td></tr>
        <tr><td>Number of throttles:</td><td>[my throttles]</td></tr>
        <tr><td>Number of rejects:</td><td>[my rejects]</td></tr>
        <tr><td>Number of repeats:</td><td>[my repeats]</td></tr>
        </table>\n"
  }

  Throttle instproc cancel {requestKey} {
    # cancel a timeout and clean up active request table for this key
    if {[my exists active($requestKey)]} {
      after cancel [lindex [my set active($requestKey)] 0]
      my unset active($requestKey)
      my log "+++ Cancel $requestKey block"
    } else {
      my log "+++ Cancel for $requestKey failed !!!"
    }
  }

  Throttle instproc active { } {
    # return the currently active requests (for debugging and introspection)
    return [my array get active]
  }

  Throttle instproc add_url_stat {url time_used key pa cc} {
      #catch {my unset running_url($key,$url)}
    #my log "### unset running_url($key,$url)"
      if { $time_used > 10000 } {
	  ns_log notice "SLOW url=$url time_used=$time_used key=$key"
      }
    response_time_minutes add_url_stat $url $time_used $key $cc
  }
  Throttle instforward report_url_stats response_time_minutes %proc
  Throttle instforward report_cc_stats response_time_minutes %proc
  Throttle instforward flush_url_stats  response_time_minutes %proc
  Throttle instforward last100          response_time_minutes %proc
  Throttle create throttler

  ############################
  # A simple counter class, which is able to aggregate values in some
  # higher level counters (report_to) and to keep statistics in form 
  # of a trend and max values)
  Class create Counter -parameter { 
    report timeoutMs 
    {stats ""} {last ""} {trend ""} {c 0} {logging 0}
    {nr_trend_elements 48} {nr_stats_elements 5} 
  }
  Counter instproc ++ {} {
    my incr c
  }
  Counter instproc end {} {
    if {[my exists report]} {
      [my report] incr c [my c]
    }
    my finalize [my c]
    my c 0
  }
  Counter instproc log_to_file {timestamp label value} {
    if {![my logging]} return
    set server [ns_info server]
#    set f [open $::logdir/counter.log a]
      set f [open [ns_config ns/parameters CounterLog $::logdir/counter.log] a]
    puts $f "$timestamp -- $server $label $value"
    close $f
  } 
  Counter instproc finalize {n} {
    after cancel [my set to]
    my instvar stats trend
    #
    # trend keeps nr_trend_elements most recent values
    #
    lappend trend $n
    set lt [llength $trend]
    if {$lt > [my nr_trend_elements]} {
      set trend [lrange $trend [expr {$lt-[my nr_trend_elements]}] end]
    }
    #
    # stats keeps nr_stats_elements highest values with time stamp
    #
    set now [clock format [clock seconds]]
    lappend stats [list $now $n]
    set stats [lrange [lsort -real -decreasing -index 1 $stats] 0 [my nr_stats_elements]]
    #
    # log if necessary
    #
      ##### HERE: catch {my log_to_file $now [self] $n}
    #
    my set to [after [my timeoutMs] [list [self] end]]
  }

  Counter instproc init {} {
    my set to [after [my timeoutMs] [list [self] end]]
    next
  }
  Counter instproc destroy {} {
    after cancel [my set to]
    next
  }

  Counter hours -timeoutMs [expr {60000*60}] -logging 1
  Counter minutes -timeoutMs 60000 -report hours -logging 1
  Counter seconds -timeoutMs 1000 -report minutes 

  Class create MaxCounter -superclass Counter -instproc end {} {
    my c [ThrottleUsers nr_active]
    if {[my exists report]} {
      [my report] instvar {c rc}
      if {$rc < [my c]} {set rc [my c]}
    }
    my finalize [my c]
    my c 0
  }

  MaxCounter user_count_hours -timeoutMs [expr {60000*60}] -logging 1
  MaxCounter user_count_minutes -timeoutMs 60000 -report user_count_hours -logging 1


  Class create AvgCounter -superclass Counter \
      -parameter {{t 0} {atleast 1}} -instproc end {} {
    if {[my c]>0} {
      set avg [expr {int([my t]*1.0/[my c])}]
    } else {
      set avg 0
    }
    if {[my exists report]} {
      [my report] incr c [my c]
      [my report] incr t [my t]
    }
    my finalize $avg
    my c 0
    my t 0
  }


  Class create UrlCounter -superclass AvgCounter \
      -parameter {{truncate_check 10} {max_urls 0}} \
      -set seconds [clock seconds] \
      -instproc add_url_stat {url ms requestor cc} {
	  my instvar c
	  my ++
	  # my log "[self proc] $url /$ms/ $requestor ($c)"
	  my incr t $ms

	  ### set up a value for the right ordering in last 100.
	  ### We take the difference in seconds since start, multiply by
	  ### 10000 (there should be no overflow); there should be less
	  ### than this number requests per minute.
	  set now [clock seconds]
	  set order [expr {($now-[[self class] set seconds])*10000+$c}]
	  my set last100([expr {$order%99}]) [list $now $order $url $ms $requestor]
	  my incr cc($cc)

      } -instproc last100  {} {
	  my array get last100
      } -instproc report_cc_stats  {} {
	  my array get cc
      } -instproc flush_url_stats {} {
	  my log "flush_url_stats"
	  my array unset stat
	  my array unset cnt
      } -instproc url_stats {} {
	  set result [list]
	  foreach url [my array names stat] {
	      lappend result [list $url [my set stat($url)] [my set cnt($url)]]
	  }
	  set result [lsort -real -decreasing -index 1 $result]
	  return $result
      } -instproc check_truncate_stats {} {
	  my max_urls 13
	  set time_window 10
	  if {$time_window != [throttler timeWindow]} {
	      throttler timeWindow $time_window
	      after 0 [list ThrottleUsers purge_access_stats]
	  }
	  
	  # truncate statistics if necessary
	  if {[info exists ::package_id]} {
	      # get values from package parameters
	      my max_urls [parameter::get -package_id $::package_id \
			       -parameter max-url-stats -default 13]
	      # we use the timer to check other parameters as well here
	      set time_window [parameter::get -package_id $::package_id \
				   -parameter time-window -default 10]
	      if {$time_window != [throttler timeWindow]} {
		  throttler timeWindow $time_window
		  after 0 [list ThrottleUsers purge_access_stats]
	      }
	  }
	  set max [my max_urls]
	  if {$max>1} {
	      set result [my url_stats]
	      set l [llength $result]
	      for {set i $max} {$i<$l} {incr i} {
		  set url [lindex [lindex $result $i] 0]
		  my unset stat($url)
		  my unset cnt($url)
	      }
	      set result [lrange $result 0 [expr {$max-1}]]
	      return $result
	  }
	  return ""
      } -instproc report_url_stats {} {
	  set stats [my check_truncate_stats]
	  if {$stats eq ""} {
	      set stats [my url_stats]
	  }
	  return $stats
      } -instproc finalize args {
	  next
	  # each time the timer runs out, perform the cleanup
	  after 0 [list [self] check_truncate_stats]
      }


  UrlCounter response_time_hours -timeoutMs [expr {60000*60}] \
     -atleast 500 -logging 1
  UrlCounter response_time_minutes -timeoutMs 60000 \
     -report response_time_hours -atleast 100 \
     -logging 1

  #
  # Class for the user tracking

  Class create ThrottleUsers -parameter { point_in_time } -ad_doc {
    This class is responsible for the user tracking and is defined only
    in a separate Tcl thread named <code>throttle</code>. 
    For each minute within the specified <code>time-window</code> an instance
    of this class exists keeping various statistics. 
    When a minute ends the instance dropping out of the
    time window is destroyed. The procs of this class can be
    used to obtain various kinds of information.

    @author Gustaf Neumann
    @cvs-id $Id: throttle_mod-procs.tcl,v 1.2 2005/12/30 00:07:23 gustafn Exp $
  }
  ThrottleUsers ad_proc active {-full:switch}  {
    Return a list of lists containing information about current 
    users. If the switch 'full' is used this list contains 
    these users who have used the server within the 
    monitoring time window (per default: 10 minutes). Otherwise,
    just a list of requestors (user_ids or peer addresses for unauthenticated 
    requests) is returned.
    <p>
    If -full is used for each requestor the last
    peer address, the last timestamp, the number of hits, a list
    of values for the activity calculations and the number of ip-switches
    the user is returned. 
    <p>
    The activity calculations are performed on base of an exponential smoothing
    algorithm which is calculated through an aggregated value, a timestamp 
    (in minutes) and the number of hits in the monitored time window.
    @return list with detailed user info
  } {
    if {$full} {
      set info [list]
      foreach key [my array names pa] {
	set entry [list $key [my set pa($key)]]
	foreach var [list timestamp hits expSmooth switches] {
	  set k ${var}($key)
	  lappend entry [expr {[my exists $k] ? [my set $k] : 0}]
	}
	lappend info $entry
      }
      return $info
    } else {
      return [my array names pa]
    }
  }
  ThrottleUsers proc unknown { obj args } {
    my log "unknown called with $obj $args"
  }
  ThrottleUsers ad_proc nr_active {} {
    @return number of active users (in time window)
  } {
    return [my array size pa]
  }
  ThrottleUsers ad_proc hits {uid} {
    @param uid request key
    @return Number of hits by this user (in time window)
  } {
    if {[my exists hits($uid)]} {return [my set hits($uid)]} else {return 0}
  }
  ThrottleUsers ad_proc last_pa {uid} {
    @param uid request key
    @return last peer address of the specified users
  } {
    if {[my exists pa($uid)]} { return [my set pa($uid)]} else { return "" }
  }
  ThrottleUsers proc last_click {uid} {
    if {[my exists timestamp($uid)]} {return [my set timestamp($uid)]} else {return 0}
  }
  ThrottleUsers proc last_requests {uid} {
    if {[my exists pa($uid)]} { 
       set urls [list]
       foreach i [ThrottleUsers info instances] {
          if {[$i exists urls($uid)]} {
            foreach u [$i set urls($uid)] { lappend urls $u }
          }
       }
       return [lsort -index 0 $urls]
    } else { return "" }
  }

  ThrottleUsers proc active_communities {} {
    foreach i [ThrottleUsers info instances] {
      lappend communities \
	  [list [$i point_in_time] [$i array names in_community]]
      foreach {c names} [$i array get in_community] {
	lappend community($c) $names
      }
    }
    return [array get community]
  }

  ThrottleUsers proc nr_active_communities {} {
    foreach i [ThrottleUsers info instances] {
      foreach c [$i array names in_community] {
	set community($c) 1
      }
    }
    set n [array size community]
    return [incr n -1];   # subtract "non-community" with empty string id
  }

  ThrottleUsers proc in_community {community_id} {
    set users [list]
    foreach i [ThrottleUsers info instances] {
      if {[$i exists in_community($community_id)]} {
	set time [$i point_in_time] 
	foreach u [$i set in_community($community_id)] {
	  lappend users [list $time $u]
	}
      }
    }
    return $users
  }

  ThrottleUsers proc current_object {} {
      throttler instvar timeWindow
      my instvar last_mkey
      set now 	[ns_time];#[clock seconds]
      set mkey 	[expr { ($now / 60) % $timeWindow}]
      set obj 	[self]::users::$mkey

      #ns_log notice "mkey=$now / 60 % $timeWindow = $mkey, last_mkey=$last_mkey"

      if {$mkey ne $last_mkey} { 
	  if {$last_mkey ne ""} {my purge_access_stats}
	  # create or recreate the container object for that minute
	  if {[my isobject $obj]} {$obj destroy}
	  ThrottleUsers create $obj -point_in_time $now
	  my set last_mkey $mkey
      }
      return $obj
  }
  ThrottleUsers proc purge_access_stats {} {
    throttler instvar timeWindow
    my instvar last_mkey
    set time [clock seconds]
    # purge stale entries (for low traffic)
    set secs [expr {$timeWindow*60}]
    if { $time - [[self]::users::$last_mkey point_in_time] > $secs } {
      # no requests for a while; delete all objects under [self]::users::
      Object create [self]::users
    } else {
      # delete selectively
      foreach element [[self]::users info children] {
        if { [$element point_in_time] < $time - $secs } {$element destroy}
      }
    } 
  }

  ThrottleUsers proc community_access {requestor community_id} {
      if { [Object isobject [my current_object]] } {
	  [my current_object] community_access $requestor $community_id
      }
  }

  ThrottleUsers instproc community_access {key community_id} {
    if {![my exists user_in_community($key,$community_id)]} {
      my set user_in_community($key,$community_id) 1
      my lappend in_community($community_id) $key
    } 
  }

  ThrottleUsers instproc addKey {key pa url community_id} {
      set class [self class]
      if {[$class exists pa($key)]} {
	  # check, if the peer address changed
	  if {[$class set pa($key)] ne $pa} {
	      if {[catch {$class incr switches($key)}]} {
		  $class set switches($key) 1
	      }
	      # log the change
	      set timestamp [clock format [clock seconds]]
	      set f [open $::logdir/switches.log a]
	      puts $f "$timestamp -- switch $key from [$class set pa($key)] to $pa $url"
	      close $f
	  }
      }
      if {[my incr active($key)] == 1} {
	  my set active($key) 1
	  $class incrRefCount $key $pa
      }
      #ns_log notice "active($key)=[my set active($key)]"

      if {[catch {$class incr hits($key)}]} {
	  $class set hits($key) 1
      }
  }

  ThrottleUsers instproc destroy {} {
      #ns_log notice "ThrottleUsers([self]) destroy"
    foreach key [my array names active] {
      [self class] decrRefCount $key [my set active($key)]
    }
    next
  }
  ThrottleUsers proc expSmooth {ts key} {
    set mins [expr {$ts/60}]
    if {[my exists expSmooth($key)]} {
      foreach {_ aggval lastmins hits} [my set expSmooth($key)] break
      set mindiff [expr {$mins-$lastmins}]
      if {$mindiff == 0} {
	incr hits
	set retval [expr {$aggval*0.3 + $hits*0.7}]
      } else {
	set aggval [expr {$aggval*pow(0.3,$mindiff) + $hits*0.7}]
	set hits 1
      }
    } else {
      set hits 1
      set aggval 1.0
    }
    if {![info exists retval]} {set retval $aggval}
    my set expSmooth($key) [list $retval $aggval $mins $hits]
    return $retval
  }
  ThrottleUsers proc incrRefCount {key pa} {
    if {[my exists refcount($key)]} {
      my incr refcount($key)
    } else {
      my set refcount($key) 1
    }
    my set pa($key) $pa
    my set timestamp($key) [clock seconds]
  }
  ThrottleUsers proc decrRefCount {key hitcount} {
    if {[my exists refcount($key)]} {
      set x [my incr refcount($key) -1]
      my incr hits($key) -$hitcount
      if {$x < 1} {
	my unset refcount($key)
	my unset pa($key)
        catch {my unset expSmooth($key)}
        catch {my unset switches($key)}
      }
    } else {
      my log "+++ cannot decrement refcount for '$key' by $hitcount"
    }
  }
  ThrottleUsers proc perDay {} {
    set ip 0; set auth 0
    foreach i [my array names timestamp] {
      if {[string match *.* $i]} {incr ip} {incr auth}
    }
    return [list $ip $auth]
  }
  
  ThrottleUsers proc perDayCleanup {} {
    set secsPerDay [expr {3600*24}]
    foreach i [lsort [my array names timestamp]] {
      set secs [expr {[clock seconds]-[my set timestamp($i)]}]
      #my log "--- $i: last click $secs secs ago"
      if {$secs>$secsPerDay} {
	  #my log "--- $i expired [expr {$secs-$secsPerDay}] seconds ago"

	  if {[catch {my unset timestamp($i)} errmsg]} {
	      ns_log notice "perDayCleanup: $errmsg"
	  }


	  set OLD {
	      foreach {d h m s} [clock format [expr {$secs-$secsPerDay}] -format {%j %H %M %S}] break
	      regexp {^[0]+(.*)$} $d match d
	      regexp {^[0]+(.*)$} $h match h
	      if {[catch {
		  incr d -1
		  incr h -1
		  #my log "--- $i expired $d days $h hours $m minutes ago"
		  my unset timestamp($i)
	      } errmsg]} {
		  ns_log notice "perDayCleanup: $errmsg"
	      }
	  }

      }
    }
    after [expr {60000*60}] [list [self] [self proc]]
  }
  
  # initialization of ThrottleUsers class object
  ThrottleUsers perDayCleanup
  Object create ThrottleUsers::users
  ThrottleUsers set last_mkey ""
 
  # for debugging purposes: return all running timers
  proc showTimers {} {
     set _ ""
     foreach t [after info] { append _ "$t [after info $t]\n" }
     return $_
  }


  set comment {
      set ::package_id [::Generic::package_id_from_package_key \
			    xotcl-request-monitor]
      ns_log notice "+++ package_id of xotcl-request-monitor is $::package_id"
      
      set logdir [parameter::get -package_id $::package_id \
		      -parameter log-dir \
		      -default [file dirname [file root [ns_config ns/parameters ServerLog]]]]
  }

  set logdir [file dirname [file root [ns_config ns/parameters ServerLog]]]

  if {![file isdirectory $logdir]} {file mkdir $logdir}

} -persistent 1 -ad_doc {
  This is a small request-throttle application that handles simple 
  DOS-attracks on an AOL-server.  A user (request key) is identified 
  via ipAddr or some other key, such as an authenticated userid.
  <p>
  XOTcl Parameters for Class <a 
  href='/xotcl/show-object?object=%3a%3athrottle+do+%3a%3aThrottle'>Throttle</a>:
  <ul>
  <li><em>timeWindow:</em>Time window for computing detailed statistics; can 
     be configured via OACS parameter <code>time-window</code></li>
  <li><em>timeoutMs:</em> Time window to keep statistics for a user</li>
  <li><em>startThrottle:</em> If user requests more than this #, he is throttled</li>
  <li><em>toMuch:</em> If user requests more than this #, he is kicked out</li>
  </ul>
  The throttler is defined as a class running in a detached thread.
  It can be subclassed to define e.g. different kinds of throttling policies for
  different kind of request keys. Note that the throttle thread itself
  does not block, only the connection thread blocks if necessary (on throttles).
  <p>
  The controlling thread contains the classes 
    <a href='/xotcl/show-object?object=%3a%3athrottle+do+%3a%3aThrottleUsers'>ThrottleUsers</a>,
   <a href='/xotcl/show-object?object=%3a%3athrottle+do+%3a%3aThrottle'>Throttle</a>,
   <a href='/xotcl/show-object?object=%3a%3athrottle+do+%3a%3aCounter'>Counter</a>, 
  <a href='/xotcl/show-object?object=%3a%3athrottle+do+%3a%3aMaxCounter'>MaxCounter</a>, ...
  @author Gustaf Neumann
  @cvs-id $Id: throttle_mod-procs.tcl,v 1.2 2005/12/30 00:07:23 gustafn Exp $
}

throttle proc ms {-start_time} {
  if {![info exists start_time]} {
    set start_time [ns_conn start]
  }
  set t [ns_time diff [ns_time get] $start_time]
  set ms [expr {[ns_time seconds $t]*1000 + [ns_time microseconds $t]/1000}]
  return $ms
}

throttle proc get_context {} {
  my instvar url query requestor user pa
  if {[my exists context_initialized]} return
  set pa [ad_conn peeraddr]
  my set community_id 0

  if {[info exists ::ad_conn(user_id)]} {
    # ordinary request, ad_conn is initialized
    set requestor $::ad_conn(user_id)
    set package_id [ad_conn package_id]
    #### if {[info command dotlrn_community::get_community_id] ne "" && $package_id ne ""} { my set community_id [dotlrn_community::get_community_id -package_id $package_id] }
  } else {
    # for requests bypassing the ordinary connection setup (resources in oacs 5.2)
    # we have to get the user_id by ourselves
    if { [catch {
      if {[info command ad_cookie] ne ""} {
	# we have the xotcl-based cookie code
	set cookie_list [ad_cookie get_signed_with_expr "_SID"]
      } else {
	set cookie_list [ad_get_signed_cookie_with_expr "_SID"]
      }
      set cookie_data [split [lindex $cookie_list 0] {,}]
      set untrusted_user_id [lindex $cookie_data 1]
      set requestor $untrusted_user_id
    } errmsg] } {
      set requestor 0
    }
  }
  #my log "get_context, user_id = $requestor"

  # if user not authorized, use peer address as user id
  if {$requestor == 0} {
    set requestor $pa
    set user "client from $pa"
  } else {
    set user "<a href='/acs-admin/users/one?user_id=$requestor'>$requestor</a>"
  }
    set url [ad_host][ns_conn url]
  set query [ns_conn query]
  if {$query ne ""} {
     append url ?$query
  }
  #my log "+++ setting url to $url"
  #show_stack
  my set context_initialized 1
}

proc show_stack {{m 100}} {
  if {[::info exists ::template::parse_level]} {
    set parse_level $::template::parse_level
  } else {
    set parse_level ""
  }
  set msg "### tid=[::thread::id] <$parse_level> connected=[ns_conn isconnected] "
  if {[ns_conn isconnected]} {
    append msg "flags=[ad_conn flags] status=[ad_conn status] req=[ad_conn request]"
  }
  my log $msg
  set max [info level]  
  if {$m<$max} {set max $m}
  my log "### Call Stack (level: command)"
  for {set i 0} {$i < $max} {incr i} {
    if {[catch {set s [uplevel $i self]} msg]} {
      set s ""
    }
    my log "### [format %5d -$i]:\t$s [info level [expr {-$i}]]"
  }
}

throttle ad_proc check {} {
  This method should be called once per request that is monitored.
  It should be called after authentication shuch we have already 
  the userid if the user is authenticated
} {
    my instvar url requestor user pa query community_id
    my get_context

    set check_result [my throttle_check $requestor $pa $url [ns_conn start] [ns_guesstype $url] $community_id]
    lassign $check_result toMuch ms repeat

    if {$repeat} {
	my add_statistics repeat $requestor $pa $url $query
	return -1
    } elseif {$toMuch} {
	my log "*** we have to refuse user $requestor with $toMuch requests"
	my add_statistics reject $requestor $pa $url $query
	return $toMuch
    } elseif {$ms} {
	my log "*** we have to block user $requestor for $ms ms"
	my add_statistics throttle $requestor $pa $url $query
	after $ms
	my log "*** continue for user $requestor"
    }
    return 0
}
####
# the following procs are forwarder to the monitoring thread
# for conveniance
####
throttle forward statistics              %self do throttler %proc
throttle forward url_statistics          %self do throttler %proc
throttle forward add_url_stat            %self do throttler %proc
throttle forward flush_url_stats         %self do throttler %proc
throttle forward report_url_stats        %self do throttler %proc
throttle forward add_statistics          %self do throttler %proc
throttle forward throttle_check          %self do throttler %proc
throttle forward last100                 %self do throttler %proc
throttle forward off                     %self do throttler set off 1
throttle forward on                      %self do throttler set off 0
throttle forward running                 %self do throttler %proc
throttle forward nr_running              %self do array size running_url
throttle forward trend                   %self do %1 set trend
throttle forward max_values              %self do %1 set stats
throttle forward purge_access_stats      %self do ThrottleUsers %proc
throttle forward users                   %self do ThrottleUsers
throttle forward report_cc_stats        %self do throttler %proc

####
# the next procs are for the filters (registered from the -init file)
####
throttle proc postauth args {
    #my log "+++ [self proc] [ad_host][ns_conn url] auth ms [my ms] [ad_conn isconnected]"
  set r [my check]
  if {$r<0} {
    ns_return 200 text/html "
      <H1>Repeated Operation</H1>
      Operation blocked.
      Don't submit the same query, while the old one is still
      running...<p>"
    return filter_return
  } elseif {$r>0} {
    ns_return 200 text/html "
      <H1>Invalid Operation</H1>
      This web server is only open for interactive usage.<br>
      Automated copying and mirroring is not allowed!<p>
      Please slow down your requests...<p>"
    return filter_return
  } else {
    return filter_ok
  }
}
throttle proc trace args {
  #my log "+++ [self proc] <$args> [ad_conn url] [my ms] [ad_conn isconnected]"
  # openacs 5.2 bypasses for requests to /resources the user filter
  # in these cases pre- or postauth are not called, but only trace.
  # So we have to make sure we have the needed context here
  my get_context
  my add_url_stat [my set url] [my ms] [my set requestor] [my set pa] [ad_conn UL_CC]
  my unset context_initialized
  return filter_ok
}

throttle proc community_access {community_id} {
  my get_context
  if {[my set community_id] eq ""} {
    my users community_access [my set requestor] $community_id
  }
}
#throttle proc {} args {my eval $args}

ad_proc string_truncate_middle {{-ellipsis ...} {-len 100} string} {
  cut middle part of a string in case it is to long
} {
  set string [string trim $string]
  if {[string length $string]>$len} {
    set half [expr {($len-2)/2}]
    set left  [string trimright [string range $string 0 $half]]
    set right [string trimleft [string range $string end-$half end]]
    return $left$ellipsis$right
  }
  return $string
}