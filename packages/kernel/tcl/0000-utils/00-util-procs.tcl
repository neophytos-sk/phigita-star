package require uri

namespace eval ::util {;}

proc ::util::ns_dbquotevalue {value {type text}} {
    if {$value eq ""} {
        return "NULL"
    }
    if {$type eq "decimal" \
            || $type eq "double" \
            || $type eq "integer" \
            || $type eq "int" \
            || $type eq "real" \
            || $type eq "smallint" \
            || $type eq "bigint" \
            || $type eq "bit" \
            || $type eq "float" \
            || $type eq "numeric" \
            || $type eq "tinyint"} {
        return $value
    }
    regsub -all "'" $value "''" value
    return "'$value'"
}

proc ::util::sqllist {list} {
    if { $list eq {} } {
	return NULL
    }
    return ([join [::xo::fun::map x $list {::util::ns_dbquotevalue $x}] ,])
}

proc ::util::html2text {html} {
    set result ""
    if { [catch {
	set docId [dom parse -html <ROOT>$html</ROOT>]
	set result [$docId asText]
	$docId delete
    } errmsg] } {
	ns_log notice "::util::html2text errmsg=$errmsg"
	set result [::util::striphtml $html]
    }
    return $result
}


# load if not already loaded
proc ::util::loadIf {filename} {
    if { -1 == [lsearch -exact [info loaded] ${filename}] } {
        if {[catch {load $filename}]} {
	    ns_log notice "Failed to load $filename"
	}
    }
}

# threshold is 8 for hexadecimal and 5 for decimal
proc ::util::getStaticHost {hash prefix suffix {threshold "8"}} {
    set firstChar [string index $hash 0]
    set bit [expr { ${firstChar} < ${threshold} }]
    set protocol [ad_conn protocol]
    set issecure [ad_conn issecure]
    return ${protocol}://${prefix}${issecure}${bit}${suffix}.phigita.net
}

# ::util::lsortMultiIndex  {{a b c e r} {d c c a p}} {2 {1 -decreasing}}
proc ::util::lsortMultiIndex {lol indexes} {
    if { $lol eq {} } {
	return {}
    }
    foreach indexAndSwitches [lreverse ${indexes}] {
	set lol [lsort -index {*}${indexAndSwitches} ${lol}]
    }
    return ${lol}
}

proc ::util::mtime {filename} {
    return [file mtime $filename]
}

proc ::util::coalesce {args} {
    return [lsearch -inline -not ${args} {}]
}

# Returns value or default value if value is empty, similar to
# Oracle's NVL nad PostgreSQL COALESCE functions.
proc ::util::nvl { value { default "" } } {

    if { $value != "" } { return $value }
    return $default
}


# Takes the place of an if (or switch) statement -- convenient because it's
# compact and you don't have to break out of an ns_write if you're in one.
# args: same order as in sql: first the unknown value, then any number of
# pairs denoting "if the unknown value is equal to first element of pair,
# then return second element", then if the unknown value is not equal to any
# of the first elements, return the last arg if exists,
# or return the value itself
# Ex:  [::util::decode $value 1 "one" 2 "two" "infinite"]
#      [::util::decode $value one 1 two 2 three 3]
proc ::util::decode { value args } {

    set length [llength $args]
    for { set i 0 } { $i < $length } {} {
	if { $value == [lindex $args $i] } {
	    return [lindex $args [expr $i + 1]]
	}
	set i [expr $i + 2]
    }
    if { [expr $length % 2] } {
	set value [lindex $args end]
    }
    return $value
}



proc ::util::doublequote {text} {
    return \"[string map {\" {\"}} ${text}]\"
}


proc ::util::striphtml {html} {
    return [ns_striphtml ${html}]
    ###
    regsub -all -- {<[^>]*>} ${html} "" html
    return ${html}
}


proc ::util::sysdate {} {
    return [clock format [ns_time] -format "%Y-%m-%d %H:%M:%S %Z"]
}

proc ::util::pad { string size {ch 0}} {

    if { ![string is integer -strict $string] } { return $string }
    set val [string repeat ${ch} [expr $size - [string length $string]]]
    append val $string
    return $val
}

proc lreverse list {
    if [set i [llength $list]] {
        while {[incr i -1]>=0} {lappend res [lindex $list $i]}
        set res
    }
}

proc ::util::encodeURIComponent {string} { string map {+ { }} [ns_urlencode $string] }


proc ::util::quotehtml {text} {
    return [ad_quotehtml $text]
}

proc ::util::dequotehtml {text} {
    return [string map {{&lt;} {<} {&gt;} {>} {&amp;} {&}} $text]
}



