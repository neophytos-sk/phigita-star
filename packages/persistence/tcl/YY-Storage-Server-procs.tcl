package require math::bignum

namespace eval ::xo::db {;}



proc get_short_line {line {leftIndex "200"} {rightIndex "50"}} {
    if { [string length $line] > 1000 } {
	return "[string range ${line} 0 ${leftIndex}] ... [string range ${line} end-${rightIndex} end]"
    }
    return $line
}


### TCP port, for commands and data
proc ::xo::db::getStoragePort {} "return [ns_config ns/server/[ns_info server] storage_port 7000]"

### UDP port, for membership communications (gossip)
proc ::xo::db::getControlPort {} {
    return 9001 ;# configure this in config-phigita.tcl
}

::xotcl::THREAD create ControlThread {

    variable ttl 30000 ;# this is in milliseconds, i.e. 10000 milliseconds = 10 seconds

    proc Storage_Server {port addr} {
	ns_log notice "listening for control messages port=$port addr=$addr"
	set s [socket -server accept_client -myaddr $addr $port]
	vwait forever
    }

    # Control_Accept --
    #	Accept a connection from a new client.
    #	This is called after a new socket connection
    #	has been created by Tcl.
    #
    # Arguments:
    #	sock	The new socket connection to the client
    #	addr	The client's IP address
    #	port	The client's port number

    proc accept_client {sock addr port} {
	variable peer
	variable ttl

	fconfigure $sock -translation binary


	# Record the client's information

	ns_log notice "Accept $sock from $addr port $port"
	#set peer(addr,$sock) [list $addr $port]
	# ttl = time to live in seconds

	set peer($sock,addr)  [list $addr $port]
	set peer($sock,state) {CONNECTED}
	set peer($sock,ttl)   $ttl
	set peer($sock,data)  {}
	set peer($sock,data_ready) 0
	set peer($sock,timer) [after $ttl [list timeout_client $sock]]

	# Ensure that each "puts" by the server
	# results in a network transmission


	fileevent $sock readable [list ControlHandler $sock]
    }
    
    proc accept_client_non_blocking {sock addr port} {
	variable peer
	variable ttl

	# Record the client's information

	ns_log notice "Accept $sock from $addr port $port"
	#set peer(addr,$sock) [list $addr $port]
	# ttl = time to live in seconds
	set peer($sock,addr)  [list $addr $port]
	set peer($sock,state) {CONNECTED}
	set peer($sock,ttl)   $ttl
	set peer($sock,data)  {}
	set peer($sock,data_ready) 0
	set peer($sock,timer) [after $::ttl [list timeout_client $sock]]

	# Ensure that each "puts" by the server
	# results in a network transmission

	#HERE:fconfigure $sock -translation binary

	### BEGIN non-blocking stuff 
	### http://www.maplefish.com/todd/tcl_net_idioms.html

	fconfigure $sock -blocking 0 ;# and maybe buffering tweaking too
	trace add variable peer($sock,data_ready) write [list handle_client $sock] 

	# Set up a callback for when the client sends data
	fileevent $sock readable [list bg_read $sock]
	### END non-blocking stuff

	#fileevent $sock readable [list ControlHandler $sock]
    }

    ### TIMEOUT STALE CONNECTIONS
    ### If you can disconnect clients that haven't sent you data in a while, 
    ### then do so. Perhaps the client forgot about you, or maybe it became 
    ### a zombie. Don't let it hang around eating up your system resources. 
    ### Let it go. One way to do this is to maintain a time-out for connections. 
    ### Once the timer has expired, check a last accessed time-stamp 
    ### associated with the channel. If the channel hasn't been accessed 
    ### in a certain amount of time, close it. 

    ### Decode complex protocols using a state machine

    ### Since we know we should Do one I/O transaction per event, it makes 
    ### sense to do any protocol decoding one step at a time. While reading 
    ### data (see Read incoming data in the background), you may end up 
    ### reading beyond the end of a message and into the next one (if your
    ### client is sending you messages asynchronously). In this case, there 
    ### is no guarantee that you have a complete message available for handling. 
    ### So, composing a state machine for processing the message will make 
    ### sense. You would loop through your data buffer, setting state as you 
    ### decode, until you either reach the end of the message or reach the 
    ### end of the buffer. Now, that collected state comes into play. You want
    ### to know where to pick up next time (when you have more data read in). 
    ### You can do this by carrying the decoding state as described in Carry 
    ### state using fileevent. It can make for oh so elegant code too. 

    proc bg_read {chan} {
	variable peer
	after cancel $peer($chan,timer)

	if {[eof $chan]} {
	    close $chan
	    set peer($chan,data_ready) -1
	    return
	}
	append peer($chan,data) [read $chan]
	if {[string length $peer($chan,data)] >= $num_bytes} {
	    set peer($chan,data_ready) 1
	}
	after $peer($chan,ttl) [list timeout_client $sock]
    }

    proc timeout_client {chan} {
	variable peer
	if { [info exists peer($chan,addr)] } {
	    catch {close $chan}
	    unset peer($chan,addr)
	}
	# cleanup
    }


    proc handle_client {} {
	variable peer
	ns_log notice "Got: $peer($chan,data)"
	set peer($chan,data_ready) 0
	set peer($chan,data) ""
    }

    # ControlHandler --
    #	This procedure is called when the server
    #	can read data from the client
    #
    # Arguments:
    #	sock	The socket connection to the client

    proc ControlHandler {sock} {
	variable peer

	# Check end of file or abnormal connection drop,
	# then echo data back to the client.

	if { [info exists peer($sock,state)] } {
	    if { $peer($sock,state) eq {BUSY} } {
		### We need some kind of error handling here
		ns_log notice "$sock is busy now, try again in a second [clock milliseconds]"
		### after 1000 ControlHandler $sock
		ns_log notice "we'll try again in a sec [clock milliseconds]"
		return
	    }
	}

	if {[eof $sock]} {
	    close $sock
	    ns_log notice "Close $peer($sock,addr)"
	    unset peer($sock,addr)
	} elseif { [catch {::xo::io::readVarText $sock line utf-8} errmsg] } {
	    close $sock
	    ns_log notice "Close $peer($sock,addr) - error while readVarText errmsg=$errmsg"
	    unset peer($sock,addr)
	} else {
	    # if catch
	    ns_log notice "ControlHandler <- [get_short_line $line 200 10]"
	    if { ${line} ne {} } {
		if { [catch {ControlHandlerCmd $sock {*}$line} errmsg] } {
		    ns_log notice "ControlHandler $sock peeraddr=$peer($sock,addr) ERROR: errmsg=$errmsg"
		}
	    }
	}
    }


    proc ControlHandlerCmd {sock cmd args} {
	if { [catch {ControlHandlerCmd=${cmd} $sock {*}${args}} errmsg] } {
	    ns_log notice "ControlHandlerCmd errmsg=[get_short_line $errmsg]"
	}
    }

    proc ControlHandlerCmd=touch {sock args} {
	ns_log notice "touching $args"
	foreach tablekey ${args} {
	    ns_cache_eval -force -- xo_db_cache TABLE:${tablekey} {
		return [clock clicks]
	    }
	}
    }

    proc ControlHandlerCmd=echo {sock args} {
	global peer
	ns_log notice "echo $peer($sock,addr) $args"
	::xo::io::writeVarText $sock $args
    }

    proc ControlHandlerCmd=delete {sock rowKey columnPath ts} {
	lassign [split $rowKey {:}] keyspace key
	lassign [split $columnPath {:}] cf columnName

	ns_log notice "DEL ${keyspace}:${key},${cf}:${columnName}\[ts=$ts\]"
	set path /web/db/data/${keyspace}
	file mkdir ${path}
	set outfile [file join ${path} ${cf}-1-Data.db]
	set fp [open $outfile a]
	puts $fp [list "DEL" ${key} ${columnName}]
	close $fp
    }

    proc ControlHandlerCmd=insert {sock rowKey columnPath value ts} {
	#set utf8_value [encoding convertfrom utf-8 $value]
	lassign [split $rowKey {:}] keyspace key
	lassign [split $columnPath {:}] cf columnName

	ns_log notice "SET ${keyspace}:${key},${cf}:${columnName}\[ts=$ts\]"
	set path /web/db/data/${keyspace}
	file mkdir ${path}
	set outfile [file join ${path} ${cf}-1-Data.db]
	set fp [open $outfile a]
	puts $fp [list "SET" ${key} ${columnName} ${value}]
	close $fp
    }


    proc ControlHandlerCmd=GET_SLICE_TOP {sock x y_parent limit sortField {sortDir "increasing"} {pk "id"} {predicate ""} {consistency_level "1"}} {
	set ds [::xo::db::get_slice_top $x $y_parent $limit $sortField $sortDir $pk $predicate $consistency_level]
	#::xo::io::writeVarText $sock [base64::encode [$ds toDict]]
	::xo::io::writeVarText $sock [$ds toRecordSet] utf-8
	flush $sock
	ns_log notice "StorageServer: GET_SLICE_TOP flushed socket $sock"
    }

    proc ControlHandlerCmd=GET_SLICE {sock x y_parent {pk "id"} {predicate ""} {consistency_level "1"}} {
	#fconfigure $sock -encoding utf-8
	#package require base64
	set ds [::xo::db::get_slice $x $y_parent $pk $predicate $consistency_level]
	#::xo::io::writeVarText $sock [base64::encode [$ds toDict]]
	::xo::io::writeVarText $sock [$ds toRecordSet] utf-8
	#::xo::io::writeVarText $sock [ns_uuencode [$ds toRecordSet]]
	flush $sock
	ns_log notice "StorageServer: GET_SLICE flushed socket $sock"
    }


    proc bg_receive_file_done {in out chunk bytes {errormsg ""}} {
	global BG_RECV_FILE_DONE peer
	if { $chunk != $bytes } {
	    ns_log notice "ERROR: NOT ENOUGH BYTES RECEIVED: bg_receive_file_done in=$in out=$out chunk=$chunk bytes=$bytes errormsg=$errormsg"
	}
	set BG_RECV_FILE_DONE($peer($in,addr)) 1
	set peer($in,state) IDLE
	close $in
	close $out
    }
    # path = destination_directory
    proc ControlHandlerCmd=receive_file {sock name size path args} {
	global BG_RECV_FILE_DONE peer
	set peer($sock,state) BUSY
	fileevent $sock readable {} ;# HERE: temporary solution to file/socket busy errors while fcopy

	ns_log notice "receiving from $peer($sock,addr) file $name size=$size path=$path args=$args"
	fconfigure $sock -translation binary

	file mkdir $path

        #gets $sock line
        #foreach {name size} $line {}

        set fully_qualified_filename [file join $path [file tail $name]]
	if { [file exists $fully_qualified_filename] } {
	    ns_log notice "ContronHandlerCmd=receive_file: file already exists: $fully_qualified_filename"
	}
        set fp [open $fully_qualified_filename w]
        fconfigure $fp -translation binary

        fcopy $sock $fp -size $size -command [list bg_receive_file_done $sock $fp $size]
	if { [catch { flush $sock } errmsg] } {
	    ns_log notice "ControlHandlerCmd=receive_file errmsg=$errmsg"
	    return
	}

        ###close $sock
        #close $fp
	#ns_log notice "receive_file in progress... ms=[clock milliseconds]"
	vwait BG_RECV_FILE_DONE($peer($sock,addr))
	unset BG_RECV_FILE_DONE($peer($sock,addr))
    }


    # SYNC_TREE aias:/web/data/storage/ ada:/web/db/storage/ $ada_stats
    proc ControlHandlerCmd=SYNC_TREE {sock local_dir remote_addr remote_dir remote_stats_map args} {
	ns_log notice "SYNC_TREE: accepted request to sync local_dir=$local_dir remote_addr=$remote_addr remote_dir=$remote_dir"

	build.tree.stat.info local_stats $local_dir
	set local_stats_map [array get local_stats]
	array set remote_stats $remote_stats_map
	###ns_log notice "StorageThread: SYNC_TREE local_stats_map=---local_stats_map"
	set total_files [llength [array names local_stats]]
	set sent_files 0 
	set existing_files 0
	set total_size 0
	foreach {filename size} ${local_stats_map} {
	    if { ![info exists remote_stats($filename)] } {
		incr sent_files
		### copy.from.to [file join $FROM_DIR $f] [file join $TO_DIR $f]
		### sendRR RECV_FILE $filename [file size $filename] $local_dir $remote_dir
		#ns_log notice "bg_sendfile [file join $local_dir $filename] $remote_addr $remote_dir"
		#after idle [list after 0 doOneStep]
		#after idle [list after 0 bg_sendfile [file join $local_dir $filename] $remote_addr [file join $remote_dir [file dirname $filename]]]
		bg_sendfile [file join $local_dir $filename] $remote_addr [file join $remote_dir [file dirname $filename]]

		if { [incr total_size $size] > 1000000 } {
		    ns_log notice "SYNC_TREE: host [ns_info hostname] says it has sent numFiles=${sent_files} totalSize=$total_size files (so far) to $remote_addr"
		    ns_log notice "remember to remove the break in SYNC_TREE after you figure out a way to throttle multiple bg_sendfile calls"
		    break
		}

	    } elseif { $size != $remote_stats($filename) } {
		ns_log notice "RESEND (TODO RSYNC)... The size for $filename in $local_dir doesn't match $remote_addr $remote_dir"
		bg_sendfile [file join $local_dir $filename] $remote_addr [file join $remote_dir [file dirname $filename]]
	    } else {
		incr existing_files
	    }
	}
	ns_log notice "SYNC_TREE: host [ns_info hostname] says: total_size=$total_size ${existing_files}+${sent_files}/${total_files} sent to $remote_addr"
    }

} -persistent 1

