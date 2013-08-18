source /var/lib/naviserver/service-phigita/packages/persistence/pdl/45-classification.tcl

tmpl::master -title "Create Class" -context_bar [ad_context_bar [list .. "Administration"] [list . "Classification"] "Create Class"] {

    form -action class-add-2 -method post {
	t "Class: "
	input -type input -value "" -name tree_sk
	input -type submit -value "Create"
    }

}