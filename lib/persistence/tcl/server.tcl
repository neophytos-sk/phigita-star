package require Thread

global Persistence
array set Persistence {}

namespace eval ::db_server {
    variable ttl 10000 ;# in milliseconds
}

proc ::db_server::Persistence_Server {addr port} {
    global Persistence

    set initcmd {
        package require core

        config section ::persistence
        config use "server"

        package require persistence

        log new_thread,[thread::id]

        ::persistence::server::init
        ::persistence::load_types_from_db
        ::persistence::ss::init
    }

    # Create thread pool with max 8 worker threads.
    # Using the internal C-based thread pool
    set Persistence(tpid) [tpool::create -maxworkers 8 -initcmd $initcmd]

    # init thread
    tpool::post -detached $Persistence(tpid) [list set _ {}]

	if { ![info exists Persistence(listen)] } {
    	set Persistence(listen) [socket -server ::db_server::SockAcceptHelper -myaddr $addr $port]
        log "started server..."
	}
}

# Helper procedure to solve Tcl shared-channel bug when responding
# to incoming connection and transfering the channel to other thread(s).
# (copied from the Thread package, see phttpd.tcl)

proc ::db_server::SockAcceptHelper {sock ipaddr port} {
    after idle [list ::db_server::SockAccept $sock $ipaddr $port]
}

# Accept a new connection from the server and set up a handler
# to read the request from the client.

proc ::db_server::SockAccept {sock ipaddr port} {
    log $sock
    global Persistence

    incr Persistence(accepts)

    fconfigure $sock -blocking 0 -translation {auto crlf}

    #
    # Detach the socket from current interpreter/tnread.
    # One of the worker threads will attach it again.
    #

    thread::detach $sock

    #
    # Send the work ticket to threadpool.
    # 

    tpool::post -detached $Persistence(tpid) [list ::db_server::SockTicket $sock]

}

proc ::db_server::SockInit {sock} {
    #log $sock

    variable ttl
	upvar #0 peer$sock peer
    if { [info exists peer(timer)] } {
        after cancel $peer(timer)
        unset peer(timer)
    }
    set peer(data)    {}
    set peer(datalen) 0
    set peer(datapos) 0
    set peer(ttl)     $ttl
    set peer(timer) [after $ttl ::db_server::SockDone $sock]
}

# Job ticket to run in the thread pool thread.
proc ::db_server::SockTicket {sock} {
    # log $sock
    thread::attach $sock

    SockInit $sock

	chan configure $sock -translation binary
    chan event $sock readable [list ::db_server::SockRead $sock]

    # End of processing is signalized here.
    # This will release the worker thread.
    vwait ::done
}

proc ::db_server::SockRead {sock} {
    upvar #0 peer$sock peer

	set bytes [read $sock]

	if { $bytes eq {} } {
		log exiting,$sock,$bytes
		SockDone $sock
		return
	}

	append peer(data) $bytes
	incr peer(datalen) [string length $bytes]
	::db_server::SockParse $sock

}

proc ::db_server::SockDone {sock} {
    log "closing socket... $sock"

    upvar #0 peer$sock peer

    if { [info exists peer(timer)] } {
        after cancel $peer(timer)
    }

	if { ![catch { close $sock }] } {
        # may have been closed from the other side
        unset peer
    }

	set ::done 1
}

proc ::db_server::SockReset {sock} {
    # log $sock
    SockInit $sock
}

proc ::echo {args} {
    return {*}$args
}

proc ::db_server::SockParse {sock} {
    # log $sock
    upvar #0 peer$sock peer

    set datalen $peer(datalen)

    if { $datalen == -1 } {
        log "error with sock $sock"
    }

    set pos $peer(datapos)

    if { $pos + 4 <= $datalen } {
        set len_p [binary scan $peer(data) "@${pos}i" len]
        if { $len_p && $datalen >= 4 + $pos + $len } {
            set pos [incr peer(datapos) 4]
            set line_p [binary scan $peer(data) "@${pos}a${len}" line]
            set pos [incr peer(datapos) $len]

            # log line=$line 
            # log datalen=$datalen
            # log pos=$pos

            exec_cmd_line ${sock} ${line}

        }
    }
}

proc ::db_server::exec_cmd_line {sock line} {
    # log entry,$line

    set ok_retcode 0
    set error_retcode 1

    set script "set x \[{*}${line}\]"
    set error_p [catch ${script} errmsg]

    # log line=$line
    # log x=$x

    if { ${error_p} } {
        log "script=$script"
        log "errmsg=$errmsg"
        log "errorInfo=$::errorInfo"
        ::util::io::write_string $sock $errmsg
        ::util::io::write_char $sock $error_retcode
        flush $sock
    } else {
        ::util::io::write_string $sock $x
        ::util::io::write_char $sock $ok_retcode
        flush $sock
    }

    SockReset $sock

    # log leave,$line

}

proc bgerror {msg} {
    global errorInfo
    puts stderr "bgerror: $msg\n$errorInfo"
}
