set conn [DB_Connection new]
foreach o [::bm::Bookmark getTableList] {
  set tablename [$o set name]
  foreach url_obj [$conn query "select url from $tablename"] {
    set url [$url_obj set url]
    set video_p f
    if { [::util::videoIf $url href video_id] } {
      lassign [::xo::buzz::getVideo $video_id] found_p vo
      if { $found_p } {
        set video_p t
        set extra [dict create video_id $video_id]
        $conn do "update $tablename set video_p='t',extra=[ns_dbquotevalue $extra] where url=[ns_dbquotevalue $url]"
        lappend result $url
      }
    }
  }
}
set result
