### see java.io.*

namespace eval ::xo::io {;}

Class ::xo::io::File -parameter {
    pathSeparator
    pathSeparatorChar
    separator
    separatorChar
    {byteOrder "$::tcl_platform(byteOrder)"}
    {filename ""}
    {encoding "binary"}
    {buffering "full"}
    {buffersize "[expr {1024*1024}]"}
    {translation "binary"}
    {access "RDONLY"}
    {channelId ""}
}

::xo::io::File instproc init {args} {
    my instvar channelId buffering translation encoding filename access
    set channelId [open ${filename} ${access}]
    fconfigure $channelId -encoding $encoding -buffering $buffering -translation $translation
    next
}


::xo::io::File instproc readLong {} { 
    my instvar channelId
    binary scan [read $channelId 8] w v
    return $v
}

::xo::io::File instproc writeLong {v} {
    my instvar channelId
    puts -nonewline $channelId [binary format w $v]
}
::xo::io::File instproc writeInt {v} {
    my instvar channelId
    puts -nonewline $channelId [binary format i $v]
}
::xo::io::File instproc writeShort {v} {
    my instvar channelId
    puts -nonewline $channelId [binary format s $v]
}
::xo::io::File instproc write {text} {
    my instvar channelId
    puts -nonewline $channelId $text
}

::xo::io::File instproc sync {} {
    my instvar channelId
    flush $channelId
}

::xo::io::File instproc destroy {args} {
    my instvar channelId
    close $channelId
    next
}