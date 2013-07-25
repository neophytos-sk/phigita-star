
set questions [Question retrieve \
                   -pathexp "Subsite [ad_conn subsite_id]" \
                   -output "*" \
                   -order "creation_date desc" \
		   -criteria "cnt_answers=0"]




tmpl::master -title "Unanswered Questions" -context_bar [ad_context_bar "Unanswered Questions"] {

    h2 {
	t "Unanswered Questions"
    }


    if {[string equal ${questions} {}]} {
	ul {
	    li {
		i {
		    t "No unanswered questions at this moment."
		}
	    }
	}
    }

    foreach question ${questions} {
	li {
	    if { [$question set kind] == 1 } {
		t { [vox pop] }
	    }
	    a -href [${question} set id] {
		t [${question} set subject]
	    }
	    t " ([lc_time_fmt [${question} set creation_date] %q])"
	}
    }
    p
    div -style "margin-left:32px;width:250;padding:5 5 5 5;border:1px dashed \#efefef;" {
	####::xo::google::adsense::slot 2463122883 250 250

	if {0} {
		    <script type="text/javascript"><!--
		    google_language = 'en';
		    google_encoding = 'utf-8';
		    google_country = 'gr';
		    google_ad_client = "pub-1374549828513817";
		    google_alternate_color = "ffffff";
		    google_ad_width = 234;
		    google_ad_height = 60;
		    google_ad_format = "234x60_as";
		    google_ad_type = "text";
		    google_ad_channel = "";
		    //--></script>
		    <script type="text/javascript" src="http://pagead2.googlesyndication.com/pagead/show_ads.js"></script>
	}
    }


}


