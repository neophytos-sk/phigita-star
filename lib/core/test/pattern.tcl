package require core

foreach str {
    12345
    abcdef
    123.45
    192.168.150.3
    somename@example.com
    http://www.phigita.net/
    Max Awesome
    12/29/2015
    02/07/2014
    phigita.net
    my.phigita.net
} {
    puts "typeof('${str}') = [::pattern::typeof $str]"
}



namespace eval ::pattern {
    variable fmt_to_pattern
    variable pattern_to_fmt

    array set fmt_to_pattern {
        %A alpha
        %T lc_alnum_dash_title_optional_ext
        %N naturalnum
        %U uuid
        %H sha1_hex
    }

    foreach {format_group pattern_name} [array get fmt_to_pattern] {
        set pattern_to_fmt($pattern_name) $format_group
    }
}

proc ::pattern::annotate_query_params {url} {
    array set urlarr [url split $url]
    if { $urlarr(query) eq {} } {
        return
    }
    puts ""
    puts "#annotate_query_params"
    set list [url parse_query $urlarr(query)]
    set types [map x $list {list $x [::pattern::typeof [lindex $x 1] {alpha naturalnum lc_alnum_dash_title_optional_ext sha1_hex uuid}]}]
    puts $types
    puts "=> [set types [map x $types {list [lindex [lindex $x 0] 0] [lindex $x 1]}]]"
    return $types
}


proc ::pattern::annotate_path_parts {url} {
    puts ""
    puts "#annotate_path_parts"
    array set urlarr [::uri::split $url]
    puts $urlarr(path)
    set values_and_types [map x [split $urlarr(path) {/}] {list $x [::pattern::typeof $x {alpha naturalnum lc_alnum_dash_title_optional_ext sha1_hex uuid}]}]
    puts $values_and_types
    set types [map x $values_and_types {lindex $x 1}]
    puts "=> $types"
    return $types
}

proc ::pattern::annotate_url {url} {
    variable pattern_to_fmt
    puts ""
    puts "#annotate_url"
    puts $url

    set path_fmt_list [list]
    foreach pattern_name_list [annotate_path_parts $url] {
        if { $pattern_name_list eq {} } {
            # TODO: temporary hack, needs to be fixed
            continue
        }
        set pattern_fmt_list [list]
        foreach pattern_name $pattern_name_list {
            lappend pattern_fmt_list $pattern_to_fmt($pattern_name)
        }
        lappend path_fmt_list [list $pattern_fmt_list]
    }
    set path_fmt [join $path_fmt_list "/"]

    set query_fmt_list [list]
    foreach item [annotate_query_params $url] {
        lassign $item param_name pattern_name_list
        if { $pattern_name_list eq {} } {
            # TODO: temporary hack, needs to be fixed
            continue
        }
        set pattern_fmt_list [list]
        foreach pattern_name $pattern_name_list {
            lappend pattern_fmt_list $pattern_to_fmt($pattern_name)
        }
        lappend query_fmt_list ${param_name}=[list $pattern_fmt_list]
    }
    set query_fmt [join $query_fmt_list "&"]

    set fmt $path_fmt
    if { $query_fmt ne {} } {
        append fmt "?" $query_fmt
    }
    return $fmt
}

proc ::pattern::match_format {format_group str} {
    variable fmt_to_pattern
    set pattern_name $fmt_to_pattern($format_group)
    return [::pattern::check=$pattern_name str]
}

proc ::pattern::match_url {fmt url} {
    array set fmt_a [url split $fmt]
    array set url_a [url split $url]

    array set fmt_query [join [url parse_query $fmt_a(query)]]
    array set url_query [join [url parse_query $url_a(query)]]

    set count_matched 0
    foreach name [array names url_query] {
        if { ![info exists fmt_query($name)] } {
            return false
        }
        set str $fmt_query($name)
        set firstChar [string index $str 0] 
        if { $firstChar in "% \\\{" } {
            foreach format_group [join $str] {
                if { $format_group ne {} && ![::pattern::match_format $format_group $url_query($name)] } {
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

set url1 "http://www.japantimes.co.jp/news/2015/07/18/national/tokyo-opens-citys-first-swimming-beach-since-1960s/"
set fmt1 [pattern::annotate_url $url1]
puts "match_url($fmt1,$url1) => [::pattern::match_url $fmt1 $url1]"

set url2 "http://www.hurriyetdailynews.com/shifts-to-shuffles.aspx?pageID=238&nID=85330&NewsCatID=473"
set fmt2 [pattern::annotate_url $url2]
#set fmt2 "%T?pageID=%N&nID=%N&NewsCatID=%N"
puts "match_url($fmt2,$url2) => [::pattern::match_url $fmt2 $url2]"
puts "match_url($fmt2,$url1) => [::pattern::match_url $fmt2 $url1]"
puts "match_url($fmt1,$url2) => [::pattern::match_url $fmt1 $url2]"

set url3 "http://www.kepa.gov.cy/em/BusinessDirectory/Company/CompanyProduct.aspx?CompanyId=2b674aab-7c3e-4e12-ab09-6d852b507a56&ProductId=cffcf1e6-efcc-41df-8e6d-46efbeabf097"
set fmt3 [pattern::annotate_url $url3]
puts "match_url($fmt3,$url3) => [::pattern::match_url $fmt3 $url3]"
