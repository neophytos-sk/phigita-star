
namespace eval ::db_client {
    variable peer
    array set peer [list]

    variable sock ""
    variable ttl 10000 ;# in milliseconds
}

proc ::db_client::init {addr port} {
    variable peer
    variable sock
    variable ttl

    set nsp ::db_client

    set sock [socket $addr $port]

    if { $sock eq {} } {
        error "failed to open socket to ${addr}:${port}"
    }

    set peer($sock,addr) [list $addr $port]
    set peer($sock,state) "CONNECTED"
    set peer($sock,ttl) $ttl
    set peer($sock,data) {}
    set peer($sock,datalen) 0
    set peer($sock,datapos) 0
    set peer($sock,timer) [after $ttl [list ${nsp}::SockDone $sock]]
    # peer($sock,retcode) is only set after a response is received
    # peer($sock,done) is only set after a response is received

    chan configure $sock -translation binary -blocking 0
    trace add variable peer($sock,datalen) write [list ${nsp}::handle_conn $sock]
    fileevent $sock readable [list ${nsp}::bg_read $sock]
}

proc ::db_client::send {argv} {
    variable sock
    assert { $sock ne {} }
    ::util::io::write_string $sock $argv
    flush $sock
}

proc ::db_client::recv {} {
    variable sock
    variable peer

    assert { $sock ne {} }

    # log "recv $sock"

    vwait ::db_client::peer($sock,done)

    if { $sock eq {} } {
        error "recv: no sock info after vwait"
    }

    set retcode $peer($sock,retcode)

    if { [boolval $retcode] } {
        error $peer($sock,done)
    } else {
        return $peer($sock,done)
    }

}

proc ::db_client::bg_read {sock} {
    variable peer
    after cancel $peer($sock,timer)

    # log "bg_read $sock"

    set bytes [read $sock]
    set scan_p [binary scan ${bytes} a* bytes]
    assert { $scan_p } 
    # set bytes [binary format a* ${bytes}]
    append peer($sock,data) $bytes 
    incr peer(${sock},datalen) [string length ${bytes}]

    # after $peer($sock,ttl) [list ::db_client::timeout_conn $sock]
}

proc ::db_client::SockDone {sock} {
    variable peer
    if { [info exists peer($sock,addr)] } {
        catch { close $sock }
        log  "closing connection $peer($sock,addr)"
        set peer($sock,done) ""
        unset peer($sock,addr)
        set ::db_client::sock ""
    }
    # cleanup
}

proc ::db_client::handle_conn {sock args} {
    variable peer

    set datalen $peer($sock,datalen)

    if { $datalen == -1 } {
        log "error with sock $sock"
    }

    set pos $peer($sock,datapos)

    set len_p [binary scan $peer($sock,data) "@${pos}i" len]
    if { $len_p && $datalen >= 5 + $pos + $len } {

        # int length (4 bytes)
        set pos [incr peer($sock,datapos) 4]

        # bytearray data ($len bytes)
        set line_p [binary scan $peer($sock,data) "@${pos}a${len}" line]
        set pos [incr peer($sock,datapos) $len]

        # char retcode (1 byte)
        set retcode_p [binary scan $peer($sock,data) "@${pos}c" retcode]
        set peer($sock,retcode) $retcode
        set pos [incr peer($sock,datapos)]

        # log line=$line

        set peer($sock,done) $line

    }

}


proc ::db_client::exec_cmd {args} {

    variable sock
    if { $sock eq {} } {
        set myaddr localhost
        set myport 9900
        ::db_client::init $myaddr $myport
    }
    # log "sending command... {*}$args"
    ::db_client::send $args
    set response [::db_client::recv]
    # log response=$response
    SockDone $sock
    return $response

}


proc bgerror {msg} {
    global errorInfo
    puts stderr "bgerror: $msg\n$errorInfo"
}

