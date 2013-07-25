
set pathexp [list "User [ad_conn user_id]"]
set data [::db::Set new \
	      -pathexp $pathexp \
	      -select "* {extra->'color' as color}" \
	      -type ::Content_Item_Label \
	      -order "cnt_entries desc" \
	      -noinit]
$data load

source [acs_root_dir]/packages/xo-drive/www-pvt/view/auxiliary.tcl


########
#$data lappend result [Object new -set title "resources" -set value 1]
#$data lappend result [Object new -set title "source" -set value 2]
#$data lappend result [Object new -set title "build" -set value 3]
#$data lappend result [Object new -set title "adapter" -set value 4]
#$data lappend result [Object new -set title "examples" -set value 5]
#$data lappend result [Object new -set title "docs" -set value 6]
###############

set result [ListArray new]
$result add -type object [AssociativeArray new -setValue [list text " Items not in folders" leaf true cls z-static-folder iconCls z-itemsnotinfolders]]
foreach o [$data set result] {
    $result add -type object [AssociativeArray new -setValue [list text [$o set name] label_id [$o set id] cnt_entries ([$o set cnt_entries]) color [$o set color] leaf true cls z-folder]]
}

ns_return 200 text/plain [$result json_encode]
return
