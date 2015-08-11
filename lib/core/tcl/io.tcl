# TODO: little endian / big endian

namespace eval ::util::io {;}

proc ::util::io::write_char {channelId v} {
    fconfigure $channelId -translation binary
    puts -nonewline $channelId [binary format c $v]
}
proc ::util::io::write_long {channelId v} {
    fconfigure $channelId -translation binary
    #ns_log notice "write_long channelId=$channelId v=$v"
    puts -nonewline $channelId [binary format w $v]
}
proc ::util::io::write_int {channelId v} {
    fconfigure $channelId -translation binary
    puts -nonewline $channelId [binary format i $v]
}
proc ::util::io::write_short {channelId v} {
    fconfigure $channelId -translation binary
    puts -nonewline $channelId [binary format s $v]
}

proc ::util::io::write_text {channelId line} {
    puts -nonewline $channelId $line
}

# varying length text
proc ::util::io::write_vartext {channelId line {encoding ""}} {
    set len [string length $line]
    ###ns_log notice "writeVawrite_vartext $len line"
    if { $encoding ne {} } {
        fconfigure $channelId -encoding binary
    }
    ::util::io::write_int $channelId $len
    if { $encoding ne {} } {
        fconfigure $channelId -encoding $encoding
    }
    ::util::io::write_text $channelId $line
    return ${len}
}

proc ::util::io::write_string {channelId line} {
    set len [string length $line]
    #set len [string length $line]
    ::util::io::write_int $channelId $len
    puts -nonewline $channelId $line
    return ${len}
}


proc ::util::io::read_long {channelId} {
    fconfigure $channelId -translation binary
    binary scan [read $channelId 8] w v
    #ns_log notice "read_long v=$v"
    return $v
}

proc ::util::io::read_char {channelId} {
    fconfigure $channelId -translation binary
    binary scan [read $channelId 1] c v
    return $v
}

proc ::util::io::read_int {channelId} {
    fconfigure $channelId -translation binary
    binary scan [read $channelId 4] i v
    #ns_log notice "read_int v=$v"
    return $v
}

proc ::util::io::read_text {channelId len {lineVar ""}} {
    if { $lineVar ne {} } {
	upvar $lineVar line
    }
    set line [read $channelId $len]
    #ns_log notice "read_text len=$len"
}

proc ::util::io::read_vartext {channelId {lineVar ""} {encoding ""}} {
    if { $lineVar ne {} } {
        upvar $lineVar line
    }
    if { $encoding ne {} } {
        fconfigure $channelId -encoding binary
    }
    set len [::util::io::read_int $channelId]
    #ns_log notice "chan pending = [chan pending input $channelId]"
    if { $encoding ne {} } {
        fconfigure $channelId -encoding $encoding
    }
    #ns_log notice "read_vartext $len line"
    ::util::io::read_text $channelId $len line
}

proc ::util::io::read_java_utf {channelId {lineVar ""}} {
    if { $lineVar ne {} } {
        upvar $lineVar line
    }
    set len [read $channelId 2]
    binary scan $len S length
    set data [read $channelId [expr {$length & 0xffff}]]
    return [encoding convertfrom utf-8 $data]
}

proc ::util::io::read_string {channelId {lineVar ""} {encoding ""}} {
    if { $lineVar ne {} } {
        upvar $lineVar line
    }
    set len [::util::io::read_int $channelId]
    if { $encoding ne {} } {
        fconfigure $channelId -encoding $encoding
    }
    set line [read $channelId $len]
}

proc ::util::io::skip_string {channelId} {
    set len [::util::io::read_int $channelId]
    seek ${channelId} ${len} current
}

proc ::util::io::skip_int {channelId} {
    seek ${channelId} 4 current
}

proc ::util::io::rskip_int {channelId} {
    seek ${channelId} -4 current
}

proc ::util::io::skip_long {channelId} {
    seek ${channelId} 8 current
}

proc ::util::io::rskip_long {channelId} {
    seek ${channelId} -8 current
}

proc ::util::io::skip_vartext {channelId encoding} {
    fconfigure $channelId -encoding binary
    set len [::util::io::read_int $channelId]
    fconfigure $channelId -encoding $encoding
    seek ${channelId} ${len} current
}


proc ::util::io::write_utf8 {fp str} {
    set len [string bytelength ${str}]
    puts -nonewline $fp [binary format i $len]
    puts -nonewline $fp [encoding convertto utf-8 $str]
}

proc ::util::io::read_utf8 {fp} {
    binary scan [read $fp 4] i len
    set str [read ${fp} ${len}]
    return [encoding convertfrom utf-8 $str]
}
