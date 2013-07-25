set questions [Question retrieve \
		   -pathexp "Subsite [ad_conn subsite_id]" \
		   -output "*" \
		   -order "creation_date desc"]


tmpl::master -title "List of Questions" -context_bar [ad_context_bar "List of Questions"] {

    h2 {
	t "List of Questions"
    }

    if {[string equal ${questions} {}]} {
        ul {
            li {
                i {
                    t "No questions at this moment."
                }
            }
        }
    }
 
    foreach question ${questions} {
        li {
            a -href [${question} set id] {
                t [${question} set subject]
            }
            t " ([lc_time_fmt [${question} set creation_date] %q])"
	}
    }
    p
    div -style "margin-left:32px;width:250;padding:5 5 5 5;border:1px dashed \#efefef;" {
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
