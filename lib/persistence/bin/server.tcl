#!/bin/sh
#\
 exec tclsh "$0" "$@"

package require core
package require persistence


namespace eval ::db_server {
    variable peer
    array set peer [list]
    variable ttl 30
}

proc ::db_server::accept_client_async {sock addr port} {
    variable peer
    variable ttl

    set nsp ::db_server

    set peer($sock,addr)    [list $addr $port]
    set peer($sock,state)   "CONNECTED"
    set peer($sock,ttl)     $ttl
    set peer($sock,data)    {}
    set peer($sock,datalen) 0
    set peer($sock,timer)   [after $ttl [list ${nsp}::timeout_client $sock]]

    fconfigure $sock -blocking 0
    trace add variable peer($sock,datalen) write [list ${nsp}::handle_client $sock]
    fileevent $sock readable [list ${nsp}::bg_read $sock]
}

proc ::db_server::bg_read {sock} {
    variable peer
    after cancel $peer($sock,timer)

    if { [eof $sock] } {
        close $sock
        set peer($sock,datalen) -1
        return
    }

    set bytes [read $sock]
    append peer($sock,data) $bytes
    incr peer($sock,datalen) [string length $bytes]

    after $peer($sock,ttl) [list ::db_server::timeout_client $sock]

}

proc ::db_server::timeout_client {sock} {
    variable peer
    if { [info exists peer($sock,addr)] } {
        catch { close $sock }

        log "closing connection $peer($sock,addr)..."

        unset peer($sock,addr)
    }
    # cleanup
}

proc ::db_server::handle_client {sock args} {
    variable peer
    set datalen $peer($sock,datalen)

    if { $datalen >= 4 } {
        set pos 0
        set cmdlen_p [binary scan $peer($sock,data) "@${pos}i" cmdlen]
        if { $cmdlen_p && $datalen >= 4 + $cmdlen } {
            set pos 4
            set cmdline_p [binary scan $peer($sock,data) "@${pos}A${cmdlen}" cmdline]

            puts datalen=$datalen
            puts cmdline=$cmdline 

            set peer($sock,datalen) 0

        }
    }

    #set peer($sock,datalen) 0
    #set peer($sock,data) ""
}

proc Server {startTime channel clientaddr clientport} {
    ::util::io::read_string $channel cmd
    puts "server received the following command"


    puts "Connection from $clientaddr registered"
    set now [clock seconds]
    puts $channel [clock format $now]
    puts $channel "[expr { $now - $startTime }] since start"
    close $channel
}

set myaddr 127.0.0.1
set myport 9900
log "starting server ${myaddr}:${myport}"
set channel [socket -server ::db_server::accept_client_async -myaddr $myaddr $myport]
chan configure $channel -blocking 0 -translation binary
vwait forever
