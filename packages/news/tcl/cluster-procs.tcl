namespace eval bow {;};			# 
ad_proc ::bow::getClusters {
    {-k "40"}
    {-numIterations "45"}
    {-stopwords ""}
    dataset
} {
    @author Neophytos Demetriou
    @param k Threshold Index.
} {

    set start_time [ns_time]


    set golden_ratio 1.61803399
    set bestNumClusters 0
    set bestValue 1.0
    set bestThresholdIndex 0
    set bestValueClusters ""
    set bestStats ""
    set size [llength $dataset]

    if { $size > 3 } {
	for {set i 0} {$i<$numIterations} {incr i 1} {
	    set k [expr { int(100*rand()) }]

	    lassign [ttext::cluster ${k} ${dataset} ${stopwords}] stats clusters
	    lassign $stats low high average outAvg inAvg stdev outStdev
	    
	    set numClusters [llength $clusters]
	    if { $numClusters } {
		set thisValue [expr { abs(double($outAvg)-double($inAvg)-0.54) }]
		if { $thisValue <= $bestValue } {
		    set bestNumClusters $numClusters
		    set bestValue $thisValue
		    set bestValueClusters $clusters
		    set bestThresholdIndex $k
		    set bestStats $stats
		}
	    }
	}
    }
    set end_time [ns_time]
    
    ns_log notice "::bow::getClusters numClusters=$bestNumClusters bestValue=$bestValue k=$bestThresholdIndex time=[expr { $end_time - $start_time }] stats=$bestStats"

    return $bestValueClusters

}

ad_proc ::bow::refreshClusters {
    {-interval "48 hours"}
    {-limit "900"}
    {-documentTable "xo.xo__sw__agg__url"}
    {-clusterTable "xo.xo__clustering__class"}
} {
    @author Neophytos Demetriou
} {


    set eto [::db::Set new -pool newsdb -select [list "distinct classification__edition_sk,classification__tree_sk"] -type ::sw::agg::Url -where [list "not buzz_p" "not feed_p" "creation_date>current_timestamp-'48 hours'::interval"]]
    $eto load

    set previous_seconds 0
    set current_seconds [ns_time]
    ns_log notice "refreshClusters: START ROUND"
    if {[catch {


	foreach eto_item [$eto set result] {
	    ns_log notice [$eto_item info vars]
	    set edition [$eto_item set classification__edition_sk]
	    set topic [$eto_item set classification__tree_sk]

	    set op "=" 
		set connObject [DB_Connection new -volatile -pool newsdb]
		ns_log notice "refreshClusters: Connection OK"

		set topic_sk [string map {. _} $topic]
		set edition_sk [string map {. _} $edition]
		set time_sk [ns_fmttime [ns_time] "%Y.%m.%d.%H.%M.%S"]
		set newsdata [::db::Set new \
				  -volatile \
				  -pool newsdb \
				  -select "u.* i.ts_vector {extract(epoch from current_timestamp-u.creation_date) as seconds_past}" \
				  -from "xo.xo__sw__agg__url u inner join xo.xo__news_in_greek i on (u.url=i.url)" \
				  -where [list "not buzz_p" \
					      "u.classification__tree_sk ${op} [ns_dbquotevalue $topic]" \
					      "u.classification__edition_sk = [ns_dbquotevalue $edition]" \
					      "u.creation_date > current_timestamp-[ns_dbquotevalue $interval]::interval"] \
				  -order "creation_date desc" \
				  -limit $limit \
				  -load]



		if { [llength [$newsdata set result]] < 5 } {
		    ns_log notice "Skip"
		    continue
		}

		set objectList [$newsdata set result]

		### Prepare data for clustering
		set dataset ""
		set dataset_size 0
		foreach o $objectList {
		    lappend dataset [::bow::getExpandedVector [$o set ts_vector]]
		    incr dataset_size
		}

		### Perform clustering
		ns_log notice "Topic=$topic Edition=$edition Size=$dataset_size BEGIN"
		set clusters [::bow::getClusters $dataset]
		ns_log notice "Topic=$topic Edition=$edition END"


		### Store clusters
		if { $clusters ne {} } {
		    set sql "BEGIN;\n"
		    #		append sql "update $clusterTable set live_p='f' where cluster_sk <@ [ns_dbquotevalue [join "$topic_sk $edition_sk" .]];"
		    append sql "delete from $clusterTable where cluster_sk <@ [ns_dbquotevalue [join "$topic_sk $edition_sk" .]];"

		    set i 0
		    foreach cluster [lreverse $clusters] {
			set cluster_sk ${topic_sk}.${edition_sk}.${time_sk}.[::util::pad ${i} 3]
			set cnt_documents [llength $cluster]
			
			set clusterMemberList ""
			set clusterHead [lindex $objectList [lindex $cluster 0]]
			set clusterHeadTitle [$clusterHead set title]
			set clusterHeadURL [$clusterHead set url]
			set clusterHeadSummary [$clusterHead set last_crawl_content]
			set clusterImageFile ""
			set clusterImageURL ""
			foreach index $cluster {
			    set o [lindex $objectList $index]
			    if { $clusterImageFile eq {} && [$o set image_file] ne {} } {
				set clusterImageFile [$o set image_file]
				set clusterImageURL [$o set url]
			    }
			    lappend clusterMemberList [ns_dbquotevalue [$o set url_sha1]]
			}
			append sql "insert into ${clusterTable} (cluster_sk,topic_sk,edition_sk,cnt_documents,head_title,head_url,head_summary,live_p,image_file,image_url,nlevel_topic_sk,nlevel_edition_sk,dataset_size) values ([ns_dbquotevalue $cluster_sk],[ns_dbquotevalue $topic],[ns_dbquotevalue $edition],[ns_dbquotevalue $cnt_documents], [ns_dbquotevalue $clusterHeadTitle],[ns_dbquotevalue $clusterHeadURL],[ns_dbquotevalue $clusterHeadSummary],'t',[ns_dbquotevalue $clusterImageFile],[ns_dbquotevalue $clusterImageURL],nlevel([ns_dbquotevalue $topic]),nlevel([ns_dbquotevalue $edition]),$dataset_size);"
			append sql "update $documentTable set clustering__cluster_sk=[ns_dbquotevalue $cluster_sk]::ltree where url_sha1 in ([join $clusterMemberList ,]);\n"

			incr i
		    }
		    append sql "delete from $clusterTable where creation_date < current_timestamp-'48 hours'::interval;"
		    append sql "END;"
		    append sql "VACUUM FULL ANALYZE ${clusterTable};"
		    $connObject do $sql
		}
		foreach o [$newsdata set result] {
		    $o destroy
		}
		$newsdata destroy
		ns_log notice "refreshClusters: newsdata destroy ok"
		$connObject destroy 
		ns_log notice "refreshClusters: Connection Released"
	}
    
    } errmsg]} {
	ns_log notice "refreshClusters: Error: $errmsg"
    }




    set previous_seconds $current_seconds
    ns_log notice "refreshClusters: END ROUND"

}

ns_log notice "is_crawler_p=[ns_config ns/server/[ns_info server] is_crawler_p 0]"
if { 0 && [ns_config ns/server/[ns_info server] is_crawler_p 0] } {
    ad_schedule_proc -thread t 7200 ::bow::refreshClusters
}