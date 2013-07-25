source [acs_root_dir]/www/__tests/async-request/30-xo-comm-procs.tcl
#source [acs_root_dir]/www/__tests/test-youtube/20-xo-dom-procs.tcl

set dev_id IPSDHWTqBr4
set video_id F5EqOiye7zI

set url [format "http://www.youtube.com/api2_rest?method=youtube.videos.get_details&dev_id=%s&video_id=%s" $dev_id $video_id]




namespace eval ::xo::remote {;}
namespace eval ::xo::remote::ut {;}

Class ::xo::remote::ut::Video
Class ::xo::remote::ut::Video instproc parse {xml} {
}

set o [xo::comm::CurlHandle new -url $url -volatile]
$o perform

doc_return 200 text/xml [$o set curlResponseBody]