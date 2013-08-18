source /var/lib/naviserver/service-phigita/packages/persistence/pdl/45-classification.tcl

ad_page_contract {
	@author Neophytos Demetriou
} {
	id:naturalnum,notnull
}

set data [db::Set new -pool newsdb -type ::classification::Class -where [list id=[ns_dbquotevalue $id]]]
$data load
set o [$data head]



tmpl::master -title "Edit Class" -context_bar [ad_context_bar [list .. "Administration"] [list . "Classification"] "Edit Class"] {

    form -action class-edit-2 -method post {
	input -type hidden -name id -value $id
	input -type hidden -name prev_tree_sk -value [$o set tree_sk]
	t "Class: "
	input -type input -name tree_sk -value [$o set tree_sk]
	input -type submit -value "Edit"
    }

}