package require uri

namespace eval ::url {

    namespace ensemble create -subcommands {
        normalize resolve join split
        parse_query
        fmt_ex match
    }

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
    puts ""
    puts "#annotate_query_params"
    set list [url parse_query $urlarr(query)]
    set types [map {x y} $list {list [list $x $y] [::pattern::typeof $y {alpha naturalnum lc_alnum_dash_title_optional_ext sha1_hex uuid alnum_plus_ext}]}]
    puts $types
    puts "=> [set types [map x $types {list [lindex [lindex $x 0] 0] [lindex $x 1]}]]"
    return $types
}


proc ::url::path_fmt_ex {url} {
    puts ""
    puts "#annotate_path_parts"
    array set urlarr [::uri::split $url]
    puts $urlarr(path)
    set values_and_types [map x [::split $urlarr(path) {/}] {list $x [::pattern::typeof $x {alpha naturalnum lc_alnum_dash_title_optional_ext sha1_hex uuid alnum_plus_ext}]}]
    puts $values_and_types
    set types [map x $values_and_types {lindex $x 1}]
    puts "=> $types"
    return $types
}

proc ::url::fmt_ex {url} {

    puts ""
    puts "#annotate_url"
    puts $url

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
                set match_p [pattern match [pattern from_fmt $format_group] $url_query($name)]
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

    return true
}

