namespace eval blogger {;}

proc blogger::get_labels_and_count {ctx_uid} {
set conn [DB_Connection new -volatile]
if {[${conn} exists [Blog_Item_Label_Map pdl.table.exists xo__u${ctx_uid} xo__blog_item_label_map]]} {
    $conn destroy
    set labels_list [Blog_Item_Label retrieve \
                         -pathexp "User ${ctx_uid}" \
                         -output "*, (select count(1) from xo__u${ctx_uid}.xo__blog_item_label_map where label_id=id) as n_count"\
                         -order "name"]
} else {
    $conn destroy
    set labels_list [Blog_Item_Label retrieve \
                         -pathexp "User ${ctx_uid}" \
                         -output "*, 0 as n_count"\
                         -order "name"]
}

  return ${labels_list}
}

proc print_labels_list { id labels__agg v__labels__index {stub ""}} {
    upvar labels__index ${v__labels__index}
    set labels__list [join [string map {, " "} ${labels__agg}]]
    foreach label_id ${labels__list} {
	a -class "cs" -href "${stub}${label_id}" {
	    t $labels__index(${label_id})
	}
	t -disableOutputEscaping "&nbsp;"
	a -style "color:blue;" -href "${stub}one-unapply?label_id=${label_id}&object_id=${id}" -title "Remove label from entry" {
	    t "\[x\]"
	}
	t -disableOutputEscaping "&nbsp;&nbsp; "
    }
}

