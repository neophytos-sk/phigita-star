if { ![::util::boolean [ad_conn issecure]] } {
    ad_returnredirect https://[ad_host][ns_conn url]
    return
}
permission::require_permission -object_id [ad_conn package_id] -privilege admin

ad_page_contract {
    @author Neophytos Demetriou
} {
    cmd:trim,notnull,optional
}

tmpl::master -onload "javascript:document.forms\['sh'\].elements\['cmd'\].focus()" {

    if {[exists_and_not_null cmd]} {
	set result [exec -- /bin/sh -c "${cmd} || exit 0" 2> /dev/null]
	pre {
	    div -class code {
		t ${result}
	    }
	}
    }

    form -name sh -action . -method post {
	input -type text -name cmd
	input -type submit
    }


}