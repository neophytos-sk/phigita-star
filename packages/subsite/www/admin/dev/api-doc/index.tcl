ad_page_contract {

	@author Neophytos Demetriou

} {
	{tclproc ""}
}

if {[set tclproc] != ""} {
    set procbody [info body $tclproc]
    set procargs [info args $tclproc]
    set pretty_procbody [util_tcl_to_html ${procbody}]
} else {
    set allcmds [lsort [info commands *]]
    set allprocs [lsort [info procs *]]

}
