#source [acs_root_dir]/packages/kernel/tcl/20-templating/00-renderingvisitor-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/10-ui-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/37-flv-procs.tcl


#ns_log notice "id=$id queryget_id=[ns_queryget id] [ns_set iget [::xo::ns::getform] id]"

namespace path {::xo::ui}

set id [ns_queryget id]

set pathexp [list "User [ad_conn user_id]"]
set list ""
foreach item $pathexp {
    foreach {className instance_id} $item break
    lappend list [$className set id]-${instance_id}
}
set directory /web/data/storage/
append directory [join $list .]/
append directory $id


FLV new \
    -path $directory \
    -vidID ${id} \
    -filename "c-${id}.flv" \
    -image preview/c-${id}_p-1-s240.jpg

for {set i 1} {$i <= 8} {incr i 2} {
    ImageFile new -image_file ${directory}/preview/c-${id}_p-${i}-s120.jpg
}
	
