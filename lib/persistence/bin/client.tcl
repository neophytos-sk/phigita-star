#!/bin/sh
#\
 exec tclsh "$0" "$@"

package require core

namespace eval ::db_client {
    variable peer
    array set peer [list]

    variable sock
    variable ttl 10000 ;# in milliseconds
}

proc ::db_client::init {addr port} {
    variable peer
    variable sock
    variable ttl

    set nsp ::db_client

    set sock [socket $addr $port]

    set peer($sock,addr) [list $addr $port]
    set peer($sock,state) "CONNECTED"
    set peer($sock,ttl) $ttl
    set peer($sock,data) {}
    set peer($sock,datalen) 0
    set peer($sock,timer) [after $ttl [list ${nsp}::timeout_conn $sock]]

    chan configure $sock -translation binary -blocking 0
    trace add variable peer($sock,datalen) write [list ${nsp}::handle_conn $sock]
    fileevent $sock readable [list ${nsp}::bg_read $sock]
}

proc ::db_client::send {argv} {
    variable sock
    ::util::io::write_string $sock $argv
    flush $sock
}

proc ::db_client::recv {} {
    variable sock
    variable peer

    log "recv $sock"

    vwait ::db_client::peer($sock,done)

    return $peer($sock,done)

}

proc ::db_client::bg_read {sock} {
    variable peer
    after cancel $peer($sock,timer)

    log "bg_read $sock"

    set bytes [read $sock]
    append peer($sock,data) $bytes
    incr peer($sock,datalen) [string length $bytes]

    after $peer($sock,ttl) [list ::db_client::timeout_conn $sock]
}

proc ::db_client::timeout_conn {sock} {
    variable peer
    if { [info exists peer($sock,addr)] } {
        catch { close $sock }
        log  "closing connection $peer($sock,addr)"
        set peer($sock,done) ""
        unset peer($sock,addr)
    }
    # cleanup
}

proc ::db_client::handle_conn {sock args} {
    variable peer
    set datalen $peer($sock,datalen)
    if { $datalen >= 4 } {
        set pos 0
        set len_p [binary scan $peer($sock,data) "@${pos}i" len]
        if { $len_p && $datalen >= 4 + $len } {
            set pos 4
            log "response len=$len"
            set response_p [binary scan $peer($sock,data) "@${pos}A${len}" response]
            set peer($sock,datalen) 0
            set peer($sock,done) $response
            log "done"
        }
    }
}

set myaddr localhost
set myport 9900
::db_client::init $myaddr $myport
::db_client::send $argv
set response [::db_client::recv]

log response=$response