proc ::util::getImageList {text} {
    set str [::util::dequotehtml $text]
    set regexp {\<img\s+[^\>]*src\s*=\s*\"?(http://[^\s\>\"]+)\s*\"?[^\>]*\>}
    set start -1
    set result ""
    while {[regexp -start $start -indices -- $regexp $str match submatch]} {
	lassign $submatch subStart subEnd
	lassign $match matchStart matchEnd
        incr matchStart -1
        incr matchEnd
        if {$subStart >= $start} {
	    lappend result [string trim [string range $str $subStart $subEnd]]
        }
        set start $matchEnd
    }
    return $result
}

proc ::util::getAnchorList {text} {
    set str [::util::dequotehtml $text]
    set regexp {\<a\s+[^\>]*href\s*=\s*\"?(http://[^\s\>\"]+)\s*\"?[^\>]*\>}
    set start -1
    set result ""
    while {[regexp -start $start -indices -- $regexp $str match submatch]} {
	lassign $submatch subStart subEnd
	lassign $match matchStart matchEnd
        incr matchStart -1
        incr matchEnd
        if {$subStart >= $start} {
	    lappend result [string trim [string range $str $subStart $subEnd]]
        }
        set start $matchEnd
    }
    return $result
}


proc ::util::getObjectList {text} {
    set str [::util::dequotehtml $text]
    set result ""
    foreach regexp {
	{\<embed\s+[^\>]*src\s*=\s*\"?(http://[^\s\>\"]+)\s*\"?[^\>]*\>}
	{\<object\s+[^\>]*data\s*=\s*\"?(http://[^\s\>\"]+)\s*\"?[^\>]*\>}
    } {
	set start -1
	while {[regexp -start $start -indices -- $regexp $str match submatch]} {
	    lassign $submatch subStart subEnd
	    lassign $match matchStart matchEnd
	    incr matchStart -1
	    incr matchEnd
	    if {$subStart >= $start} {
		set url [string trim [string range $str $subStart $subEnd]]
		if { [lsearch -exact $result $url] == -1 } {
		    lappend result $url
		}
	    }
	    set start $matchEnd
	}
    }
    return $result
}


proc ::util::wgetFile { suffix url } {

    set result ""

    if { $url ne {} } {
	set url [string map {{;} {%3b}} [string map {{&amp;} {&} {&#038;} {&} \$ {%24} \[ {%5b} \] {%5d}} [::uri::canonicalize $url]]]
	set path "[web_root_dir]/data/${suffix}"
	set sha1 [ns_sha1 $url]

	    append path /[string range $sha1 0 1]
	    if { ![file exists $path] } {
		file mkdir $path
	    }

	    if { [file exists ${path}/${sha1}] && [file size ${path}/${sha1}] > 0 } {
	    set result $sha1
	    if { ![file exists ${path}/${sha1}-sample-80x80.jpg] } {
		ns_log notice "original file (${path}/${sha1}) exists but no thumbnail... trying to convert image again"
		if {[catch "exec -- /bin/sh -c \"convert -sample 80x80 ${path}/${sha1} ${path}/${sha1}-sample-80x80.jpg || exit 0\" 2> /dev/null"]} {
		    set result ""
		    ns_log notice "Error converting image $sha1 for existing file"
		}
	    }
	} else {
	    #exec -- /bin/sh -c \"wget -q -O ${path}/${sha1} $url || exit 0\" 2> /dev/null
	    ns_log notice "wgetFile: url=$url file=${path}/${sha1}"
	    #-ignorecontentlength 1
	    if { ![catch "curl::transfer -url $url -file ${path}/${sha1}" errmsg]} {
		ns_log notice "file ${path}/${sha1} size=[file size ${path}/${sha1}]"
		set result $sha1
		if {[catch "exec -- /bin/sh -c \"convert -filter Lanczos -unsharp 0x0.6+1.0 -resize 80x80 ${path}/${sha1} ${path}/${sha1}-sample-80x80.jpg || exit 0\" 2> /dev/null"]} {
		    set result ""
		    ns_log notice "Error converting image $sha1"
		}
		if {[catch "exec -- /bin/sh -c \"jpegoptim -q --strip-all ${path}/${sha1}-sample-80x80.jpg || exit 0\" 2> /dev/null"]} {
		    set result ""
		    ns_log notice "Error optimizing (jpegoptim) image ${sha1}-sample-80x80.jpg"
		}
	    } else {
		set result ""
		ns_log notice "wgetFile error fetching: $url errmsg=$errmsg"
	    }
	}
    }

    return $result
}


proc ::util::dbquotevalue_old {text} {
    set result [ns_dbquotevalue [string map {\\ \\\\} $text]]
    if { $result eq {NULL} } {
	return NULL
    } else {
	return E${result}
    }

    #    return '[string map {{'} {\'}} $text]'
}

proc ::util::dbquotevalue {text} {
    if { $text eq {} } {
	return NULL
    } else {
	return E'[string map {' '' \\ \\\\} $text]'
    }
}

proc ::util::jsquotevalue {text} {

    set result '[string map {{'} {\'} \n \\n \r \\r} [string map {\\ \\\\} $text]]'
    return ${result}
}

proc ::util::filter {fn list} {
    set result [list]
    foreach item $list {
	if { [$fn $item] } {
	    lappend result $item
	}
    }
    return $result
}

proc ::util::lremove {item list} {
    set result [list]
    foreach member $list {
	if { $member ne $item } {
	    lappend result $member
	}
    }
    return $result
}

proc ::util::ldiff {list1 list2} {
    set result $list1
    foreach item $list2 {
	set result [::util::lremove $item $result]
    }
    return $result
}


proc ::util::__ObjectSlotCompare { slot_name o1 o2 } {
    return [string compare [$o1 set $slot_name] [$o2 set $slot_name]]
}



proc ::util::duration_to_secs {duration} {
    set parts [split $duration :]
    #foreach {hours minutes secs} $parts break
    set hours 0
    set minutes 0
    set secs 0
    lassign [lreverse $parts] secs minutes hours
    return [expr { $hours * 3600 + $minutes * 60 + $secs }]
}

proc ::util::timefmt {secs {fmt "%H:%M:%S"}} {

    if { ![string is integer -strict $secs] } {
        error "first argument must be integer"
    }

    set d [expr {$secs/86400}] ; set D [string range "0$d" end-1 end]
    set h [expr {($secs%86400)/3600}] ; set H [string range "0$h" end-1 end]
    set m [expr {(($secs%86400)%3600)/60}] ; set M [string range "0$m" end-1 end]
    set s [expr {(($secs%86400)%3600)%60}] ; set S [string range "0$s" end-1 end]

   set p "%% % %s $s %S $S %m $m %M $M %h $h %H $H %d $d %D $D"
    set str [string map $p $fmt]
    return $str;

};# timefmt



proc VideoDuration {secs} {
    set timelist ""
    foreach div { 86400 3600 60 1 } mod { 0 24 60 60 } name { day hr min sec } {
	set secs [ string trimleft $secs 0 ]
	if { ${secs} eq {} } break
	regsub -all {,} $secs {} secs
	set n [ expr {round($secs) / $div} ]
	if { $mod > 0 } { set n [ expr {$n % $mod} ] }
	if { $n > 1 } {
	    lappend timelist "$n ${name}s"
	} elseif { $n == 1 } {
	    lappend timelist "$n $name"
	}
    }
    return [join $timelist " "]
}




proc hstore2dict {hstore} {
    return [join [split [string map {"=>" " "} $hstore] ","] " "]

    set result ""
    foreach item [split [string map {"=>" " "} $hstore] ","] {
	foreach {key value} $item break
	lappend result "[string tolower [string map {. _} $key]] ${value}"
    }
    return [join $result " "]
}



proc filter_metadata {hstore filetype} {
    
    Object itemToUser \
	-set md(document) [list XO.Info.pages XO.Info.title XO.Info.author XO.Info.creationdate XO.Info.page_size XO.Info.encrypted XO.Info.subject XO.Info.keywords XO.Info.creator] \
	-set md(spreadsheet) [list XO.Info.pages XO.Info.title XO.Info.author XO.Info.creationdate XO.Info.page_size XO.Info.encrypted XO.Info.subject XO.Info.keywords XO.Info.creator] \
	-set md(presentation) [list XO.Info.pages XO.Info.title XO.Info.author XO.Info.creationdate XO.Info.page_size XO.Info.encrypted XO.Info.subject XO.Info.keywords XO.Info.creator] \
	-set md(image) [list \
			    Exif.Image.Make \
			    Exif.Image.Model \
			    Exif.Photo.ApertureValue \
			    Exif.Photo.ShutterSpeedValue \
			    Exif.Photo.ExposureTime\
			    Exif.Photo.ExposureProgram \
			    Exif.Photo.FocalLength \
			Exit.Photo.MeteringMode \
			    Exif.Photo.WhiteBalance \
			    Exif.Photo.DateTimeOriginal] \
	-set md(audio) [list XO.Info.duration MP3.Info.Title MP3.Info.Track MP3.Info.Artist MP3.Info.Genre MP3.Info.Album MP3.Info.Year] \
	-set md(video) [list XO.Info.duration] \
	-set md(database) [list] \
	-set md(other) [list]


    set allowed_attributes [itemToUser set md(${filetype})]

    set fileinfo [dict create]
    foreach item [split $hstore ","] {
	set index [string first => $item]
	set key [string range $item 0 [expr {-1+$index}]]
	set value [string range $item [expr {2+$index}] end]
	set dict [dict set fileinfo [string trim $key { "}] [string trim $value { "}]]
    }

    set result ""
    foreach key $allowed_attributes {
	if { [dict exists $fileinfo $key] } {
	    lappend result "[::util::doublequote [lindex [split $key .] end]]=>[::util::doublequote [dict get $fileinfo $key]]"
	}
    }
    return [join $result {,}]
}

proc ::util::domain_from_host {host} {
    set host_parts [split $host {.}]
    set country_code [lindex $host_parts end]
    if { ${country_code} eq {uk} || ${country_code} eq {cy} || ${country_code} eq {au} } {
	set domain [lindex $host_parts end-2]
    } else {
	set domain [lindex $host_parts end-1]
    }
    return $domain
}


proc ::util::minitext_to_html {text} {
    regsub -nocase -all {(^|[^a-zA-Z0-9]+)(https?://[^\(\)"<>\s,\*\':;?\[\]]+[^\(\)\"<>\s\.,\*\':;?\[\]])} $text "\\1<a href=\"\\2\">\\2</a>" text
    return $text
}
