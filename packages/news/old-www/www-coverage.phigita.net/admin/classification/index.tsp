#source /var/lib/naviserver/service-phigita/packages/persistence/pdl/45-classification.tcl


set classList [db::Set new -pool newsdb -type ::classification::Class -order tree_sk]
$classList load


tmpl::master -title "Classification" -context_bar [ad_context_bar [list .. Administration] Classification] {

    a -href "class-add" {
	t "New Class"
    }

    ul {
	foreach classObject [$classList set result] {
	    li {
		t "[::util::pad [$classObject set id] 3] - [mc [$classObject set tree_sk] [$classObject set tree_sk]]"
		t " \["
		a -href "class-delete?id=[$classObject set id]" {
		    t "delete"
		}
		t "\] "
		t " \["
		a -href "class-edit?id=[$classObject set id]" {
		    t "edit"
		}
		t "\]"
	    }
	}
    }

}