if { [::xo::db::getStoragePort] ne {} } {
    if { [::xo::kit::performance_mode_p] } {
	ns_schedule_proc -once 0 ControlThread do -async Storage_Server [::xo::db::getStoragePort] [ns_info hostname]
    } else {
	ns_schedule_proc -once 0 ControlThread do -async Storage_Server [::xo::db::getStoragePort] localhost
    }
}



#
# A client of the storage service.
#

proc Control_Client {host port} {
    set s [socket $host $port]
    fconfigure $s -translation binary
    return $s
}

proc Control_AsyncClient {host port} {
    set s [socket -async $host $port]
    fconfigure $s -translation binary
    return $s
}


if { [ns_config ns/server/[ns_info server] performance_mode_p 1] } {
    proc getAllHosts {} {
	return {atlas}
    }
    proc getRing {} {
	#### note that bignums were generated by ns_sha1 and that they are sorted in increasing order
	#return {ada {bignum 0 41984 36959 22427 13770 874 17375 21078 1580 10572 58602}}
	return {atlas {bignum 0 41984 36959 22427 13770 874 17375 21078 1580 10572 58602}}
	### return {aias {bignum 0 63340 40119 14187 33072 38548 3048 41650 26792 6835 15718} ada {bignum 0 41984 36959 22427 13770 874 17375 21078 1580 10572 58602}}
	### FIXME: just a quick draft for testing/debugging - use real endpoint/host tokens
	set result ""
	foreach host [getAllHosts] {
	    set isAvailable 1
	    lappend result [list $host [ns_sha1 $host] $isAvailable]
	}
	return $result
    }

} else {
    proc getAllHosts {} {
	#return {epimetheus}
	return {localhost}
    }
    proc getRing {} {
	#### note that bignums were generated by ns_sha1 and that they are sorted in increasing order
	return {localhost-0 {bignum 0 63340 40119 14187 33072 38548 3048 41650 26792 6835 15718} localhost-1 {bignum 0 41984 36959 22427 13770 874 17375 21078 1580 10572 58602}}
    }

}


