ad_page_contract {
    @author Neophytos Demetriou
} {
    item_id:integer
    {start:integer 0}
    {limit:integer "5"}
    {q:trim ""}
    {order_by:trim "r1"}
}

if { $limit > 10 } { 
    set limit 10
}

source [acs_root_dir]/packages/xo-drive/www-pvt/view/auxiliary.tcl

#set host http://www.phigita.net/
set host "" 
set urlPrefix /lib/ext-1.1-beta1/examples/view/images/thumbs/

set path [acs_root_dir]/www${urlPrefix}

#	      -where [list "extra->'XO.File.Magic'='JPEG'"]

set pathexp [list "User [ad_conn user_id]"]
set data [::db::Set new \
	      -pathexp $pathexp \
	      -type ::Content_Item_Part \
	      -offset $start -noinit]

set stats [::db::Set new \
	       -pathexp $pathexp \
	       -select [list "count(1) as total_count"] \
	       -type ::Content_Item_Part -noinit]

$data lappend where item_id=[::util::dbquotevalue $item_id]
$stats lappend where item_id=[::util::dbquotevalue $item_id]

if { [exists_and_not_null limit] } { $data set limit $limit }


if { [exists_and_not_null q] } { 
    set searchQuery [::util::dbquotevalue [join ${q} {&}]]
    #set tsQuery [[$data getConn] getvalue "select to_tsquery('simple',$searchQuery)"]
    set tsQuery [[$data getConn] getvalue "select to_tsquery('[default_text_search_config]',$searchQuery)"]
    if { $tsQuery ne {} } {
	$data set select "part_index"
	$data lappend select "ts_headline('[default_text_search_config]',part_text,[::util::dbquotevalue $tsQuery],'MaxWords=25, MinWords=15') as part_snippet"

	# Get extents
	# Order extents by importance
	# Choose 2-3 extents 
	#$data lappend select "get_covers(ts_vector,[::util::dbquotevalue $tsQuery]) as part_snippet"


	if { $order_by eq {r0} } {
	    ### normalization
	    # 0 : no normalization
	    # 1 : log(document length)
	    # 2 : document length
	    #$data lappend select "rank('{0.1, 0.2, 0.4, 1.0}',ts_vector,[::util::dbquotevalue $tsQuery],1|4) as rank"
	    $data lappend select "rank(ts_vector,[::util::dbquotevalue $tsQuery],0) as rank"
	    $data order "rank desc"
	} 

	if { $order_by eq {r1} } {
	    ### rank_cd normalization
	    # 0  : no normalization
	    # 1  : 1+log (document length)
	    # 2  : document length
	    # 4  : mean harmonic distance between extents
	    # 8  : the number of unique words in document
	    # 16 : 1+log (the number of unique words in document)

	    $data lappend select "ts_rank_cd(ts_vector,[::util::dbquotevalue $tsQuery],4|16) as rank"
	    $data order "rank desc"
	} 

	if { $order_by eq {i0} } {
	    $data order "part_index desc"
	}

	$data lappend where "ts_vector @@  [::util::dbquotevalue $tsQuery]::tsquery "
	$data load

	$stats lappend where "ts_vector @@  [::util::dbquotevalue $tsQuery]::tsquery "
	$stats load
	set totalCount [[$stats head] set total_count]
    } else {
	set totalCount 0
	# do nothing, empty query, empty result set
    }
} else {
    $data load
    $stats load
    set totalCount [[$stats head] set total_count]
}




set searchResults [ListArray new]
set result [AssociativeArray new]
$result setValueOf -type object searchResults $searchResults
$result setValueOf -type atom totalCount $totalCount


foreach o [$data set result] {
    set part_index [$o set part_index]
    set part_snippet [$o set part_snippet]
    
    $searchResults add -type object [AssociativeArray new -setValue [list part_index $part_index part_text $part_snippet]]
}


ns_return 200 text/plain [$result json_encode]

