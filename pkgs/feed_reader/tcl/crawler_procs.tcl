proc ::util::pretty_interval {secs} {

    set result [list]

    foreach {interval suffix} {
        86400 d
        3600  h
        60    m
        1     s
    } {

        if { ${secs} >= ${interval} } {
            set howmany [expr { ${secs} / ${interval} }]
            lappend result "${howmany}${suffix}"
            set secs [expr { ${secs} % ${interval} }]

        }

    }

    return [join ${result} { }]

}

proc ::feed_reader::stats {{news_sources ""}} {

    set feeds_dir [get_package_dir]/feed

    if { ${news_sources} eq {} } {
        set news_sources [glob -nocomplain -tails -directory ${feeds_dir} *]
    }

    puts [format "%40s %10s %10s %15s %15s" feed_name "Pr\[write\]" "#times/day" "interval" "#write / #fetch"]
    puts [format "%40s %10s %10s %15s %15s" --------- "---------"   "----------" "--------" "---------------"]

    set crawler_dir [get_crawler_dir]
    foreach news_source $news_sources {

        set feed_files [get_feed_files ${news_source}]
        foreach feed_file ${feed_files} {

            # set feed_name ${news_source}/[file tail ${feed_file}]
            set feed_name [file tail ${feed_file}]


	    ::persistence::__get_column          \
            "crawldb"                      \
            "feed_stats.by_feed_and_const" \
            "${feed_name}"                 \
            "_stats"                       \
            "column_data"

            array set count ${column_data}

            set reference_interval 86400
            set max_times 96
            lassign [get_sync_info count ${reference_interval} ${max_times}] pr num_times interval 


            # TODO: pretty interval
            #set interval_in_mins [expr { ${interval} / 60 }]
            set pretty_interval [::util::pretty_interval ${interval}]
            puts [format "%40s %10.1f %10.1f %15s %15s" ${feed_name} ${pr} ${num_times} ${pretty_interval} "$count(FETCH_AND_WRITE_FEED) / $count(FETCH_FEED)"]

            unset count
            
        }

    }
}

proc ::feed_reader::get_first_sync_timestamp {linkVar} {

    upvar $linkVar link

    set urlsha1 [get_urlsha1 ${link}]

    set where_clause [list [list urlsha1 = $urlsha1]]
    set oid [::crawldb::sync_info_t 0or1row $where_clause]
    if { $oid eq {} } {
        return 0
    }
    set atts [::crawldb::sync_info_t from_path $oid] 
    lassign [split [join [keylget atts "datetime_urlsha1"]] { }] revision_datetime

    # puts "get_first_sync_timestamp: urlsha1=$urlsha1 revision_datetime=$revision_datetime link=$link"

    if { ${revision_datetime} eq {} } {
        return 0
    }

    return [clock scan ${revision_datetime} -format "%Y%m%dT%H%M"]

}


proc ::feed_reader::get_last_sync_timestamp {linkVar} {

    upvar $linkVar link

    set urlsha1 [get_urlsha1 ${link}]

    set where_clause [list [list urlsha1 = $urlsha1]]
    set paths [::crawldb::sync_info_t find $where_clause]
    if { $paths eq {} } {
        return 0
    }
    set path [lindex $paths end]
    set atts [::crawldb::sync_info_t from_path $path] 
    lassign [split [join [keylget atts "datetime_urlsha1"]] { }] revision_datetime

    return [clock scan ${revision_datetime} -format "%Y%m%dT%H%M"]

}

proc ::feed_reader::auto_resync_p {feedVar link} {

    upvar $feedVar feed

    set now [clock seconds]
    set first_sync [get_first_sync_timestamp link]

    # do not check for revisions if the item is older than a day (or maxage)

    set maxage [get_value_if feed(check_for_revisions_maxage) "86400"]

    if { ${now} - ${first_sync} < ${maxage} } {

        set last_sync [get_last_sync_timestamp link]

        # check for revisions every hour (default) or given interval

        set interval [get_value_if feed(check_for_revisions_interval) "7200"]

        if { ${now} - ${last_sync} > ${interval} } {
            return 1
        }

    }

    return 0
}

proc ::feed_reader::print_sync_stats {feed_name statsVar} {
    upvar $statsVar stats

    puts [format "\t %20s" ${feed_name}]
    puts [format "\t %20s" [string repeat {-} [string length ${feed_name}]]]

    set do_not_show {FETCH_FEED NO_WRITE_FEED FETCH_AND_WRITE_FEED}
    if { $stats(ERROR_FETCH_FEED) } {
        set names {ERROR_FETCH_FEED}
    } elseif { $stats(NO_WRITE_FEED) } {
        set names {NO_FETCH NO_WRITE ERROR_FETCH}
    } else {
        set do_not_show [concat ${do_not_show} {ERROR_FETCH_FEED NO_WRITE_FEED}]
        set names [array names stats]
    }

    if { !$stats(ERROR_FETCH) } {
        lappend do_not_show {ERROR_FETCH}
    }

    if { !$stats(NO_WRITE) } {
        lappend do_not_show {NO_WRITE}
    }

    lassign [intersect3 ${names} ${do_not_show}] names _intersection_ _list2_

    foreach name ${names} {
        puts [format "\t %20s %s" ${name} $stats(${name})]
    }
    puts "\n\n"
}

proc print_round_stats {round_statsVar} {
    upvar $round_statsVar round_stats

    puts ""
    puts "--->>> round $round_stats(round_timestamp) stats"
    puts ""
    array unset round_stats round_timestamp
    foreach name [array names round_stats] {
        puts [format "%20s %s" ${name} $round_stats(${name})]
    }
    puts ""

}

