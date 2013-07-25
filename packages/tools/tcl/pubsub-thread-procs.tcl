#if { ![ns_config ns/server/[ns_info server] is_chat_p 0] } { return }

proc bgerror {message} {
    ns_log notice "BGERROR: $message"
}

::xotcl::THREAD create PUBSUB {



    # For debugging purposes: set by dwr/index.vuh at the moment
    set ::WUW_FORMAT sharedraw
    #set ::WUW_FORMAT chat

    proc js_encode {string} {
	string map [list \n \\n \" {\"} ' {\'}] $string
    }



    ::xotcl::Class ::Widget -parameter {
	instanceid 
	guid
	title
	shortName 
	startFile
	height 
	width
	package_url


	{author ""}
	{authorEmail ""}
	{authorHref ""}
	{description ""}
	{version "0.1"}
	{maximize "false"}

	{shared_data_key ""}
	{properties ""}
    }

    ::Widget proc getInstance {idkey} {
	my instvar __widget_instance
	if { [info exists __widget_instance($idkey)] } {
	    return $__widget_instance($idkey)
	}
    }

    ::Widget proc setInstance {idkey o} {
	my instvar __widget_instance
	if { [info exists __widget_instance($idkey)] } {
	    ns_log notice "something is wrong... cannot have more than an object for an idkey"
	}
	set __widget_instance($idkey) $o
    }

    ::Widget proc generateIdentifier {o} {
	$o instvar title height width shared_data_key properties
	set text "${title},${height},${width},${shared_data_key},${properties}"
	return [ns_sha1 $text]
    }

    ::Widget proc metadata {idkey} {
	set o [my getInstance $idkey]
	return [$o toJSON]
    }

    ::Widget proc getOrCreateInstance {-returnXML args} {
	set o [::Widget new {*}${args}]

	if { $returnXML } {
	    return [$o toXML]
	} else {
	    return $o
	}
    }

    ::Widget instproc init {} {
	my instvar instanceid
	set cl [my info class]
	set instanceid [$cl generateIdentifier [self]]
	$cl setInstance $instanceid [self]	
    }

    ::Widget instproc toJSON {} {
	set result [list]
	foreach varName {instanceid title shortName height width author authorEmail authorHref description version} {
	    set varValue [my set $varName]
	    lappend result "${varName}:\"[js_encode ${varValue}]\""
	}
	return "\{[join ${result} {,}]\}"
    }

    ::Widget instproc toXML {} {
	my instvar instanceid title shortName startFile height width maximize package_url
	set url ${package_url}download/file/${shortName}/${startFile}?idkey=$instanceid
	set xml [subst -nocommands -nobackslashes {
	    <widgetdata>
	    <url>${url}</url>
	    <identifier>${instanceid}</identifier>
	    <title>${title}</title>
	    <height>${height}</height>
	    <width>${width}</width>
	    <maximize>${maximize}</maximize>
	    </widgetdata> 
	}]
	ns_log notice xml=$xml
	return $xml
    }

    ::xotcl::Class ::Subscriber -parameter {channel_ socket_ user_id batchId mode callback_}

    ::Subscriber proc sharedDataForKey {idkey wName} {
	my instvar state

	#set key $idkey
	set key "${idkey},${wName}"

	ns_log notice "called sharedDataForKey $key"

	if { [info exists state($key)] } {

	    if { $::WUW_FORMAT eq {sharedraw} } {
		set json \{[join $state($key) {,}]\}
		return $json
	    } else {
		return "'$state($key)'"
		# HERE
	    }

	} else {
	    return null
	}
    }

    ::Subscriber proc unsubscribe {channel_list} {
	my instvar subscriptions

	# unsubscribe who? needs user_id or session_id

    }


    # appendSharedDataForKey and then broadcast

    ::Subscriber proc broadcast {channel message {format ""}} {
	my instvar subscriptions state

	ns_log notice "broadcast $channel $message"

	#set key "${idkey},${wName}"
	#set key $idkey
	set thedelta $message

	if { $::WUW_FORMAT eq {sharedraw} } {
	    lappend state($channel) [string range $thedelta 1 end-1]
	    #set state($key) $thedelta ;# HERE: FIXME
	} else {
	    append state($channel) $thedelta
	}


	if { $format eq {sharedraw} } {
	    set json "\{\"channel\":\"$channel\",\"message\":$message\}"
	} else {
	    set json [::util::map2json channel $channel message $message]
	}
	if { [info exists subscriptions($channel)] } {
	    set subs1 [list]
	    foreach s $subscriptions($channel) {
		ns_log notice "send to subscriber $s socket=[$s socket_] (channel=[$s channel_])"
		if {[catch {
		    #set callback "sync_message_from_server"
		    set callback [$s callback_]
		    set js "${callback}(${json});"
		    puts -nonewline [$s socket_] $js
		    flush [$s socket_]
		} errmsg]} {
		    ns_log notice "error in send to subscriber [$s socket_] (channel=$channel): $errmsg"
		    catch {close [$s socket_]}
		    $s destroy
		} else {
		    if {1} {
			# mode=scripted-streaming
			catch {close [$s socket_]}
			$s destroy
		    } else {
			# mode=comet
			lappend subs1 $s
		    }
		}
	    }
	    set subscriptions($channel) $subs1
	}
	incr ::message_count
    }
    
    ::Subscriber instproc init {args} {
	[my info class] instvar subscriptions
	my instvar channel_ socket_
	lappend subscriptions($channel_) [self]
	fconfigure $socket_ -translation binary
	incr ::subscription_count
	ns_log notice "subscriptions($channel_) = $subscriptions($channel_)"
    }

} -persistent 1


#####################################

::PUBSUB proc subscribe {channel user_id batchId callback {mode default} } {
   set content_type "text/plain"
    ns_write "HTTP/1.0 200 OK\r\nContent-type: $content_type\r\n\r\n[string repeat { } 1024]"
    set sock [ns_conn channel] ;# has the notion of a socket
    thread::transfer [my get_tid] $sock
    my do ::Subscriber new -channel_ $channel -socket_ $sock -user_id $user_id -batchId $batchId -mode $mode -callback_ $callback

}

::PUBSUB proc publish {channel message {format ""}} {
    my do -async ::Subscriber broadcast $channel $message $format
}

::PUBSUB proc unsubscribe {channel_list} {
    my do -async ::Subscriber unsubscribe $channel_list
}


#PUBSUB proc ping_all {} {
#    my do -async ::Subscriber ping_all
#}

#PUBSUB proc send_directive_to_subscriber {user_id} {
#    my do -async ::Subscriber ping_user $user_id
#}

#PUBSUB proc send_to_subscriber {key msg} {
#    my do -async ::Subscriber broadcast $key ${msg}\t
#}

#PUBSUB proc change_user_status {user_id status} {
#    my do ::Subscriber changeUserStatus $user_id $status
#}

#PUBSUB proc adjust_buffer_size {session_id} {
#    my do -async ::Subscriber adjust_buffer_size $session_id
#}


namespace eval ::xo::api {;}

proc ::xo::api::subscribe {channel_list callback} {
    set user_id [ad_conn user_id] ;# todo: change to session_id
    set batchId "nada-for-now"
    ### TODO: FIX ME TO WORK WITH MORE CHANNELS
    set channel [lindex $channel_list 0]
    ::PUBSUB subscribe $channel $user_id $batchId $callback
}

proc ::xo::api::publish {channel message {format ""} {api_key ""}} {
    ::PUBSUB publish $channel $message $format
}

proc ::xo::api::unsubscribe {{channel_list ""}} {
    ::PUBSUB unsubscribe $channel_list
}
