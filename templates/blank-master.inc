dataview {
    head {
	meta -http-equiv "content-type" -content "text/html; charset=UTF-8"
	if { [exists_and_not_null arg(description)] } {
	    meta -name "description" -content $arg(description)
	}
	if { [exists_and_not_null arg(keywords)] } {
	    meta -name "keywords" -content $arg(keywords)
	}
	if { [exists_and_not_null arg(noindex)] } {
	    meta -name "robots" -content "noindex"
	}
	if { [exists_and_not_null arg(title)] } {
	    title { t $arg(title) }
	}

	# add rss feed, if rss attributes exists
	if { [exists_and_not_null arg(rss)] } {
	    link \
		-rel "alternate" \
		-type "application/rss+xml" \
		-title "RSS" \
		-href $arg(rss)
	}
    }
    set bodynode [::tmpl::body {
	slave
    }]

    if { [exists_and_not_null arg(onload)] } {
	$bodynode setAttribute onload $arg(onload)
    }
}
