set result ""
set conn [DB_Connection new]
set tablename xo.xo__sw__agg__url
foreach url_obj [$conn query "select url,video_p from $tablename"] {
  if { [$url_obj set video_p] eq {t} } continue
  set url [$url_obj set url]
  set video_p f
  if { [catch {
    if { [::util::videoIf $url href video_id] } {
      lassign [::xo::buzz::getVideo $video_id] found_p vo
      if { $found_p } {
        set video_p t
        set extra [dict create video_id $video_id]
        $conn do "update $tablename set video_p='t',extra=[ns_dbquotevalue $extra] where url=[ns_dbquotevalue $url]"
        lappend result $url
      }
    }
  } errMsg] } { lappend result "$errMsg" }
}

set result