proc getHostFor {rowkey} {
    lassign [split $rowkey {!}] keyspace key
    $keyspace instvar partitioner
    set token [$partitioner getToken $key]
    set theRing [getRing]
    foreach {ep_host ep_token} $theRing {
	if { [::math::bignum::lt $token $ep_token] } {
	    ns_log notice "selected ep=$ep_host (consistent hashing attempt)... token for $rowkey is... $token"
	    return $ep_host
	}
    }
    lassign $theRing ep_host ep_token
    return $ep_host
    ### getRing
    ### search for right range based on token of the key and token of the endpoints
    return $ep_host
}

proc bg_sendOneWay {line} {
    #::ControlThread do -async sendOneWay $line
    set port [::xo::db::getStoragePort]
    foreach host [getAllHosts] {
	if { [catch {
	    set s [Control_AsyncClient ${host} $port]
	    ::xo::io::writeVarText $s ${line}
	    close $s
	} errmsg] } {
	    ns_log notice "sendOneWay: errmsg=$errmsg"
	}
    }
}

proc fg_sendMessageTo {host line} {
    set result ""
    set port [::xo::db::getStoragePort]
    if { [catch {
	set s [Control_Client ${host} ${port}]
	::xo::io::writeVarText $s ${line} utf-8
	flush $s
	#ns_log notice "just flushed s=$s"
	::xo::io::readVarText $s result utf-8
	close $s
    } errmsg] } {
	ns_log notice "sendMessageTo: host=$host line=$line errmsg=$errmsg"
    }
    return $result
}

