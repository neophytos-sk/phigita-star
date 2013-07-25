ad_page_contract {
} {
}

template::multirow create caches name entries size max flushed hit_rate

foreach cache [lsort -dictionary [ns_cache_names]] {
	array set stats [ns_cache_stats $cache]
	set size [format "%.2f MB" [expr $stats(size) / 1048576.0]]
	set max [format "%.2f MB" [expr $stats(maxsize) / 1048576.0]]
	#ns_cache_stats $match stats_array
	set entries $stats(entries)
	set flushed $stats(flushed)
	set hit_rate $stats(hitrate)
	template::multirow append caches $cache $entries $size $max \
		$flushed $hit_rate

}

