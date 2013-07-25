namespace path {::xo::ui ::template}

Page new -master ::xo::ui::DefaultMaster -title "Synchronize Books" -appendFromScript {

    Form new \
	-label "Synchronize Books" \
	-action sync \
	-autoHeight true \
	-style "padding:5px;margin-left:auto;margin-right:auto;" \
	-appendFromScript {

	    TextField new \
		-name low \
		-label "From" \
		-allowBlank true \
		-width 50

	    TextField new \
		-name high \
		-label "To" \
		-allowBlank true \
		-width 50

	} -proc action(sync) {marshaller} {
	    set mydict [my getDict]
	    set low [dict get $mydict low]
	    set high [dict get $mydict high]
	    if { ![string is integer $low] || ![string is integer $high] } {
		$marshaller go -select "" -action draw
	    }
	    ns_schedule_proc -once 0 get_all_biblionet_books $low $high
	    ad_returnredirect .
	}

}