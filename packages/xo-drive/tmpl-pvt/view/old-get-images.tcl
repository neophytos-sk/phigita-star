ad_page_contract {
    @author Neophytos Demetriou
} {
    {x_offset:integer 0}
    {x_limit:integer "50"}
    {filetype:trim ""}
    {q:trim ""}
    {starred_p:boolean ""}
    {hidden_p:boolean "f"}
    {deleted_p:boolean "f"}
    {shared_p:boolean ""}
    {include_guid_p "f"}
    label_id:integer,optional
    {order_by:trim "d0"}
}

if { $x_limit > 100 } { 
    set x_limit 100
}

set start $x_offset
set limit $x_limit

source [acs_root_dir]/packages/xo-drive/www-pvt/view/auxiliary.tcl

#set host http://www.phigita.net/
set host "" 
set urlPrefix /lib/ext-1.1-beta1/examples/view/images/thumbs/

set path [acs_root_dir]/www${urlPrefix}

#	      -where [list "extra->'XO.File.Magic'='JPEG'"]

### (select trim(xo__concatenate_aggregate(name || ', '),', ') from xo__u814.xo__content_item_label l inner join int_array_enum(c.tags_ia) tag_id on (id=tag_id))

set pathexp [list "User [ad_conn user_id]"]

set ds_tags [::db::Set new \
		 -alias tags \
		 -select [list "trim(xo__concatenate_aggregate('{' || label.name || '} {' || coalesce((extra->'bgcolor'),'') || '} {' || coalesce((extra->'fontcolor'),'') ||'} ' ),' ')"] \
		 -type [::db::Inner_Join new \
			    -lhs [::db::Set new -alias label -pathexp ${pathexp} -type ::Content_Item_Label] \
			    -rhs [::db::Set new -alias tag_id -from int_array_enum(tags_ia)] \
			    -join_condition "label.id=tag_id.int_array_enum"] \
		 -noinit]


set ds_items [::db::Set new \
		  -pathexp ${pathexp} \
		  -select {
		      item.tags_ia
		      item.id 
		      item.title 
		      {item.extra->'XO.File.Size' as file_size} 
		      {lower(item.extra->'XO.File.Magic') as file_magic} 
		      {lower(item.extra->'XO.File.Type') as filetype} 
		      item.shared_p 
		      item.deleted_p 
		      item.hidden_p 
		      item.starred_p 
		  } -type [db::Set new -pathexp ${pathexp} -type ::Content_Item -alias item] \
		  -offset $start \
		  -noinit]


set data [::db::Set new \
	      -pathexp $pathexp \
	      -viewFields [list $ds_tags] \
	      -type $ds_items \
	      -noinit]


set stats [::db::Set new \
	       -pathexp $pathexp \
	       -select [list "count(1) as total_count"] \
	       -type ::Content_Item -noinit]

if { $deleted_p ne {} } {
    $stats lappend where "deleted_p=[ns_dbquotevalue $deleted_p]"
    $ds_items lappend where "deleted_p=[ns_dbquotevalue $deleted_p]"
#    set hidden_p ""
}
if { $shared_p ne {} } {
    $stats lappend where "shared_p=[ns_dbquotevalue $shared_p]"
    $ds_items lappend where "shared_p=[ns_dbquotevalue $shared_p]"
}
if { $hidden_p ne {} } {
    $stats lappend where "hidden_p=[ns_dbquotevalue $hidden_p]"
    $ds_items lappend where "hidden_p=[ns_dbquotevalue $hidden_p]"
}
if { $starred_p ne {} } {
    $stats lappend where "starred_p=[ns_dbquotevalue $starred_p]"
    $ds_items lappend where "starred_p=[ns_dbquotevalue $starred_p]"
}
if { [info exists label_id] } {
    if { $label_id ne {} } {
	set label_clause "tags_ia @> [ns_dbquotevalue \{$label_id\}]::integer\[\]"
    } else {
	set label_clause "tags_ia is null"
    }
    $stats lappend where $label_clause ;# "tags_ia ${op} [ns_dbquotevalue \{$label_id\}]::integer\[\]"
    $ds_items lappend where $label_clause  ;# "tags_ia ${op} [ns_dbquotevalue \{$label_id\}]::integer\[\]"
}

if { [exists_and_not_null limit] } { $ds_items set limit $limit }

if { [exists_and_not_null filetype] } {
    $stats lappend where "extra->'XO.File.Type' = [::util::dbquotevalue $filetype]"
    $ds_items lappend where "extra->'XO.File.Type' = [::util::dbquotevalue $filetype]"
}



if { $order_by eq {d0} } {
    $ds_items order "item.creation_date desc"
}


if { [exists_and_not_null q] } { 

    set searchQuery [::util::dbquotevalue [join ${q} {&}]]
    set tsQuery [[$ds_items getConn] getvalue "select to_tsquery('[default_text_search_config]',$searchQuery)"]
    if { $tsQuery ne {} } {

	set order_by r0

	if { $order_by eq {r0} } {
	    ### rank normalization
	    # 0 : no normalization
	    # 1 : log(document length)
	    # 2 : document length
	    $ds_items lappend select "ts_rank('{0.1, 0.2, 0.4, 1.0}',ts_vector,[::util::dbquotevalue $tsQuery],2) as rank_r0"
	    $ds_items order "rank_r0 desc"
	} 

	if { $order_by eq {r1} } {
	    ### rank_cd normalization
	    # 0  : no normalization
	    # 1  : 1+log (document length)
	    # 2  : document length
	    # 4  : mean harmonic distance between extents
	    # 8  : the number of unique words in document
	    # 16 : 1+log (the number of unique words in document)

	    #$ds_items lappend select "ts_rank_cd('{0.1, 0.2, 0.4, 1.0}',ts_vector,[::util::dbquotevalue $tsQuery],1|4|16) as rank_r1"
	    $ds_items lappend select "ts_rank_cd(ts_vector,[::util::dbquotevalue $tsQuery],1|4|16) as rank_r1"
	    $ds_items order "rank_r1 desc"
	} 



	$ds_items lappend where "ts_vector @@  [::util::dbquotevalue $tsQuery]::tsquery "
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


#ns_log notice "get images sql=[$data set sql]"

set images [ListArray new]
set result [AssociativeArray new]
$result setValueOf -type object images $images
$result setValueOf -type atom totalCount $totalCount


foreach o [$data set result] {
    set id [$o set id]
    set title [$o set title]
    set file_size [$o set file_size]
    set tags ""
    ###ns_log notice "tags=[$o set tags]"
    foreach {name bgcolor fontcolor} [$o set tags] {
	lappend tags "\{name:'${name}', bgcolor:'${bgcolor}', fontcolor:'${fontcolor}'\}"
    }
    set tags \[[join $tags {,}]\]
    set url view/[$o set id]
    set file_magic [$o set file_magic]
    set filetype [$o set filetype]

    set aa [AssociativeArray new -setValue [list id $id title $title size $file_size magic $file_magic filetype $filetype shared_p [$o set shared_p] starred_p [$o set starred_p] deleted_p [$o set deleted_p] hidden_p [$o set hidden_p] url ${host}${url} ]]
    $aa setValue -type js [list tags $tags]
    $images add -type object $aa
}


ns_return 200 text/plain [$result json_encode]

