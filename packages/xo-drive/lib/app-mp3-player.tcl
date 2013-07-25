#source [acs_root_dir]/packages/kernel/tcl/20-templating/00-renderingvisitor-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/10-ui-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/37-flv-procs.tcl



namespace path ::xo::ui


#more_info amazon.com/Revival-Postmen/dp/B00005J8R7/sr=1-6/qid=1166887655/ref=sr_1_6/105-9454024-2355627?ie=UTF8&s=music

set id [ns_queryget id]
set mp3_artist [ns_queryget mp3_artist]
set mp3_title [ns_queryget mp3_title]

set pathexp [list "User [ad_conn user_id]"]
set list ""
foreach item $pathexp {
    ###foreach {className instance_id} $item break
    lassign $item className instance_id
    lappend list [$className set id]-${instance_id}
}


set directory /web/data/storage/
append directory [join $list .]/
append directory $id

MP3 new \
    -path $directory \
    -filename "${id}.mp3" \
    -image preview/c-${id}_p-1-s120.jpg \
    -identifier $id \
    -creator $mp3_artist \
    -title $mp3_title \
    -thumbsinplaylist false \
    -more_info http://www.phigita.net/

