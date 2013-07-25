source [acs_root_dir]/packages/xo-drive/www-pvt/view/auxiliary.tcl

#XO.Info.title
#XO.Info.author
#XO.Info.creationdate



ad_page_contract {
    @author Neophytos Demetriou
} {
    id:integer
    {q:trim,notnull ""}
}

set pathexp [list "User [ad_conn user_id]"]


set ds_tags [::db::Set new \
		 -alias tags \
		 -select [list "trim(xo__concatenate_aggregate(label.name || ', '),', ')"] \
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
		      item.extra
		  } -type [db::Set new -pathexp ${pathexp} -type ::Content_Item -alias item] \
		  -order "item.creation_date desc" \
		  -where [list "item.id=${id}"] \
		  -noinit]


set data [::db::Set new \
	      -pathexp $pathexp \
	      -viewFields [list $ds_tags] \
	      -type $ds_items \
	      -noinit]


$data load
set o [$data head]


set fileRecord [ListArray new]
set result [AssociativeArray new]
$result setValueOf -type object fileRecord $fileRecord


set arro [AssociativeArray new -setValue [list \
					      id [$o set id] \
					      title [$o set title] \
					      size [$o set file_size] \
					      tags [$o set tags] \
					      starred_p [$o set starred_p] \
					      hidden_p [$o set hidden_p] \
					      deleted_p [$o set deleted_p] \
					      shared_p [$o set shared_p]]]


set extra [$o set extra]
set extra [filter_metadata $extra [$o set filetype]]


$arro setValueOf -type object extra [AssociativeArray new -setValue [hstore2dict $extra]]
$fileRecord add -type object $arro

set json [::util::map2json L|M:fileRecord [list [list \
						     n:id [$o set id] \
						     s:title [$o set title] \
						     s:size [$o set file_size] \
						     L:tags [$o set tags] \
						     b:starred_p [$o set starred_p] \
						     b:hidden_p [$o set hidden_p] \
						     b:deleted_p [$o set deleted_p] \
						     b:shared_p [$o set shared_p] \
						     M:extra [hstore2dict $extra]]]]

ns_return 200 text/plain $json
#ns_return 200 text/plain [$result json_encode]
