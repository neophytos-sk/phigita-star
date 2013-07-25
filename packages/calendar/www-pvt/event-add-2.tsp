ad_page_contract {

    @author Neophytos Demetriou

} {
    {title ""}
    start_year
    start_mon
    start_day
    start_hour
    start_min
    duration_hour
    duration_min
    shared_p
}


tmpl::master -context_bar [ad_context_bar "Add Event (Process)"] {

    foreach varname {title start_year start_mon start_day start_hour start_min duration_hour duration_min shared_p} {

	t "${varname} = [set ${varname}]"
	p

    }
}
