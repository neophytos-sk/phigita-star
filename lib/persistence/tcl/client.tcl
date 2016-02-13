
namespace eval ::db_client {
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

    upvar #0 peer$sock peer
    set peer(addr) [list $addr $port]
    set peer(state) "CONNECTED"
    set peer(ttl) $ttl
    set peer(data) {}
    set peer(datalen) 0
    set peer(datapos) 0
    set peer(timer) [after $ttl [list ${nsp}::SockDone $sock]]
    # peer(retcode) is only set after a response is received
    # peer(done) is only set after a response is received

    chan configure $sock -translation binary -blocking 0
    fileevent $sock readable [list ${nsp}::SockRead $sock]
}

proc ::db_client::send {argv} {
    variable sock
    assert { $sock ne {} }
    ::util::io::write_string $sock $argv
    flush $sock
}

proc ::db_client::SockReset {sock} {
    variable ttl
    upvar #0 peer$sock peer
    catch {unset ::done($sock)}
    set peer(retcode) {}
    set peer(data) {}
    set peer(datalen) 0
    if { [info exists peer(timer)] } {
        after cancel $peer(timer)
        unset peer(timer)
    }
    set peer(timer) [after $ttl [list ::db_client::SockDone $sock]]
}

proc ::db_client::recv {} {
    variable sock
    assert { $sock ne {} }

    # log "recv $sock"

    # SockReset $sock
    vwait ::done($sock)

    if { $sock eq {} } {
        error "recv: no sock info after vwait"
    }

    upvar #0 peer$sock peer
    set retcode $peer(retcode)

    if { [boolval $retcode] } {
        error $::done($sock)]
    } else {
        return [set ::done($sock)]
    }

}

proc ::db_client::SockRead {sock} {
    upvar peer$sock peer

    after cancel $peer(timer)
    unset peer(timer)

    # log "bg_read $sock"

    set bytes [read $sock]
    if { $bytes eq {} } {
        # SockDone $sock
        # return
    }

    set scan_p [binary scan ${bytes} a* bytes]
    assert { $scan_p } 
    append peer(data) $bytes 
    incr peer(datalen) [string length ${bytes}]

    SockParse $sock

    set peer(timer) [after $peer(ttl) [list ::db_client::SockDone $sock]]
}

proc ::db_client::SockDone {sock} {
    upvar #0 peer$sock peer

    if { [info exists peer(addr)] } {
        catch { close $sock }
        log  "closing connection $peer(addr)"
        set ::done($sock) ""
        unset peer(addr)
        set ::db_client::sock ""
    }
    # cleanup
}

proc ::db_client::SockParse {sock args} {
    upvar #0 peer$sock peer

    set datalen $peer(datalen)

    if { $datalen == -1 } {
        log "error with sock $sock"
    }

    set pos $peer(datapos)

    set len_p [binary scan $peer(data) "@${pos}i" len]
    if { $len_p && $datalen >= 5 + $pos + $len } {

        # int length (4 bytes)
        set pos [incr peer(datapos) 4]

        # bytearray data ($len bytes)
        set line_p [binary scan $peer(data) "@${pos}a${len}" line]
        set pos [incr peer(datapos) $len]

        # char retcode (1 byte)
        set retcode_p [binary scan $peer(data) "@${pos}c" retcode]
        assert { $retcode_p }
        set peer(retcode) $retcode
        set pos [incr peer(datapos)]

        # log line=$line

        set ::done($sock) $line

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
    # SockDone $sock
    return $response

}


proc bgerror {msg} {
    global errorInfo
    puts stderr "bgerror: $msg\n$errorInfo"
}