proc bg_sendMessageTo {host line} {
    ns_log notice "sendTo $host line = [string range $line 0 200] ... [string range $line end-10 end]"
    set result ""
    set port [::xo::db::getStoragePort]
    if { [catch {
	set s [Control_AsyncClient ${host} ${port}]
	::xo::io::writeVarText $s ${line} utf-8
	flush $s
	#ns_log notice "just flushed s=$s"
	# NOT SURE IF THIS IS NEEDED ::xo::io::readVarText $s result
	close $s
    } errmsg] } {
	ns_log notice "bg_sendMessageTo: host=$host line=[get_short_line $line] errmsg=$errmsg"
    }
    return $result
}


proc monitor_sock {channelId} {
    global TMPCOUNTER
    ns_log notice "StorageClient: pending=[chan pending input $channelId] before_read=$TMPCOUNTER"
    incr TMPCOUNTER [string bytelength [read $channelId]]
    ns_log notice "StorageClient: pending=[chan pending input $channelId] after_read=$TMPCOUNTER"
}

proc bg_sendfile_done {in out chunk callback bytes {errormsg ""}} {
    global BG_SENDFILE_DONE 
    set BG_SENDFILE_DONE($out) 1
    if { $chunk != $bytes } {
	ns_log notice "bg_sendfile_done in=$in out=$out callback=$callback chunk=$chunk bytes=$bytes errormsg=$errormsg"
    }

    close $in
    close $out

}

