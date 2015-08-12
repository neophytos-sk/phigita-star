package require uri

namespace eval ::url {

    namespace ensemble create -subcommands {
        normalize resolve join split
        parse_query
        fmt_ex fmt_sp match
        encode decode
        intersect
        scheme host port path query fragment
        domain
    }

    namespace export \
        domain_from_host

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
proc ::url::join {url_keyl} {
    return [::uri::join {*}$url_keyl]
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
    set types [map {x y} $list {
        set __to_check_pattern_names {
            alpha naturalnum lc_alnum_dash_title_optional_ext 
            sha1_hex uuid alnum_plus_ext
        }
        set __types [::pattern::typeof $y $__to_check_pattern_names]
        list [list $x $y] $__types
    }]
    #puts $types
    set types [map x $types {list [lindex [lindex $x 0] 0] [lindex $x 1]}]
    return [lsort -index 0 $types]
}


proc ::url::path_fmt_ex {url} {
    #puts ""
    #puts "#annotate_path_parts"
    array set urlarr [::uri::split $url]
    #puts $urlarr(path)
    set values_and_types [map x [::split $urlarr(path) {/}] {
        set __to_check_pattern_names {
            alpha naturalnum lc_alnum_dash_title_optional_ext 
            sha1_hex uuid alnum_plus_ext
        }
        list $x [::pattern::typeof $x $__to_check_pattern_names]
    }]
    #puts $values_and_types
    set types [map x $values_and_types {lindex $x 1}]
    #puts "=> $types"
    return $types
}



#proc ::url::annotate_query {str} {
#    set list [parse_query $str]
#    return [map x $list {::pattern::typeof [lindex $x 1]}]
#}

proc ::url::match {pattern url {valuesVar ""}} {
    array set fmt_a [url split $pattern]
    array set url_a [url split $url]

    array set fmt_query [url parse_query $fmt_a(query)]
    array set url_query [url parse_query $url_a(query)]

    # match query with fmt
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

proc ::url::intersect {url1 url2} {
    array set url1_a [url split $url1]
    array set url2_a [url split $url2]

    array set url1_query_a [url parse_query $url1_a(query)]
    array set url2_query_a [url parse_query $url2_a(query)]

    set intersection_url_keyl [list]

    # scheme,host,port intersection
    foreach name {scheme host port fragment user pwd} {
        if { $url1_a($name) eq $url2_a($name) } {
            lappend intersection_url_keyl $name $url1_a($name)
        } else {
            lappend intersection_url_keyl $name {}
        }
    }

    # path intersection
    set path_args [list]
    foreach str1 [::split $url1_a(path) {/}] str2 [::split $url2_a(path) {/}] {
        if { $str1 eq $str2 } {
            lappend path_args $str1
        } else {
            lappend path_args {}
        }
    }
    lappend intersection_url_keyl path [::join $path_args {/}]

    # query intersection
    set sorted_param_names [lsort [array names url1_query_a]]
    set query_args [list]
    foreach name $sorted_param_names {
        if { $url1_query_a($name) eq [value_if url2_query_a($name) ""] } {
            lappend query_args "${name}=$url1_query_a($name)"
        } else {
            lappend query_args "${name}="
        }
    }
    lappend intersection_url_keyl query [::join $query_args {&}]

    return [url join $intersection_url_keyl]

}


# TODO: sort query parameter names
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

    array set url_a [url split $url]
    set url_keyl [list]
    foreach name {scheme host port user pwd fragment} {
        lappend url_keyl $name $url_a($name)
    }

    lappend url_keyl path $path_fmt
    lappend url_keyl query $query_fmt

    return [url join $url_keyl]
}


# format specialize wrt to a given intersection_url,
# which is the output of ::url::intersect

proc ::url::fmt_sp {fmt intersection_url} {
    array set fmt_a [url split $fmt]
    array set url_a [url split $intersection_url]

    set fmt_query_keyl [url parse_query $fmt_a(query)]
    set url_query_keyl [url parse_query $url_a(query)]

    set fmt_keyl [list]
    foreach name {scheme host port user pwd fragment} {
        lappend fmt_keyl $name $fmt_a($name)
    }

    set path_args [list]
    foreach str1 [::split $fmt_a(path) {/}] str2 [::split $url_a(path) {/}] {
        lappend path_args [coalesce $str2 $str1]
    }
    lappend fmt_keyl path [::join $path_args {/}]

    set query_args [list]
    foreach {k1 v1} $fmt_query_keyl {k2 v2} $url_query_keyl {
        lappend query_args "[coalesce $k2 $k1]=[coalesce $v2 $v1]"
    }
    lappend fmt_keyl query [::join $query_args {&}]

    return [url join $fmt_keyl]

}

proc ::url::scheme {url} {
    array set url_a [url split $url]
    return $url_a(scheme)
}

proc ::url::host {url} {
    array set url_a [url split $url]
    return $url_a(host)
}

proc ::url::port {url} {
    array set url_a [url split $url]
    return $url_a(port)
}

proc ::url::path {url} {
    array set url_a [url split $url]
    return $url_a(path)
}

proc ::url::query {url} {
    array set url_a [url split $url]
    return $url_a(query)
}

proc ::url::fragment {url} {
    array set url_a [url split $url]
    return $url_a(fragment)
}


proc ::url::domain_from_host {host} {

    assert { ${host} ne {} }

    set re {([^\.]+\.)(com\.cy|ac.cy|gov.cy|org.cy|gr|com|net|org|info|coop|int|co\.uk|org\.uk|ac\.uk|uk|co|eu|co.jp|__and so on__)$}

    if { [regexp -- ${re} ${host} whole domain tld] } {
        return ${domain}${tld}
    }

    #puts "could not match regexp to host=${host}"

    return ${host}
}

proc ::url::domain {url} {

    if { ${url} eq {} } {
        return
    }

    set index [string first {:} ${url}]
    if { ${index} == -1 } {
        return
    }

    set scheme [string range ${url} 0 ${index}]
    if { ${scheme} ne {http:} && ${scheme} ne {https:} } {
        return
    }

    set host [url host ${url}]

    # note that host can be empty, e.g. if url was "http:///"    

    return [domain_from_host ${host}]
}


namespace eval :: {
    namespace import ::url::domain_from_host
}
