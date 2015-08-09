
namespace eval ::db_server {
    variable peer
    array set peer [list]
    variable ttl 30000 ;# in milliseconds
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
    set peer($sock,datapos) 0
    set peer($sock,timer)   [after $ttl [list ${nsp}::timeout_client $sock]]

    fconfigure $sock -blocking 0
    trace add variable peer($sock,datalen) write [list ${nsp}::handle_conn $sock]
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

proc ::db_server::handle_conn {sock args} {
    variable peer

    set datalen $peer($sock,datalen)

    if { $datalen == -1 } {
        log "error with sock $sock"
    }

    set pos $peer($sock,datapos)

    if { $pos + 4 <= $datalen } {
        set len_p [binary scan $peer($sock,data) "@${pos}i" len]
        if { $len_p && $datalen >= 4 + $pos + $len } {
            set pos [incr peer($sock,datapos) 4]
            set line_p [binary scan $peer($sock,data) "@${pos}A${len}" line]
            set pos [incr peer($sock,datapos) $len]

            log line=$line 
            # log datalen=$datalen
            log pos=$pos

            # execute command
            set cmd "set x \[{*}${line}\]"
            if { [catch $cmd errmsg] } {
                log "errmsg=$errmsg"
            }

            log "sending reply..."
            ::util::io::write_string $sock [binary encode base64 $x]
            flush $sock
            log "reply sent..."

        }
    }
}

