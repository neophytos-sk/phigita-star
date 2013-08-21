

proc ::feed_reader::fetch_feed_p {feed_name timestamp {coeff "0.3"}} {

    set crawler_dir [get_crawler_dir]
    set crawler_feed_dir "${crawler_dir}/feed/${feed_name}/"

    # 	{mdH-%m%d%H} would take too long to see results, so remove from list for now
    foreach format {
	{H-%H}
	{uH-%u%H}
    } {

	set pretty_timeval [clock format ${timestamp} -format ${format}]
	set crawler_feed_sync_dir ${crawler_feed_dir}/${pretty_timeval}/
	
	if { ![file isdirectory ${crawler_feed_sync_dir}] } {
	    return 1
	}
	
	set filename ${crawler_feed_dir}/${pretty_timeval}/_stats

	array set count [::util::readfile ${filename}]

	set reference_interval 3600
	set max_times 4
	lassign [get_sync_info count ${reference_interval} ${max_times}] pr num_times interval 

	set last_sync [file mtime ${filename}]
	if { ${pr} > 0 && ${last_sync} + ${interval} < ${timestamp} } {
	    return 1
	}

	unset count
    }

    # we don't have to check existence of this file
    # because you cannot possibly reach this point 
    # without having checked sub-directories for
    # the hour, day of the week, and month-day stats.
    #
    set filename "${crawler_feed_dir}/_stats"

    set last_sync [file mtime ${filename}]

    array set count [::util::readfile ${filename}]

    set reference_interval 86400
    set max_times 96
    lassign [get_sync_info count ${reference_interval} ${max_times}] pr num_times interval 

    # if last update more than the computed general interval then fetch
    if { ${last_sync} + ${interval} < ${timestamp} } {
	return 1
    }

    return 0

}

proc ::feed_reader::update_crawler_stats {timestamp feed_name statsVar} {

    upvar $statsVar stats

    set crawler_dir [get_crawler_dir]
    set crawler_feed_dir "${crawler_dir}/feed/${feed_name}/"

    foreach format {
	{H-%H}
	{uH-%u%H}
	{mdH-%m%d%H}
    } {

	set pretty_timeval [clock format ${timestamp} -format ${format}]
	set crawler_feed_sync_dir ${crawler_feed_dir}/${pretty_timeval}/
	
	if { ![file isdirectory ${crawler_feed_sync_dir}] } {
	    file mkdir ${crawler_feed_sync_dir}
	}
	
	set crawler_feed_sync_stats ${crawler_feed_dir}/${pretty_timeval}/_stats
	incr_array_in_file ${crawler_feed_sync_stats} stats

    }

    incr_array_in_file "${crawler_feed_dir}/_stats" stats

}
