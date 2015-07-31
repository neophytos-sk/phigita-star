package require uri

namespace eval ::url {

    namespace ensemble create -subcommands {
        normalize resolve join split
        parse_query
        fmt_ex match
        encode decode
    }

    # url encode/decode mapping initialization
    variable ue_map
    variable ud_map

    lappend d + { }
    for {set i 0} {$i < 256} {incr i} {
        set c [format %c $i]
        set x %[format %02x $i]
        if {![string match {[a-zA-Z0-9]} $c]} {
            lappend e $c $x
            lappend d $x $c
        }
    }
    set ue_map $e
    set ud_map $d

}

proc ::url::normalize {url} {

    if { [string range ${url} 0 1] ne {//} } {
        set i [string first {:} ${url}] 
        set j [string first {.} ${url}]
        if { ( ${i} == -1 ) && ( ${i} < ${j} )} {
            # if no colon character found before the first dot
            set url "http://${url}"
        }
    }
    return [::uri::join {*}[::uri::split ${url}]]
}
proc ::url::resolve {base url} {
    return [::uri::resolve $base $url]
}
proc ::url::join {url} {
    return [::uri::join $url]
}
proc ::url::split {url} {
    return [::uri::split $url]
}

proc ::url::parse_query {str} {
    set result [list]
    foreach param [::split $str {&}] {
        lassign [::split $param {=}] param_name param_value
        lappend result $param_name $param_value
    }
    return $result
}

proc ::url::query_fmt_ex {url} {
    array set urlarr [url split $url]
    if { $urlarr(query) eq {} } {
        return
    }
    #puts ""
    #puts "#annotate_query_params"
    set list [url parse_query $urlarr(query)]
    set types [map {x y} $list {list [list $x $y] [::pattern::typeof $y {alpha naturalnum lc_alnum_dash_title_optional_ext sha1_hex uuid alnum_plus_ext}]}]
    #puts $types
    set types [map x $types {list [lindex [lindex $x 0] 0] [lindex $x 1]}]
    return $types
}


proc ::url::path_fmt_ex {url} {
    #puts ""
    #puts "#annotate_path_parts"
    array set urlarr [::uri::split $url]
    #puts $urlarr(path)
    set values_and_types [map x [::split $urlarr(path) {/}] {list $x [::pattern::typeof $x {alpha naturalnum lc_alnum_dash_title_optional_ext sha1_hex uuid alnum_plus_ext}]}]
    #puts $values_and_types
    set types [map x $values_and_types {lindex $x 1}]
    #puts "=> $types"
    return $types
}

proc ::url::fmt_ex {url} {

    #puts ""
    #puts "#annotate_url"
    #puts $url

    set path_fmt_list [list]
    foreach pattern_name_list [path_fmt_ex $url] {
        if { $pattern_name_list eq {} } {
            # TODO: temporary hack, needs to be fixed
            continue
        }
        set pattern_fmt_list [list]
        foreach pattern_name $pattern_name_list {
            lappend pattern_fmt_list [pattern to_fmt $pattern_name]
        }
        lappend path_fmt_list [list $pattern_fmt_list]
    }
    set path_fmt [::join $path_fmt_list "/"]

    set query_fmt_list [list]
    foreach item [query_fmt_ex $url] {
        lassign $item param_name pattern_name_list
        if { $pattern_name_list eq {} } {
            # TODO: temporary hack, needs to be fixed
            continue
        }
        set pattern_fmt_list [list]
        foreach pattern_name $pattern_name_list {
            lappend pattern_fmt_list [pattern to_fmt $pattern_name]
        }
        lappend query_fmt_list ${param_name}=[list $pattern_fmt_list]
    }
    set query_fmt [::join $query_fmt_list "&"]

    set fmt $path_fmt
    if { $query_fmt ne {} } {
        append fmt "?" $query_fmt
    }
    return $fmt
}



#proc ::url::annotate_query {str} {
#    set list [parse_query $str]
#    return [map x $list {::pattern::typeof [lindex $x 1]}]
#}

proc ::url::match {pattern url} {
    array set fmt_a [url split $pattern]
    array set url_a [url split $url]

    array set fmt_query [url parse_query $fmt_a(query)]
    array set url_query [url parse_query $url_a(query)]

    set count_matched 0
    foreach name [array names url_query] {
        if { ![info exists fmt_query($name)] } {
            return false
        }
        set str $fmt_query($name)
        set firstChar [string index $str 0] 
        if { $firstChar in "% \\\{" } {
            foreach format_group [::join $str] {
                if { $format_group eq {} } {
                    continue
                }
                set match_p [pattern match [pattern from_fmt $format_group] url_query($name)]
                if { !$match_p } {
                    return false
                }
            }
        } elseif { $str ne $url_query($name) } {
            return false
        }
        incr count_matched
    }

    if { $count_matched != [array size fmt_query] } {
        return false
    }

    # match path with fmt
    foreach str1 [::split $fmt_a(path) {/}] str2 [::split $url_a(path) {/}] {
        if { [string index $str1 0] eq {%} } {
            set match_p [pattern match [pattern from_fmt $str1] str2]
            if { !$match_p } {
                return false
            }
        } elseif { $str1 ne $str2 } {
            return false
        }
    }

    return true
}


proc ::url::urldecode2 {str} {
    # rewrite "+" back to space
    # protect \ from quoting another '\'
    set str [string map [list + { } "\\" "\\\\"] $str]

    # prepare to process all %-escapes
    regsub -all -- {%([A-Fa-f0-9][A-Fa-f0-9])} $str {\\u00\1} str

    # process \u unicode mapped chars
    return [subst -novar -nocommand $str]
}


proc ::url::decode {s} {
    variable ud_map
    return [string map ${ud_map} ${s}]
}


proc ::url::encode {s} {
    variable ue_map
    set s [encoding convertto utf-8 ${s}]
    return [string map ${ue_map} ${s}]
}


