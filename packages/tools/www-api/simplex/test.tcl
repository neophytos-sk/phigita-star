#ad_maybe_redirect_for_registration

#::xo::kit::reload [acs_root_dir]/packages/tools/tcl/storage-procs.tcl
#::xo::kit::reload [acs_root_dir]/packages/tools/tcl/pubsub-thread-procs.tcl

ad_page_contract {
	@author Neophytos Demetriou
} {
    cmd:notnull
    {ie "utf-8"}
    {oe "utf-8"}
    {argv ""}
    {callback "no_callback"}
    {batch_count:integer ""}
    {message_format:trim ""}
}


# TODO:
# - address different sessions issues

if { -1 == [lsearch "PUT SET GET DEL INCR DECR prefix_match prefix_delete size whoami batch_mutation subscribe unsubscribe publish" $cmd] } {
    rp_returnnotfound
    return
}


if { [ad_conn user_id] == 0 && $cmd ne {whoami} } {
    ad_maybe_redirect_for_registration
}


::xo::storage::init

if { $cmd eq {PUT} } {

    lassign $argv key value
    set json [::xo::storage::PUT $key $value]
    doc_return 200 text/plain "${callback}(${json});"

} elseif { $cmd eq {batch_mutation} } {

    set js ""
    for {set i 0} {$i < $batch_count} {incr i} {
	set callback_i [::xo::kit::queryget "callback${i}"]
	set cmd [::xo::kit::queryget "cmd${i}"]
	set argv [::xo::kit::queryget "argv${i}"]
	lassign $argv key value
	if { $cmd eq {PUT} || ${cmd} eq {put} } {
	    set json [::xo::storage::PUT $key $value]
	    if { $callback_i ne {} } {
		append js "${callback_i}(${json});"
	    }
	} elseif { ${cmd} eq {SET} } {
	    set key [::xo::kit::queryget "argv${i}_key"]
	    set value [::xo::kit::queryget "argv${i}_val"]
	    set json [::xo::storage::SET ${key} ${value}]
	    if { $callback_i ne {} } {
		append js "${callback_i}(${json});"
	    }
	} elseif { ${cmd} eq {DEL} } {
	    set json [::xo::storage::prefix_delete "${key}="]
	    if { $callback_i ne {} } {
		append js "${callback_i}(${json});"
	    }
	}
    }
    if { $callback ne {no_callback} } {
	append js "${callback}();"
    }
    doc_return 200 text/plain ${js}

} elseif { $cmd eq {GET} } {

    lassign $argv key
    set json [::xo::storage::GET $key]
    doc_return 200 text/plain "${callback}($json);"

} elseif { $cmd eq {prefix_match} } {
    
    lassign $argv prefix limit
    set json [::xo::storage::prefix_match $prefix "0" $limit "1" "raw_data"]
    doc_return 200 text/plain "${callback}($json);"
	
} elseif { $cmd eq {prefix_delete} } {
    
    lassign $argv key
    set json [::xo::storage::prefix_delete "${key}"]
    doc_return 200 text/plain "${callback}($json);"
	
} elseif { $cmd eq {DEL} } {
    
    lassign $argv key
    set json [::xo::storage::prefix_delete "${key}="]
    doc_return 200 text/plain "${callback}($json);"
	
} elseif { $cmd eq {SET} } {

    lassign $argv key value
    set json [::xo::storage::SET $key $value]
    doc_return 200 text/plain "${callback}(${json});"

} elseif { $cmd eq {whoami} } {
    set user_id [ad_conn user_id]
    if { $user_id == 0 } {
	set user_id "anon-[ad_conn session_id]"
    }
    set key "STATE.${user_id}.num_sessions"
    set session_id [::xo::storage::INCR $key]
    set json [::util::map2json user_id $user_id session_id $session_id]
    doc_return 200 text/plain "${callback}(${json})"
} elseif { $cmd eq {subscribe} } {
    # subscribe channel [channel ...]
    set channel_list $argv
    ::xo::api::subscribe $channel_list $callback
} elseif { $cmd eq {unsubscribe} } {
    # unsubscribe [channel [channel ...]]
    # set channel_list $argv
    # ::xo::storage::unsubscribe $channel_list
} elseif { $cmd eq {publish} } {
    # publish channel message
    # Return value: Integer reply: the number of clients that received the message.
    lassign $argv channel message
    ::xo::api::publish $channel $message $message_format
    set json [::util::map2json async 1 channel $channel message $message]
    doc_return 200 text/plain "${callback}(${json});"
} elseif { $cmd eq {INCR} } {
    lassign $argv key
    set value [::xo::storage::INCR $key]
    set json [::util::map2json value $value]
    doc_return 200 text/plain "${callback}(${json})"
} elseif { $cmd eq {DECR} } {
    lassign $argv key
    set value [::xo::storage::DECR $key]
    set json [::util::map2json value $value]
    doc_return 200 text/plain "${callback}(${json})"
}

