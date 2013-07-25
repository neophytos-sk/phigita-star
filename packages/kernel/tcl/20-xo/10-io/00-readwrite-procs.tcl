# TODO: little endian / big endian

namespace eval ::xo::io {;}

proc ::xo::io::writeLong {channelId v} {
    fconfigure $channelId -translation binary
    #ns_log notice "writeLong channelId=$channelId v=$v"
    puts -nonewline $channelId [binary format w $v]
}
proc ::xo::io::writeInt {channelId v} {
    fconfigure $channelId -translation binary
    puts -nonewline $channelId [binary format i $v]
}
proc ::xo::io::writeShort {channelId v} {
    fconfigure $channelId -translation binary
    puts -nonewline $channelId [binary format s $v]
}

proc ::xo::io::writeText {channelId line} {
    puts -nonewline $channelId $line
}

# varying length text
proc ::xo::io::writeVarText {channelId line {encoding ""}} {
    set len [string length $line]
    ###ns_log notice "writeVarText $len line"
    if { $encoding ne {} } {
	fconfigure $channelId -encoding binary
    }
    ::xo::io::writeInt $channelId $len
    if { $encoding ne {} } {
	fconfigure $channelId -encoding $encoding
    }
    ::xo::io::writeText $channelId $line
}

proc ::xo::io::writeString {channelId line} {
    set len [string bytelength $line]
    ::xo::io::writeInt $channelId $len
    puts -nonewline $channelId $line
}


proc ::xo::io::readLong {channelId} {
    fconfigure $channelId -translation binary
    binary scan [read $channelId 8] w v
    #ns_log notice "readLong v=$v"
    return $v
}

proc ::xo::io::readInt {channelId} {
    fconfigure $channelId -translation binary
    binary scan [read $channelId 4] i v
    #ns_log notice "readInt v=$v"
    return $v
}

proc ::xo::io::readText {channelId len {lineVar ""}} {
    if { $lineVar ne {} } {
	upvar $lineVar line
    }
    set line [read $channelId $len]
    #ns_log notice "readText len=$len"
}

proc ::xo::io::readVarText {channelId {lineVar ""} {encoding ""}} {
    if { $lineVar ne {} } {
	upvar $lineVar line
    }
    if { $encoding ne {} } {
	fconfigure $channelId -encoding binary
    }
    set len [::xo::io::readInt $channelId]
    #ns_log notice "chan pending = [chan pending input $channelId]"
    if { $encoding ne {} } {
	fconfigure $channelId -encoding $encoding
    }
    #ns_log notice "readVarText $len line"
    ::xo::io::readText $channelId $len line
}
proc ::xo::io::readJavaUTF {channelId {lineVar ""}} {
    if { $lineVar ne {} } {
	upvar $lineVar line
    }
    set len [read $channelId 2]
    binary scan $len S length
    set data [read $channelId [expr {$length & 0xffff}]]
    return [encoding convertfrom utf-8 $data]
}

proc ::xo::io::readString {channelId {lineVar ""} {encoding ""}} {
    if { $lineVar ne {} } {
	upvar $lineVar line
    }
    set len [::xo::io::readInt $channelId]
    if { $encoding ne {} } {
	fconfigure $channelId -encoding $encoding
    }
    set line [read $channelId $len]
}
