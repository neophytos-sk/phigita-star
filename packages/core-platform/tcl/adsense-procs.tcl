namespace eval ::xo {;}
namespace eval ::xo::google {;}
namespace eval ::xo::google::adsense {;}
namespace eval ::xo::amazon {;}

if { [ns_config ns/server/[ns_info server] performance_mode_p 1] } {

    proc ::xo::google::adsense::slot {slot width height {threshold "0.59"} {client "pub-1374549828513817"}} {
	# if { [expr { rand() > ${threshold} }] } { return }

	# ::xo::kit::is_registered_p
	if { [ad_conn user_id] eq {814} } {
	    div -style "background:#f0f0f0;width:${width}px;height:${height}px;" {
		div -style "margin:auto;" {
		    #nt "&nbsp;"
		    t "$slot (${width}x${height})"
		}
	    }
	} else {
	    nt [subst -nocommands -nobackslashes {
		<script type="text/javascript"><!--
		google_ad_client = "${client}";
		google_ad_slot = "${slot}";
		google_ad_width = ${width};
		google_ad_height = ${height};
		//--></script>
		<script type="text/javascript"
		src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
		</script>
	    }]
	}
    }

    proc ::xo::google::adsense::get_slot_html {slot width height {client "pub-1374549828513817"}} {

	# ::xo::kit::is_registered_p
	if { [ad_conn user_id] eq {814} } {

	    return [subst -nocommands -nobackslashes {<div style="background:#f0f0f0;width:${width}px;height:${height}px;"><div style="text-align:center;">${slot} (${width}x${height})</div></div>}]

	} else {

	    return [subst -nocommands -nobackslashes {
		<script type="text/javascript"><!--
		google_ad_client = "${client}";
		google_ad_slot = "${slot}";
		google_ad_width = ${width};
		google_ad_height = ${height};
		//--></script>
		<script type="text/javascript"
		src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
		</script>
	    }]

	}

    }

    proc ::xo::amazon::kindle {} {
	nt {<iframe src="http://rcm.amazon.com/e/cm?lt1=_blank&bc1=000000&IS2=1&nou=1&bg1=FFFFFF&fc1=000000&lc1=0000FF&t=phigita-20&o=1&p=8&l=as4&m=amazon&f=ifr&ref=ss_til&asins=B0051QVF7A" style="width:120px;height:240px;" scrolling="no" marginwidth="0" marginheight="0" frameborder="0"></iframe>}
    }

    proc ::xo::amazon::kindle_in_html {} {
	return {<iframe src="http://rcm.amazon.com/e/cm?lt1=_blank&bc1=000000&IS2=1&nou=1&bg1=FFFFFF&fc1=000000&lc1=0000FF&t=phigita-20&o=1&p=8&l=as4&m=amazon&f=ifr&ref=ss_til&asins=B0051QVF7A" style="width:120px;height:240px;" scrolling="no" marginwidth="0" marginheight="0" frameborder="0"></iframe>}
    }


} else {

    proc ::xo::google::adsense::slot {slot width height {client "pub-1374549828513817"}} {
	div -style "background:#f0f0f0;width:${width};height:${height};" {
	    div -style "margin:auto;" {
		t "google: $slot (${width}x${height})"
	    }
	}
    }



    proc ::xo::google::adsense::get_slot_html {slot width height {client "pub-1374549828513817"}} {

	return [subst -nocommands -nobackslashes {<div style="background:#f0f0f0;width:${width}px;height:${height}px;"><div style="text-align:center;">${slot} (${width}x${height})</div></div>}]

    }





    proc ::xo::amazon::kindle {} {
	div -style "background:#f0f0f0;width:120px;height:240px;margin:auto;" {
	    div -style "margin:auto;" {
		t "amazon: kindle (120x240)"
	    }
	}
    }


    proc ::xo::amazon::kindle_in_html {} {
	return {<iframe src="http://rcm.amazon.com/e/cm?lt1=_blank&bc1=000000&IS2=1&nou=1&bg1=FFFFFF&fc1=000000&lc1=0000FF&t=phigita-20&o=1&p=8&l=as4&m=amazon&f=ifr&ref=ss_til&asins=B0051QVF7A" style="width:120px;height:240px;" scrolling="no" marginwidth="0" marginheight="0" frameborder="0"></iframe>}
    }


}
