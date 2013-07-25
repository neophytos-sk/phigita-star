ad_page_contract {
  Displays active commnities

    @author Gustaf Neumann 

    @cvs-id $id$
} -query {
  {orderby:optional "count,desc"}
} -properties {
    title:onevalue
    context:onevalue
}

set title "Active Communities"
set context [list "Active Communities"]

TableWidget t1 \
    -columns {
      AnchorField community -label Community -orderby community
      Field count -label Count -orderby count
    }

foreach {att order} [split $orderby ,] break
t1 orderby -order [expr {$order eq "asc" ? "increasing" : "decreasing"}] $att

foreach {community_id users} [throttle users active_communities] {
  if {$community_id eq ""} continue
  t1 add \
      -community [dotlrn_community::get_community_name $community_id] \
      -community.href [export_vars -base users-in-community {community_id}] \
      -count [llength [lsort -unique [eval concat $users]]]
}
set t1 [t1 asHTML]