proc bg_sendfile {filename remote_addr remote_dir {callback ""}} {
    global BG_SENDFILE_DONE peer

    set size [file size $filename]
    set fp [open $filename]
    fconfigure $fp -translation binary

    set name [file tail $filename]
    set port [::xo::db::getStoragePort]
    set line [list receive_file $name $size $remote_dir]
    if { [catch {
	set channel [Control_AsyncClient ${remote_addr} ${port}]
	::xo::io::writeVarText $channel $line utf-8
	flush $channel
	fconfigure $channel -translation binary
	fcopy $fp $channel -size $size -command [list bg_sendfile_done $fp $channel $size $callback]
	#close $fp
	#close $channel
	vwait BG_SENDFILE_DONE($channel)
	unset BG_SENDFILE_DONE($channel)
    } errmsg] } {
	ns_log notice "sendfile: errmsg=$errmsg"
    }
}


proc bg_rsync_tree {remote_addr remote_dir local_dir} {
    set local_addr [ns_info hostname]
    build.tree.stat.info local_stats $local_dir
    set local_stats_map [array get local_stats]
    set line "SYNC_TREE [list $remote_dir $local_addr $local_dir $local_stats_map]"
    bg_sendMessageTo $remote_addr $line
}

set COMMENT {
    # A sample client session looks like this
    #   set s [Control_Client localhost 2540]
    #   puts $s "Hello!"
    #   gets $s line
}

