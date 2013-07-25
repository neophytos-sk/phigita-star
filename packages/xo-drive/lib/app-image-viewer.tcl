

ad_page_contract {
    @author Neophytos Demetriou
} {
    id:integer
    {size:integer "500"}
}

if { -1 == [lsearch -exact "120 240 500 800" $size] } {
    set size 500
}



set pathexp [list "User [ad_conn user_id]"]
set list ""
foreach item $pathexp {
    foreach {className instance_id} $item break
    lappend list [$className set id]-${instance_id}
}
set directory /web/data/storage/
append directory [join $list .]/
append directory $id

namespace eval ::xo::ui [subst -nocommands {

    Widget new -appendFromScript {

	NavTabPanel new -value $size -appendFromScript {
	    NavTabPanel.TextAnchor new -href [export_vars -base . -override [list "size 240"]] -label "small" -value "240"
	    NavTabPanel.TextAnchor new -href [export_vars -base . -override [list "size 500"]] -label "medium" -value "500"
	    NavTabPanel.TextAnchor new -href [export_vars -base . -override [list "size 800"]] -label "large" -value "800"
	}

	ImageFile new -image_file ${directory}/preview/c-${id}_p-1-s${size}.jpg -override_vars [list "size $size"]

    }
}]
