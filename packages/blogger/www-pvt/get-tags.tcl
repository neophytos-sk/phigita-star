ad_page_contract {
    @author Neophytos Demetriou
} {
    {q:trim ""}
}

set limit 10

source [acs_root_dir]/packages/xo-drive/www-pvt/view/auxiliary.tcl


set lastWord [string trim [lindex [split ${q} ","] end]]


set pathexp [list "User [ad_conn user_id]"]
set data [::db::Set new \
	      -pathexp $pathexp \
	      -select {{name as tag_name} {cnt_entries as num_occurs}} \
	      -type ::Blog_Item_Label \
	      -order "cnt_entries desc" \
	      -limit $limit \
	      -noinit]

if { $lastWord ne {} } {
    set searchQuery "[string map {% {}} ${lastWord}]%"
    $data lappend where "name ilike [ns_dbquotevalue "${searchQuery}"]"
}

$data load

set tags [ListArray new]
set result [AssociativeArray new]
$result setValueOf -type object tags $tags
#$result setValueOf -type atom totalCount $totalCount


foreach o [$data set result] {
    set tagName [$o set tag_name]
    set numOccurs [$o set num_occurs]
    
    $tags add -type object [AssociativeArray new -setValue [list tagName $tagName numOccurs $numOccurs]]
}


ns_return 200 text/plain [$result json_encode]