proc mk_verb {verb proc_name} {
    rename ${proc_name} ${proc_name}_
    proc ${proc_name} {args} [subst -nocommands {
	return [fg_sendMessageTo epimetheus "${proc_name} \${args}"]
    }]
}




proc net_get_slice {args} {
    set x [lindex $args 0]
    set y [lindex $args 1]
    set host [getHostFor $x]
    set ds [::db::Set new -type $y]
    $ds fromRecordSet [fg_sendMessageTo $host "GET_SLICE ${args}"]
    return $ds
}

proc cf_to_relname {cf} {
    return xo__[string tolower [namespace tail $cf]]
}
proc postgresql_to_sstable {cf} {
    set conn [DB_Connection new]
    set relname [cf_to_relname $cf]
    set mydict [$conn queryDict "select nspname,relname from pg_class cl inner join pg_namespace nsp on (cl.relnamespace=nsp.oid) where relname=[ns_dbquotevalue ${relname}]"]
    dict with mydict {
	foreach row $rows {
	    lassign $row nspname relname
	    set queryDict [$conn queryDict "select id,title from ${nspname}.${relname}"]
	    lappend result [list $nspname $queryDict]
	}
    }
    return $result
}

proc build.tree.stat.info {statsVar base_dir {dir ""}} {
    upvar $statsVar stats
    array set stats {}
    foreach f [glob  -nocomplain -tails -directory $base_dir [file join $dir *]] {
	set filename [file join ${base_dir} $f]
	if { [file isdirectory $filename] } {
	    build.tree.stat.info stats $base_dir $f
	} elseif { [file isfile $filename] } {
	    set stats([list $f]) [file size $filename]
	}
    }
}



if { [ns_info hostname] ne {atlas} } {

    # ns_atstartup script ?args?
    # ad_after_server_initialization
    proc sync_data_with_master {} {
	set directories {fonts storage books}
	foreach dirname $directories {
	    ns_log notice "started rsync for ${dirname}"
	    bg_rsync_tree atlas /web/data/${dirname}/ /web/local-data/${dirname}/
	}
    }
    ### -once
    ns_schedule_proc -thread [expr {3*3600}] sync_data_with_master
}





proc testmsg1 {} {
    set host [getHostFor User!1756]
    return [fg_sendMessageTo $host "GET_SLICE [list User!1756 ::Blog_Item]"]
}
proc testmsg2 {} {
    set host [getHostFor User!814]
    return [fg_sendMessageTo $host "GET_SLICE [list User!814 ::Blog_Item]"]
}
proc testmsg3 {} {
    set host aias
    return [fg_sendMessageTo $host "GET_SLICE [list User!814 ::Blog_Item]"]
}
proc testmsg4 {} {
    set host [getHostFor User!814]
    return [fg_sendMessageTo $host "GET_SLICE [list User!814 ::Blog_Item_Label]"]
}


proc testds1 {} {
    set host [getHostFor User!1756]
    set ds [::db::Set new -pathexp {{User 1756}} -type ::Blog_Item]
    $ds fromRecordSet [fg_sendMessageTo $host "GET_SLICE [list User!1756 ::Blog_Item]"]
    return $ds
}

proc testbin1 {} {
    set host [ns_info hostname]
    bg_sendfile /web/data/storage/10-814/1346/c-1346.pdf $host /web/db/blob/
}
proc testbin2 {} {
    bg_rsync_tree epimetheus /web/tmp2/ /web/db/blob/
}


proc testecho1_read_cb {args} {
    ns_log notice "testecho1_read_cb args=$args"
}
proc testecho1_write_cb {args} {
    ns_log notice "testecho1_write_cb args=$args"
}

proc testecho1 {{message "Hello World!"}} {
    set host aias
    set port [::xo::db::getStoragePort]
    set s [Control_AsyncClient $host $port]
    fileevent $s readable testecho1_read_cb
    fileevent $s writable testecho1_write_cb
    ::xo::io::writeVarText $s "echo [list $message]"
    #::xo::io::writeVarText $s "GET_SLICE [list User!814 ::Blog_Item_Label]"
}