proc update_round_stats {feed_name statsVar round_statsVar} {
    upvar $statsVar stats
    upvar $round_statsVar round_stats

    foreach name [array names stats] {
        incr round_stats(${name}) $stats(${name})
    }

    if { $stats(ERROR_FETCH_FEED) } {
        lappend round_stats(ERROR_FETCH_FEED_LIST) ${feed_name}
    }

    if { $stats(ERROR_FETCH) } {
        lappend round_stats(ERROR_FETCH_LIST) ${feed_name}
    }
}


proc progress_init {tot} {
    set ::progress_start     [clock seconds]
    set ::progress_last      0
    set ::progress_last_time 0
    set ::progress_tot       $tot
 }

 # We update if there's a 5% difference or a 5 second difference

 proc progress_tick {cur} {
    set now [clock seconds]
    set tot $::progress_tot

    if {$cur > $tot} {
        set cur $tot
    }
    if {($cur >= $tot && $::progress_last < $cur) ||
        ($cur - $::progress_last) >= (0.05 * $tot) ||
        ($now - $::progress_last_time) >= 5} {
        set ::progress_last $cur
        set ::progress_last_time $now
        set percentage [expr round($cur*100/$tot)]
        set ticks [expr $percentage/2]
        if {$cur == 0} {
            set eta   ETA:[format %7s Unknown]
        } elseif {$cur >= $tot} {
            set eta   TOT:[format %7d [expr int($now - $::progress_start)]]s
        } else {
            set eta   ETA:[format %7d [expr int(($tot - $cur) * ($now - $::progress_start)/$cur)]]s
        }
        set lticks [expr 50 - $ticks]
        set str "[format %3d $percentage]%|[string repeat = $ticks]"
        append str "[string repeat . $lticks]|[format %8d $cur]|$eta\r"
        puts -nonewline stdout $str
        if {$cur >= $tot} {
            puts ""
        }
        flush stdout
    }
 }

# TODO: instead of 3600 seconds, use ${now} - ${first_sync_of_feed}
#
# having sampled all hours, probability here tells us 
# how often a feed changes in a day
#

proc get_sync_info {countVar {reference_interval "86400"} {max_times "96"}} {

    upvar $countVar count

    set epsilon 0.00001

    if { [catch {
	set pr [expr { double(1 + $count(FETCH_AND_WRITE_FEED)) / double(1 + $count(FETCH_FEED)) }]
    } errmsg] } {

	puts "----------------->>> error errmsg=$errmsg count=[array get count]"

	return [list 0 0 0]
    }

    if { ${pr} < ${epsilon} } {

        set pr 0
        set num_times 1.0

    } else {

        set num_times [expr { ${pr} * ${max_times} }]

    }

    set interval [expr { int( ${reference_interval} / ${num_times} ) }]

    return [list ${pr} ${num_times} ${interval}]

}


proc ::feed_reader::fetch_feed_p {feed_name timestamp {coeff "0.3"}} {

    # 	{mdH-%m%d%H} would take too long to see results, so remove from list for now
    foreach format {
        {H-%H}
        {uH-%u%H}
    } {

        set pretty_timeval [clock format ${timestamp} -format ${format}]

        # set oid [::crawldb::stat_info_t find_by feed_name $feed_name $pretty_timeval]
        
        set oid \
            [::persistence::__get_column        \
                "crawldb"                       \
                "feed_stats.by_feed_and_period" \
                ${feed_name}                    \
                ${pretty_timeval}               \
                ""                              \
                exists_p]

        if { !$exists_p } {
            return 1
        }

        array set count [::persistence::get_data ${oid}]

        set reference_interval 3600
        set max_times 4
        lassign [get_sync_info count ${reference_interval} ${max_times}] pr num_times interval 

        set last_sync [::persistence::mtime $oid]
        if { ${pr} > 0 && ${last_sync} + ${interval} < ${timestamp} } {
            return 1
        }

        unset count
    }

    set oid [::persistence::__get_column      \
		      "crawldb"                       \
		      "feed_stats.by_feed_and_const"  \
		      "${feed_name}"                  \
		      "_stats"]
    
    if { ![::persistence::exists_data_p ${oid}] } {
        return 1
    }

    array set count [::persistence::get_data ${oid}]

    set last_sync [::persistence::mtime ${oid}]

    set reference_interval 86400
    set max_times 96
    lassign [get_sync_info count ${reference_interval} ${max_times}] pr num_times interval 

    # if last update more than the computed general interval then fetch
    if { ${last_sync} + ${interval} < ${timestamp} } {
        return 1
    }

    return 0

}


proc ::feed_reader::incr_array_in_column {ks cf_axis row_key column_path incrementVar} {

    upvar $incrementVar increment

    set oid "${ks}/${cf_axis}/${row_key}/+/${column_path}"
    ::persistence::get_column $oid column_data exists_p

    if { ${exists_p} } {
        array set count ${column_data}
    } else {
        array set count [list]
    }

    foreach name [array names increment] {
        incr count(${name}) $increment(${name})
    }

    set stats [array get count]

    ::persistence::insert_column $oid $stats

    return ${stats}

}


proc ::feed_reader::update_crawler_stats {timestamp feed_name statsVar} {

    upvar $statsVar stats

    foreach format {
        {H-%H}
        {uH-%u%H}
        {mdH-%m%d%H}
    } {

	set pretty_timeval [clock format ${timestamp} -format ${format}]
	
	incr_array_in_column                \
	    "crawldb"                       \
	    "feed_stats.by_feed_and_period" \
	    "${feed_name}"                  \
	    "${pretty_timeval}"            \
	    "stats"

    }

    incr_array_in_column                \
        "crawldb"                       \
        "feed_stats.by_feed_and_const" \
        "${feed_name}"                  \
        "_stats"                        \
        stats

}
